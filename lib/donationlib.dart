import 'package:file/file.dart';
import 'package:file/local.dart';
import 'dart:convert';

class DonationLib {
  DonationLib(this.jsonPath) {
    fs = LocalFileSystem();
    jsonFile = fs.file(jsonPath);
  }

  FileSystem fs;
  File jsonFile;
  final String jsonPath;

  List<dynamic> loadList() {
    return jsonDecode(jsonFile.readAsStringSync());
  }
}
