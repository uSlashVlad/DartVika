import 'package:mongo_dart/mongo_dart.dart';

class MongoDB {
  static final MongoDB _singleton = MongoDB._internal();

  factory MongoDB() {
    return _singleton;
  }

  MongoDB._internal();

  Db db;

  Future<void> start(String name,
      {String password, String host = 'localhost'}) async {
    db = (password != null)
        ? new Db("mongodb://admin:$password@$host/$name?authSource=admin")
        : new Db("mongodb://$host/$name");
    await db.open();
  }

  Future<void> stop() async {
    await db.close();
  }

  Future<List<Map<String, dynamic>>> loadAllData(String collection) =>
      db.collection(collection).find().toList();

  Future<Map<String, dynamic>> loadOne(String collection, Map<String, dynamic> selector) =>
      db.collection(collection).findOne(selector);

  Future<void> insert(String collection, Map<String, dynamic> document) async {
    await db.collection(collection).insert(document);
  }

  Future<void> delete(String collection, Map<String, dynamic> document) async {
    await db.collection(collection).remove(document);
  }
}
