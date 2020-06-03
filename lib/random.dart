import 'dart:math';

class RandomHelper {

  /// Method returns random int from [min] to [max] exclusive
  static int rangeInt(int min, max) {
    return min + Random().nextInt(max - min);
  }

  /// Method returns random double from [min] to [max] inclusive
  static double rangeDouble(double min, max) {
    return min + (Random().nextDouble() * max - min);
  }

  /// Method returns random element of [list]
  static dynamic listElement(List list) {
    return list[rangeInt(0, list.length)];
  }

  /// Method returns true with [k] chance
  static bool chance(double k) {
    double rnd = rangeDouble(0, 1);
    return (rnd <= k) ? true : false;
  }
}