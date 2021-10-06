import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:sonaar_retailer/services/auth_service.dart';

class DioProvider {
  static final DioProvider _singleton = new DioProvider._internal();
  final _dio = Dio();

  factory DioProvider() => _singleton;

  Dio dio() => _dio;

  DioProvider._internal() {
    // _dio.options.baseUrl = 'http://192.168.1.141:8005/api';
    // _dio.options.baseUrl = 'https://sonaar.coronainfotech.in/api';
    // _dio.options.baseUrl = 'https://api.zaveribazaar.co.in/api';
    // _dio.options.baseUrl = 'http://13.127.105.85/laravel-zaveri-api/public/api';
    //_dio.options.baseUrl = 'http://13.233.100.19/zaveri/public/api/';
    _dio.options.baseUrl = 'https://test.zaveribazaar.co.in/public/api/';

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions options) async {
        // Add authentication headers
        final tokens = await AuthService.getTokens();
        if (tokens['accessToken'] != null && tokens['refreshToken'] != null) {
          options.headers['x-token'] = tokens['accessToken'];
          options.headers['x-refresh-token'] = tokens['refreshToken'];
        }

        if (options.data is FormData) {
          print("**** Form Data Values ****");
          options.data.fields.forEach((element) {
            print(element.key + ":" + element.value);
          });
        }

        return options;
      },
      onResponse: (Response res) async {
        // Parse authentication headers
        Map<String, List<String>> map = res.headers.map;
        if (map.containsKey('x-token') && map.containsKey('x-refresh-token')) {
          await AuthService.updateTokens(
              map['x-token'][0], map['x-refresh-token'][0]);
        }
        return res;
      },
      onError: (DioError e) {
        // Do something with response error
        if (e.type == DioErrorType.DEFAULT && e.error is SocketException) {
          return 'No internet connection!';
        }
        return e;
      },
    ));
    // to log api request/response
    _dio.interceptors.add(LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true));
    //For Production
    //_dio.interceptors.add(LogInterceptor(responseBody: false));
  }
}
