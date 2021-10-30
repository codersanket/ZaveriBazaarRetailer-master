import 'dart:convert';

import 'package:intent/category.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/subcategory.dart';
import 'package:sonaar_retailer/pages/widgets/product_filters.dart';
import 'package:sonaar_retailer/pages/widgets/product_filters.dart' as PF;
import 'package:sonaar_retailer/services/product_service.dart';
import 'auth_service.dart';

class Tracking {
  List<Subcategory> subcategories = [];
  List<String> subcategories1 = [];
  PF.Filter filter;

  ///filter data set at floatingaction button
  static Future<void> track(
    String min,
    String max,
    String categoryId,
    String subcategories,
    String cities,
    String productType,
  ) async {
    try {
      var response =
          await DioProvider().dio().post('/search_track/insert', data: {
        'retailer_id': AuthService.user.id,
        'name': AuthService.user.name,
        'phone': AuthService.user.mobile,
        'min_weight': min,
        'max_weight': max,
        'category_id': categoryId,
        'subcategories': subcategories,
        'cities': cities,
        'product_type': productType,
            // remaining to  add result and search key
      });
      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }
///set at apply button
  static Future<void> track1(String searchKey, String categoryId, String min,
      String max, String result) async {
    try {
      var response =
          await DioProvider().dio().post('/search_track/insert', data: {
        'retailer_id': AuthService.user.id,
        'name': AuthService.user.name,
        'phone': AuthService.user.mobile,
        'search_Key': searchKey,
        'category_id': categoryId,
        'min_weight': min,
        'max_weight': max,
        'result': result
      });
      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static Future<void> getResult(String result) async {
    try {
      var response = await DioProvider()
          .dio()
          .post('/search_track/insert', data: {'result': result});
      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
