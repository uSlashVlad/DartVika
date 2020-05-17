import 'dart:math';

class RandomHelper {
  static int range(int min, max) {
    return min + Random().nextInt(max - min);
  }

  static double rangeDouble(double min, max) {
    return min + (Random().nextDouble() * max - min);
  }

  static dynamic listElement(List list) {
    return list[range(0, list.length)];
  }

  static bool chance(double k) {
    double rnd = rangeDouble(0, 1);
    return (rnd <= k) ? true : false;
  }
}