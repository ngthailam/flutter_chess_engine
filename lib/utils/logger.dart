// ignore_for_file: constant_identifier_names

import 'package:flutter/foundation.dart';

class Logger {
  static const String TAG = 'ChessEngine';

  static const String COLOR_CODE_INFO = "34";
  static const String COLOR_CODE_ERROR = "31";

  static void d(String msg) {
    if (kDebugMode) {
      print('[$TAG]: $msg');
    }
  }

  static void e(String msg) {
    if (kDebugMode) {
      print('[$TAG][ERROR]: $msg');
    }
  }
}
