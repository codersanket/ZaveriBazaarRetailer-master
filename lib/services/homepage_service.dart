import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';

class HomePageService{
  
  //get all status
  static Future<dynamic> getAllStatus(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/status', queryParameters: params);

      return Future.value(response.data);
    }
    catch (e) {
      return Future.error( _handleError(e));
    }
  }

  ///youtube video
  static Future<dynamic> getAllVideo() async {
    try {
      var response = await DioProvider().dio().get('/youtube_video');

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //visit mumbai
  static Future<dynamic> visitMumbai(FormData formData) async {
    try {
      var response = await DioProvider().dio().post('/mumbai_visit/insert', data: formData);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }


  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }

}