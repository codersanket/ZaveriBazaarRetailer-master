import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/melting.dart';
import 'package:sonaar_retailer/models/brand.dart';
import 'package:sonaar_retailer/models/category.dart';
import 'package:sonaar_retailer/models/city.dart';
import 'package:sonaar_retailer/models/product.dart';
import 'package:sonaar_retailer/models/product_type.dart';
import 'package:sonaar_retailer/models/subcategory.dart';
import 'package:sonaar_retailer/models/weight_range.dart';
import 'package:sonaar_retailer/services/Exception.dart';

class ProductService {
  static List<Category> _categories = [];
  static List<ProductType> _types = [];
  static List<Brand> _brands = [];
  static List<Melting> _meltings = [];
  static List<String> _tags = [];
  static WeightRange _weightRange;

  //product methods
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/products', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get all products', e.toString())));
    }
  }

  static Future<dynamic> getSortedProducts(
      Map<String, dynamic> params, categoryId) async {
    try {
      var response = await DioProvider().dio().get(
          categoryId == null
              ? '/products/categorywise'
              : '/products/subcategorywise/$categoryId',
          queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get sorted product', e.toString())));
    }
  }

  static Future<Product> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/products/$id');

      return Future.value(Product.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Product get by id', e.toString())));
    }
  }

  /// Product create
  static Future<Product> create(FormData formData) async {
    try {
      var response =
          await DioProvider().dio().post('/products', data: formData);

      return Future.value(Product.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Create product', e.toString())));
    }
  }

  /// Product update
  static Future<Product> update(String productId, FormData formData) async {
    try {
      var response = await DioProvider()
          .dio()
          .post('/products/$productId', data: formData);

      return Future.value(Product.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Update product', e.toString())));
    }
  }

  /// Toggle bookmark
  static Future<dynamic> toggleBookmark(
      String productId, bool bookmarked) async {
    try {
      var response = await DioProvider().dio().post(
        '/products/$productId/bookmark/' + (bookmarked ? 'off' : 'on'),
        data: {},
      );

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('BookMark product', e.toString())));
    }
  }

  //product attributes
  static Future<dynamic> getCategories() async {
    try {
      if (_categories.length == 0) {
        var response = await DioProvider()
            .dio()
            .get('/categories', queryParameters: {'nopaginate': '1'});

        _categories = Category.listFromJson(response.data);
      }

      return Future.value(_categories);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get filter category', e.toString())));
    }
  }

  static Future<dynamic> getSubcategories(String categoryId) async {
    try {
      var response = await DioProvider().dio().get('/subcategories',
          queryParameters: {'nopaginate': '1', 'category_id': categoryId});

      return Future.value(Subcategory.listFromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get filter subcategories', e.toString())));
    }
  }

  static Future<dynamic> getTypes() async {
    try {
      if (_types.length == 0) {
        var response = await DioProvider()
            .dio()
            .get('/product-types', queryParameters: {'nopaginate': '1'});

        _types = ProductType.listFromJson(response.data);
      }
      return Future.value(_types);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get type of product', e.toString())));
    }
  }

  static Future<dynamic> getBrands() async {
    try {
      if (_brands.length == 0) {
        var response = await DioProvider()
            .dio()
            .get('/brands', queryParameters: {'nopaginate': '1'});

        _brands = Brand.listFromJson(response.data);
      }
      return Future.value(_brands);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('get Product brand', e.toString())));
    }
  }

  static Future<dynamic> getMeltings() async {
    try {
      if (_meltings.length == 0) {
        var response = await DioProvider()
            .dio()
            .get('/products/meltings', queryParameters: {'nopaginate': '1'});

        _meltings = Melting.listFromJson(response.data);
      }
      return Future.value(_meltings);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get meltings', e.toString())));
    }
  }

  static Future<dynamic> getCities([String categoryId]) async {
    try {
      var response = await DioProvider().dio().get('/products/cities',
          queryParameters: {'category_id': categoryId});

      return Future.value(City.listFromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get city', e.toString())));
    }
  }

  static Future<dynamic> getWeightRange() async {
    try {
      if (_weightRange == null) {
        var response = await DioProvider().dio().get('/products/weight-range');
        _weightRange = WeightRange.fromJson(response.data);
      }
      return Future.value(_weightRange);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get weight range ', e.toString())));
    }
  }

  static Future<dynamic> getTags(String categoryId) async {
    try {
      if (_tags.length == 0) {
        var response = await DioProvider().dio().get<List<dynamic>>(
          '/products/tags',
          queryParameters: {'category_id': categoryId},
        );

        _tags.clear();
        response.data.forEach((d) => _tags.add(d.toString()));
      }
      return Future.value(_tags);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get tags', e.toString())));
    }
  }


  //Top 10 products
  static Future<dynamic> getTopProducts() async {
    try {
      var response = await DioProvider().dio().get('/products/product_topten');

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Top 10 product', e.toString())));
    }
  }

  //new arrivals
  static Future<dynamic> getNewProducts() async {
    try {
      var response = await DioProvider().dio().get("/m/add_new_arrivals");
      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Product new arrivals', e.toString())));
    }
  }

  //wholesaler - category list
  static Future<dynamic> getWholesalerCategory({String wholesalerId}) async {
    try {
      var response = await DioProvider().dio().get("/products/wholesellerwisecategory/$wholesalerId");
      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Wholesaler category list', e.toString())));
    }
  }


  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
