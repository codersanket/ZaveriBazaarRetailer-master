import 'package:dio/dio.dart';

class ErrorHandler {
  static handleError(e) {
    if (e is DioError && e.type == DioErrorType.RESPONSE) {
      return e.response.data['message'];
    } else if (e is DioError && e.type == DioErrorType.DEFAULT) {
      return e.error;
    } else {
      return e;
    }
  }
}
