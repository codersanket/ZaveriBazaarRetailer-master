import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/bullion_city.dart';
import 'package:sonaar_retailer/models/error_handler.dart';

import 'Exception.dart';

class CityService {
  static List<dynamic> _states = [];

  /// get states with cities prefilled
  static Future<dynamic> getStates() async {
    try {
      if (_states.length == 0) {
        var response = await DioProvider()
            .dio()
            .get('/cities/states', queryParameters: {'fill_cities': '1'});

        _states = response.data;
      }
      return Future.value(_states);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('get state based on city', e.toString())));
    }
  }

  /// get city from pin code
  static Future<dynamic> getCityFromPinCode(int pinCode) async {
    try {
        var response = await DioProvider()
            .dio()
            .get('/m/get-city', queryParameters: {'pincode': pinCode});

        dynamic _stateList = response.data['city'];
      return Future.value(_stateList);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('get city from pin code', e.toString())));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
