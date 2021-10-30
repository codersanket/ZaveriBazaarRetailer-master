import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/city.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/wholesaler_rating.dart';
import 'package:sonaar_retailer/services/Exception.dart';

class WholesalerRatingService {
  static List<City> _cities = [];

  /// Get all ratings
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response = await DioProvider()
          .dio()
          .get('/wholesaler-ratings', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get wholesaler ratings', e.toString())));
    }
  }
  
  
  static Future getRatingbyWholesalerId(String id) async {
    try {
      var params = {'wholesaler_firms_id': id};
      var response = await DioProvider()
          .dio()
          .get('/wholesaler-ratings/wholesaler_rate/', queryParameters: params);
      //print(response.data[0]);
      //print(response.data);
      //var res = response.data;
      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get rating by wholesaler id', e.toString())));
    }
  }

  /// Get rating by id
  static Future<WholesalerRating> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/wholesaler-ratings/$id');

      return Future.value(WholesalerRating.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Rating', e.toString())));
    }
  }

  /// Get wholesaler by id
  static Future<Map<String, dynamic>> getWholesalerById(String id) async {
    try {
      var response =
          await DioProvider().dio().get('/wholesaler-ratings/$id/wholesaler');

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('get wholesaler by id', e.toString())));
    }
  }

  /// WholesalerRating create
  static Future<WholesalerRating> create(FormData formData) async {
    try {
      var response =
          await DioProvider().dio().post('/wholesaler-ratings', data: formData);

      return Future.value(WholesalerRating.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Create wholesaler rating', e.toString())));
    }
  }

  /// WholesalerRating update
  static Future<WholesalerRating> update(
      String wholesalerId, FormData formData) async {
    try {
      var response = await DioProvider()
          .dio()
          .post('/wholesaler-ratings/$wholesalerId', data: formData);

      return Future.value(WholesalerRating.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Update wholesaler rating', e.toString())));
    }
  }

  /// WholesalerRating delete
  static Future<WholesalerRating> delete(String wholesalerId) async {
    try {
      var response =
          await DioProvider().dio().delete('/wholesaler-ratings/$wholesalerId');

      return Future.value(WholesalerRating.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Delete wholesaler rating', e.toString())));
    }
  }

  /// get cities with atleast one rating
  static Future<List<City>> getCities() async {
    try {
      if (_cities.length == 0) {
        var response =
            await DioProvider().dio().get('/wholesaler-ratings/cities');

        _cities = City.listFromJson(response.data);
      }
      return Future.value(_cities);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get city with wholesaler rating', e.toString())));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
