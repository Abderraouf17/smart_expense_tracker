import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  UserService._();
  static final instance = UserService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  /// Stream the current user's profile document (users/{uid}).
  Stream<DocumentSnapshot<Map<String, dynamic>>>? currentUserProfileStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Convenience to get the current user's display name with fallback.
  Stream<String> currentDisplayNameStream() {
    final uid = _auth.currentUser?.uid;
    final email = _auth.currentUser?.email ?? 'User';
    if (uid == null) return Stream.value('User');
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data();
      final name = data?['name'] as String?;
      return (name != null && name.trim().isNotEmpty) ? name : (email ?? 'User');
    });
  }
}
