import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';

import 'auth_service.dart';

class UserException1 {
  /// user Exception
  static Future<void> userException(String errorType, String errorMsg) async {
    try {
      AuthService.getUser().then((res) async {
        var response = await DioProvider().dio().post(
          '/m/error_log',
          //'/users/exception',
          data: {
            'number': res.mobile,
            'name':res.name,
            'error_type': errorType,
            'user_id': res.id,
            'error_message': errorMsg,
          },
        );

        return Future.value();
      }).catchError((err) {
      });
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }

}
