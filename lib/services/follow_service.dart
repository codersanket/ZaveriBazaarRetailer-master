import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/follow.dart';

import 'Exception.dart';

class FollowService {
  /// Get all follows
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/follows', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Get follow by id
  static Future<Follow> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/follows/$id');

      return Future.value(Follow.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Get wholesaler by id
  static Future<Map<String, dynamic>> getWholesalerById(String id) async {
    try {
      var response = await DioProvider().dio().get('/follows/$id/wholesaler');

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Follow create
  static Future<Follow> create({String mobile, String firmId}) async {
    try {
      final data = {};
      if (mobile != null) data['mobile'] = mobile;
      if (firmId != null) data['followed_id'] = firmId;

      var response = await DioProvider().dio().post('/follows', data: data);

      return Future.value(Follow.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Follow accept
  static Future<Follow> accept(String followId) async {
    try {
      var response =
          await DioProvider().dio().post('/follows/$followId/accept', data: {});

      return Future.value(Follow.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Follow ignore
  static Future<Follow> ignore(String followId) async {
    try {
      var response =
          await DioProvider().dio().post('/follows/$followId/ignore', data: {});

      return Future.value(Follow.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Follow delete
  static Future<Follow> delete(String followId) async {
    try {
      var response = await DioProvider().dio().delete('/follows/$followId');

      return Future.value(Follow.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
