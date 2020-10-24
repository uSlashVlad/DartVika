import 'dart:io';

import 'package:DartVika/stringlib.dart';

enum ActionType { Message, CallbackQuery, Other }

class Logger {
  Logger(this.path) {
    logFile = File(path);
  }
  File logFile;
  final String path;

  /// Method adds at end of log file "[separator][text]"
  String log(String text, {String separator = '\n'}) {
    print(text);
    logFile.writeAsStringSync(text, mode: FileMode.append);
    return text;
  }

  /// Method for logging some specific action.
  void logAction(
    ActionType type, {
    String user,
    String channel,
    String text,
    String additional = '',
    DateTime time,
  }) {
    // DateTime time = DateTime.now();
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
