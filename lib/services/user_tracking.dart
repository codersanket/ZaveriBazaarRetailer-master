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

  ///filter data
  static Future<void> getFilterData(String subcategories, String categoryId,
      String min, String max,String searchKey, String cities, String productType) async {
    try {
      var response = await DioProvider().dio().post(
        '/search_track/insert',
        data: {
          'retailer_id': AuthService.user.id,
          'name': AuthService.user.name,
          'phone': AuthService.user.mobile,
          'subcategories': subcategories,
          'category_id': categoryId,
          'min_weight': min,
          'max_weight': max,
          'search_key':searchKey,
          'cities': cities,
          'product_type': productType,
        },
      );
      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
