class StringLib {
  static String beautifulizeTime(DateTime time) {
    String hours = (time.hour >= 10) ? '${time.hour}' : '0${time.hour}';
    String minutes = (time.minute >= 10) ? '${time.minute}' : '0${time.minute}';
    String seconds = (time.second >= 10) ? '${time.second}' : '0${time.second}';
    return '[$hours:$minutes:$seconds]';
  }
}
