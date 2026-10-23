import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kayros/config/firebase_runtime.dart';

class Database {
  static String? userUid;
  static String? userUids;

  static String get _uid {
    final uid = userUid ?? FirebaseRuntime.auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Debe haber un usuario autenticado.');
    }
    return uid;
  }

  static CollectionReference<Map<String, dynamic>> get _items =>
      FirebaseRuntime.firestore
          .collection('notes')
          .doc(_uid)
          .collection('items');

  static Future<void> addItem({
    required String title,
    required String description,
  }) async {
    await _items.add({'title': title, 'description': description});
  }

  static Future<void> updateItem({
    required String title,
    required String description,
    required String docId,
  }) async {
    await _items
        .doc(docId)
        .update({'title': title, 'description': description});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> readItems() {
    return _items.snapshots();
  }

  static Future<void> deleteItem({required String docId}) async {
    await _items.doc(docId).delete();
  }
}
