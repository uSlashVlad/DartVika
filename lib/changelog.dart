import 'dart:io';

/// Simple ethod fot loading changelog
String loadChanges(String path) {
  final file = File(path);
  return file.readAsStringSync();
}
