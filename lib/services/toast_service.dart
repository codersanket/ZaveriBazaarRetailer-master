import 'package:flutter/material.dart';

class ToastService {
  static void error(
    GlobalKey<ScaffoldState> scaffoldKey,
    String message, [
    bool fixed = false,
  ]) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      behavior: fixed ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
      backgroundColor: Colors.red.shade600,
    ));
  }

  static void success(
    GlobalKey<ScaffoldState> scaffoldKey,
    String message, [
    bool fixed = false,
  ]) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      behavior: fixed ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
      backgroundColor: Colors.green.shade600,
    ));
  }

  static void info(
    GlobalKey<ScaffoldState> scaffoldKey,
    String message, {
    bool fixed = false,
    Duration duration,
  }) {
    scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
      behavior: fixed ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
      backgroundColor: Colors.blue.shade600,
      duration: duration != null ? duration : Duration(seconds: 3),
    ));
  }
}
