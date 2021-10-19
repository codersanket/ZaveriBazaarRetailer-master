import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';

import 'auth_service.dart';

class UserException1 {
  /// user Exception
  static Future<void> userException(String vendorId, String type) async {
    try {
      AuthService.getUser().then((res) async {
        var response = await DioProvider().dio().post(
          '/users/exception',
          data: {
            'user_id': res.id,
            'mobile_no': res.mobile,
            'other': vendorId,
            'type': type,
          },
        );

        return Future.value();
      }).catchError((err) {
        print(err);
      });
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }

  ///filter data
  static Future<void> getFilterData() async {
    try {
      AuthService.getUser().then((res) async {
        var response = await DioProvider().dio().post(
          '/users/exception',
          data: {
            'user_id': res.id,
            'name': res.name,
            'mobile_no': res.mobile,
          },
        );

        return Future.value();
      }).catchError((err) {
        print(err);
      });
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }
}
