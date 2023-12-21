import 'dart:math';

extension MapExtension on Map {
  randomKey() {
    final random = Random().nextInt(length);
    return keys.elementAt(random);
  }
}
