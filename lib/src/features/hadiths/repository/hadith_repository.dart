import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore'dagi bitta hadis hujjati.
typedef HadithDocument = QueryDocumentSnapshot<Map<String, dynamic>>;

/// Hadislar bilan ishlash uchun ma'lumotlar manbasi.
abstract class HadithRepository {
  /// Hadislar ro'yxatining real vaqt oqimi.
  Stream<List<HadithDocument>> watch();

  Future<void> add(Map<String, dynamic> data);

  Future<void> delete(String id);

  Future<void> update(String id, Map<String, String> changes);
}

/// [FirebaseFirestore] kolleksiyasi orqali ishlaydigan amalga oshirish.
class FirestoreHadithRepository implements HadithRepository {
  FirestoreHadithRepository(this._collection);

  final CollectionReference<Map<String, dynamic>> _collection;

  @override
  Stream<List<HadithDocument>> watch() =>
      _collection.snapshots().map((snapshot) => snapshot.docs);

  @override
  Future<void> add(Map<String, dynamic> data) => _collection.add(data);

  @override
  Future<void> delete(String id) => _collection.doc(id).delete();

  @override
  Future<void> update(String id, Map<String, String> changes) =>
      _collection.doc(id).update({
        for (final field in changes.entries)
          FieldPath([field.key]): field.value,
      });
}
