import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MFAService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enableMFA() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _firestore.collection('users').doc(user.uid).update({
      'mfaEnabled': true,
      'mfaEnrolledAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> disableMFA() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    await _firestore.collection('users').doc(user.uid).update({
      'mfaEnabled': false,
      'mfaDisabledAt': FieldValue.serverTimestamp(),
    });
  }

  Future<bool> isMFAEnabled() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      return doc.data()?['mfaEnabled'] ?? false;
    } catch (e) {
      return false;
    }
  }
}