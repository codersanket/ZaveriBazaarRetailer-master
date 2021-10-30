import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/retailer_rating.dart';
import 'package:sonaar_retailer/services/Exception.dart';

class RetailerRatingService {
  /// Get all retailers
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response = await DioProvider()
          .dio()
          .get('/retailer-ratings', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get all retailers', e.toString())));
    }
  }

  /// Get retailer by id
  static Future<RetailerRating> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/retailer-ratings/$id');

      return Future.value(RetailerRating.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get retailer by id', e.toString())));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
