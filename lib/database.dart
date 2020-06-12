import 'package:mongo_dart/mongo_dart.dart';

class MongoDB {
  static final MongoDB _singleton = MongoDB._internal();

  factory MongoDB() {
    return _singleton;
  }

  MongoDB._internal();

  Db db;

  Future<void> start(String name) async {
    db = new Db("mongodb://localhost:27017/$name");
    await db.open();
  }

  Future<void> stop() async {
    await db.close();
  }

  Future<List<Map<String, dynamic>>> loadAllData(String collection) async {
    return await db.collection(collection).find().toList();
  }

  Future<void> insert(String collection, Map<String, dynamic> document) async {
    await db.collection(collection).insert(document);
  }
}
