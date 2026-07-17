import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/influencer_product_assignment_model.dart';
import '../models/product_model.dart';

class InfluencerProductException implements Exception {
  final String code;
  final String message;

  const InfluencerProductException(this.code, this.message);

  @override
  String toString() => message;
}

class InfluencerProductService {
  static const String collectionName = 'influencer_products';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Random _secureRandom;

  InfluencerProductService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Random? secureRandom,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _secureRandom = secureRandom ?? Random.secure();

  Future<InfluencerProductAssignment> activateProduct(Product product) async {
    final user = _requireCurrentUser();
    if (product.id.trim().isEmpty) {
      throw const InfluencerProductException(
        'invalid-product',
        'This product does not have a valid product ID.',
      );
    }

    final assignmentId = _assignmentId(user.uid, product.id);
    final assignmentReference =
        _firestore.collection(collectionName).doc(assignmentId);
    final productReference = _firestore.collection('products').doc(product.id);
    final userReference = _firestore.collection('users').doc(user.uid);
    final generatedReferralCode = _generateReferralCode();

    late InfluencerProductAssignment result;

    await _firestore.runTransaction((transaction) async {
      final userDocument = await transaction.get(userReference);
      _verifyInfluencerRole(userDocument);

      final productDocument = await transaction.get(productReference);
      if (!productDocument.exists) {
        throw const InfluencerProductException(
          'product-not-found',
          'This product is no longer available.',
        );
      }

      final liveProduct = Product.fromFirestore(productDocument);
      if (!liveProduct.isActive) {
        throw const InfluencerProductException(
          'inactive-product',
          'This product is inactive and cannot be promoted.',
        );
      }
      if (!liveProduct.isInStock) {
        throw const InfluencerProductException(
          'out-of-stock',
          'This product is currently out of stock.',
        );
      }

      final assignmentDocument = await transaction.get(assignmentReference);
      final now = DateTime.now();

      if (assignmentDocument.exists) {
        final existing =
            InfluencerProductAssignment.fromFirestore(assignmentDocument);
        if (existing.influencerId != user.uid ||
            existing.productId != liveProduct.id) {
          throw const InfluencerProductException(
            'assignment-conflict',
            'The existing product assignment is invalid.',
          );
        }
        if (existing.isActive) {
          throw const InfluencerProductException(
            'already-active',
            'This product is already in your active catalog.',
          );
        }

        result = existing.copyWith(
          vendorId: liveProduct.vendorId,
          productName: liveProduct.name,
          imageUrl: liveProduct.imageUrl,
          sellingPrice: liveProduct.price,
          commissionType: liveProduct.commissionType,
          commissionValue: liveProduct.commissionValue,
          status: InfluencerProductStatus.active,
          updatedAt: now,
          clearDeactivatedAt: true,
          referralCode: existing.referralCode.isEmpty
              ? generatedReferralCode
              : existing.referralCode,
        );

        transaction.set(
          assignmentReference,
          result.toFirestore(),
          SetOptions(merge: true),
        );
        return;
      }

      result = InfluencerProductAssignment(
        assignmentId: assignmentId,
        influencerId: user.uid,
        vendorId: liveProduct.vendorId,
        productId: liveProduct.id,
        productName: liveProduct.name,
        imageUrl: liveProduct.imageUrl,
        sellingPrice: liveProduct.price,
        commissionType: liveProduct.commissionType,
        commissionValue: liveProduct.commissionValue,
        status: InfluencerProductStatus.active,
        activatedAt: now,
        updatedAt: now,
        referralCode: generatedReferralCode,
      );

      transaction.set(assignmentReference, result.toFirestore());
    });

    return result;
  }

  Future<void> deactivateProduct(String productId) async {
    final user = _requireCurrentUser();
    if (productId.trim().isEmpty) {
      throw const InfluencerProductException(
        'invalid-product',
        'A valid product ID is required.',
      );
    }

    final assignmentReference = _firestore
        .collection(collectionName)
        .doc(_assignmentId(user.uid, productId));

    await _firestore.runTransaction((transaction) async {
      final assignmentDocument = await transaction.get(assignmentReference);
      if (!assignmentDocument.exists) {
        throw const InfluencerProductException(
          'assignment-not-found',
          'This product is not assigned to your catalog.',
        );
      }

      final assignment =
          InfluencerProductAssignment.fromFirestore(assignmentDocument);
      if (assignment.influencerId != user.uid) {
        throw const InfluencerProductException(
          'permission-denied',
          'You cannot change this product assignment.',
        );
      }
      if (!assignment.isActive) return;

      final now = DateTime.now();
      transaction.update(assignmentReference, <String, dynamic>{
        'status': InfluencerProductStatus.inactive.name,
        'updatedAt': Timestamp.fromDate(now),
        'deactivatedAt': Timestamp.fromDate(now),
      });
    });
  }

  Stream<List<InfluencerProductAssignment>> watchMyAssignments({
    bool activeOnly = false,
  }) {
    final user = _requireCurrentUser();

    return _firestore
        .collection(collectionName)
        .where('influencerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final assignments = snapshot.docs
          .map(
              (document) => InfluencerProductAssignment.fromFirestore(document))
          .where((assignment) => !activeOnly || assignment.isActive)
          .toList();
      assignments
          .sort((first, second) => second.updatedAt.compareTo(first.updatedAt));
      return assignments;
    });
  }

  Future<InfluencerProductAssignment?> getMyAssignmentForProduct(
      String productId) async {
    final user = _requireCurrentUser();
    if (productId.trim().isEmpty) return null;

    final document = await _firestore
        .collection(collectionName)
        .doc(_assignmentId(user.uid, productId))
        .get();
    if (!document.exists) return null;

    final assignment = InfluencerProductAssignment.fromFirestore(document);
    if (assignment.influencerId != user.uid) {
      throw const InfluencerProductException(
        'permission-denied',
        'You cannot access this product assignment.',
      );
    }
    return assignment;
  }

  User _requireCurrentUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw const InfluencerProductException(
        'unauthenticated',
        'Please sign in as an influencer to continue.',
      );
    }
    return user;
  }

  void _verifyInfluencerRole(
      DocumentSnapshot<Map<String, dynamic>> userDocument) {
    if (!userDocument.exists) {
      throw const InfluencerProductException(
        'profile-not-found',
        'Your SelloreAI user profile was not found.',
      );
    }

    final role =
        (userDocument.data()?['role'] as String? ?? '').trim().toUpperCase();
    if (role != 'INFLUENCER' && role != 'CREATOR') {
      throw const InfluencerProductException(
        'role-not-allowed',
        'Only influencer accounts can activate products.',
      );
    }
  }

  String _assignmentId(String influencerId, String productId) {
    return '${influencerId}_$productId';
  }

  String _generateReferralCode() {
    const characters =
        'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789';
    return List<String>.generate(
      20,
      (_) => characters[_secureRandom.nextInt(characters.length)],
      growable: false,
    ).join();
  }
}
