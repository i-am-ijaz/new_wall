import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:new_wall/models/wallpaper/wallpaper.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  static FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;

  static final _walls = firestoreInstance.collection(FirestorePath.wallpapers);

  static Stream<List<Wallpaper>> wallpapers() => _walls.snapshots().map(
        (snapshot) => snapshot.docs.map(
          (doc) {
            final data = doc.data();

            return Wallpaper.fromJson({
              'id': doc.id,
              'url': data['url'],
              'tag': data['tag'],
            });
          },
        ).toList(),
      );

  static Future<QuerySnapshot<Map<String,dynamic>>> getWallapers(
    int limit, {
    DocumentSnapshot? startAfter,
  }) async {
    final wallsRef = _walls.limit(limit);

    if (startAfter == null) {
      return wallsRef.get();
    } else {
      return wallsRef.startAfterDocument(startAfter).get();
    }
  }
}

class FirestorePath {
  static const String wallpapers = 'wallpapers';
}
