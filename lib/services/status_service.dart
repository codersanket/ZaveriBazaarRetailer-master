import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/status.dart';

class StatusService{
  
  //get all status
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/status', queryParameters: params);

      return Future.value(response.data);
    }
    catch (e) {
      return Future.error( _handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }

}