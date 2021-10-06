import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';

import 'auth_service.dart';

class UserLogService {
  /// user log by id
  static Future<void> userLogById(String vendorId, String eventType) async {
    try {
      AuthService.getUser().then((res) async {
        var response = await DioProvider().dio().post(
          '/m/user-log-by-id',
          data: {
            'user_id': res.id,
            'vendor_id': vendorId,
            'event_type': eventType,
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
}
