import 'package:dio/dio.dart';
import 'package:sonaar_retailer/services/Exception.dart';

class ErrorHandler {
  static handleError(e) {
    if (e is DioError && e.type == DioErrorType.RESPONSE) {
      return e.response.data['message'];
    } else if (e is DioError && e.type == DioErrorType.DEFAULT) {
      return e.error;
    } else {
      UserException1.userException('Product', e.toString());
      return e;
    }
  }
}
