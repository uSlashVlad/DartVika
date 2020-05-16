import 'package:file/file.dart';
import 'package:file/local.dart';

import 'package:DartVika/stringlib.dart';

enum ActionType { Message, CallbackQuery, Other }

class Logger {
  Logger(this.path) {
    fs = LocalFileSystem();
    logFile = fs.file(path);
  }
  FileSystem fs;
  File logFile;
  final String path;

  void log(String text, {String separator = '\n'}) {
    print(text);
    logFile.writeAsStringSync('${logFile.readAsStringSync()}$separator$text');
  }

  void logAction(ActionType type, {String user, String channel, String text, String additional = ''}) {
    DateTime time = DateTime.now();
    String message = '${StringLib.beautifulizeTime(time)} ';
    switch (type) {
      case ActionType.Message:
        message += '$user >> $channel:$additional $text';
        break;
      case ActionType.CallbackQuery:
        message += '$user ($channel) >> [CQ] $text';
        break;
      default:
    }
    log(message);
  }
}
