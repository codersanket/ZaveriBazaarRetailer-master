import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';

class WholesalerFirmService {
  /// Get all wholesalerfirms
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response = await DioProvider()
          .dio()
          .get('/wholesaler-firms', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Get wholesalerfirm by id
  static Future<WholesalerFirm> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/wholesaler-firms/$id');

      return Future.value(WholesalerFirm.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
