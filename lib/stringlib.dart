class StringLib {
  /// Method returns String in "[hh:mm:ss]" format
  static String beautifulizeTime(DateTime time) {
    String hours = (time.hour >= 10) ? '${time.hour}' : '0${time.hour}';
    String minutes = (time.minute >= 10) ? '${time.minute}' : '0${time.minute}';
    String seconds = (time.second >= 10) ? '${time.second}' : '0${time.second}';
    return '[$hours:$minutes:$seconds]';
  }

  /// Method returns list of Strings
  static List<String> getArgs(String text) {
    final rawArgs = text.split(' ');
    final resArgs = List<String>();
    rawArgs.forEach((element) {
      if (element != '') {
        final temp = element.split('\n');
        resArgs.addAll(temp);
      }
    });
    for (int i = 0; i < rawArgs.length; i++) {}
    return resArgs;
  }

  /// Method joins params from [map] into String (fot HTTP request, for example)
  static String joinMapArgs(Map map) {
    String res = '';
    map.forEach((key, value) {
      res += '$key=$value&';
    });
    res = res.substring(0, res.length - 1);
    return res;
  }
}
