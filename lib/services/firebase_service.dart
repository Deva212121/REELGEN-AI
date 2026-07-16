import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentFirebaseUser => _auth.currentUser;

  FirestoreUser? _currentUser;
  FirestoreUser? get currentUser => _currentUser;

  List<VoidCallback> _listeners = [];

  // OTP Limits
  Map<String, int> _otpAttempts = {};
  Map<String, DateTime> _otpLastSent = {};
  String _verificationId = '';

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _currentUser = null;
        _notifyListeners();
      }
    });
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _currentUser = FirestoreUser(
          uid: uid,
          displayName: data['displayName'],
          email: data['email'],
          role: data['role'] ?? 'INFLUENCER',
          mobile: data['mobile'],
        );
        _notifyListeners();
      } else {
        // User document doesn't exist, create one
        _currentUser = FirestoreUser(
          uid: uid,
          displayName: 'User',
          email: _auth.currentUser?.email,
          role: 'INFLUENCER',
          mobile: '',
        );
        await _firestore.collection('users').doc(uid).set({
          'displayName': 'User',
          'email': _auth.currentUser?.email ?? '',
          'role': 'INFLUENCER',
          'mobile': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _notifyListeners();
      }
    } catch (e) {
      debugPrint('Load user error: $e');
    }
  }

  // ---------- Load Current User ----------
  Future<void> loadCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _loadUserData(user.uid);
    }
  }

  // ---------- Login ----------
  Future<void> login(String email, String password, String role) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _loadUserData(credential.user!.uid);
      await switchRole(role);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loginWithGoogle(String role) async {}

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _notifyListeners();
  }

  Future<void> switchRole(String role) async {
    if (_currentUser == null) return;
    await _firestore.collection('users').doc(_currentUser!.uid).update({
      'role': role,
    });
    _currentUser = _currentUser!.copyWith(role: role);
    _notifyListeners();
  }

  Future<void> createUserIfNotExists(String email, String mobile, String role) async {
    final snapshot = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isEmpty) {
      await _firestore.collection('users').add({
        'email': email,
        'mobile': '+91$mobile',
        'role': role,
        'displayName': email.split('@').first,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ---------- Create User (For direct signup) ----------
  Future<void> createUser(String email, String password, String role) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'email': email,
      'role': role,
      'displayName': email.split('@').first,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------- OTP (Development Mode - Skip Real OTP) ----------
  Future<String> sendOTP(String mobile) async {
    // TEMPORARY: Skip real OTP for testing
    _verificationId = 'test_verification_id_${DateTime.now().millisecondsSinceEpoch}';
    return _verificationId;
  }

  Future<void> verifyOTP(String verificationId, String smsCode) async {
    // TEMPORARY: Skip real OTP verification
    return;
  }

  // ---------- Referral Click ----------
  Future<void> saveReferralClick({
    required String influencerId,
    required String productId,
    required String customerId,
  }) async {
    try {
      await _firestore.collection('referral_clicks').add({
        'influencerId': influencerId,
        'productId': productId,
        'customerId': customerId,
        'timestamp': FieldValue.serverTimestamp(),
        'isDeleted': false,
      });
      debugPrint('Referral click saved: $influencerId -> $productId');
    } catch (e) {
      debugPrint('Error saving referral click: $e');
    }
  }

  // ---------- Parcel Tracking ----------
  Future<void> customerConfirmParcel(String parcelId, bool received, String proof) async {}

  List<Map<String, dynamic>> get parcelTrackings => [];
  List<Map<String, dynamic>> get affiliateLinks => [];
}

class FirestoreUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String role;
  final String? mobile;

  FirestoreUser({
    required this.uid,
    this.displayName,
    this.email,
    this.role = 'INFLUENCER',
    this.mobile,
  });

  FirestoreUser copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? role,
    String? mobile,
  }) {
    return FirestoreUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      role: role ?? this.role,
      mobile: mobile ?? this.mobile,
    );
  }
}