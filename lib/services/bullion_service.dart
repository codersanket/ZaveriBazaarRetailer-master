import 'package:flutter/material.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/bullion_city.dart';
import 'package:sonaar_retailer/models/bullion_vendor.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/get_live_price.dart';

import 'Exception.dart';

class BullionService {
  final BuildContext _context;

  BullionService(this._context);

  /// get states list
  Future<List<String>> getStateList() async {
    try {
      var response = await DioProvider().dio().get('/m/states');

      List<String> _stateList = response.data['states'].cast<String>();

      return Future.value(_stateList);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }
  ///youtube video
  static Future<dynamic> getAll() async {
    try {
      var response = await DioProvider().dio().get('/youtube_video');

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }
  /// get city list
  Future<List<BullionCity>> getCityList(String state) async {
    try {
      Map<String, dynamic> params = {'state': state};
      var response =
          await DioProvider().dio().get('/m/cities', queryParameters: params);

      List<BullionCity> _cityList =
          BullionCity.listFromJson(response.data['states']);

      return Future.value(_cityList);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// get vendor list
  Future<List<BullionVendor>> getVendorList(String userId, String cityId,
      int isGoldVendor, int isSilverVendor) async {
    try {
      Map<String, dynamic> params = {
        'user_id': userId,
        'city_id': cityId,
        'isGoldVendor': isGoldVendor,
        'isSilverVendor': isSilverVendor,
      };
      var response = await DioProvider()
          .dio()
          .get('/m/bullion-vendor-list', queryParameters: params);

      print("response_" + response.toString());

      List<BullionVendor> _vendorList =
          BullionVendor.listFromJson(response.data['users']);

      return Future.value(_vendorList);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// update vendor rating
  Future<String> updateVendorRating(String userId, String vendorId,
      int _recommend, double _rating, String text) async {
    try {
      Map<String, dynamic> params = {
        'user_id': userId,
        'vendor_id': vendorId,
        'recommend': _recommend,
        'ratting': _rating,
        'review': text,
      };
      var response = await DioProvider()
          .dio()
          .post('/m/update-ratting', queryParameters: params);

      print("response_" + response.toString());

      return Future.value(response.data['message']);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// get bullion city list
  Future<List<BullionCity>> getBullionCityList() async {
    try {
      var response = await DioProvider().dio().get('/m/bullion-cities');

      List<BullionCity> _cityList =
          BullionCity.listFromJson(response.data['cities']);

      return Future.value(_cityList);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Get live price
  Future<GetLivePrice> getLivePrice() async {
    try {
      var response = await DioProvider().dio().get('/m/price');

      GetLivePrice getLivePrice = GetLivePrice.fromJson(response.data);

      return Future.value(getLivePrice);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
