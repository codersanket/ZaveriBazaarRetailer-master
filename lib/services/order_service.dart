import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/order.dart';

class OrderService{

  //get all orderss
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/create_order', queryParameters: params);

      return Future.value(response.data);
    }
    catch (e) {
      return Future.error( _handleError(e));
    }
  }

  //create order request
  static Future<Orders> create(FormData formData) async {
    try {
      var response =
          await DioProvider().dio().post('/create_order/insert', data: formData);

      return Future.value(Orders.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //update
   static Future<Orders> update(FormData formData) async {
    try {
      var response = await DioProvider()
          .dio()
          .post('/create_order/update', data: formData);

      return Future.value(Orders.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //delete
  static Future<Orders> delete({int id, int userId}) async {
    try {
      var response = await DioProvider().dio().delete('/create_order/delete',queryParameters: {"id" : id,"user_id" : userId});

      return Future.value(Orders.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //getByid
  static Future<Orders> getById({String id, String userid}) async {
    try {
      var response = await DioProvider()
          .dio()
          .get('create_order/info', queryParameters: {"id": id, "user_id":userid});

      return Future.value(Orders.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }


  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}