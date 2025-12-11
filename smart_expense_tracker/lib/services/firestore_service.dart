import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  final _db = FirebaseFirestore.instance;

  Future<void> addTestPing() async {
    await _db.collection('test').add({
      'ping': 'ok',
      'ts': FieldValue.serverTimestamp(),
    });
  }
}
