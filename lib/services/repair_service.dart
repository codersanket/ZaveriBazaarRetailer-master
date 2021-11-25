import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/repairs.dart';

class RepairService{

  //get all repairs
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/repairing', queryParameters: params);

      return Future.value(response.data);
    }
    catch (e) {
      return Future.error( _handleError(e));
    }
  }

  //create repair request
  static Future<Repairs> create(FormData formData) async {
    try {
      var response =
          await DioProvider().dio().post('/repairing/insert', data: formData);

      return Future.value(Repairs.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //update
   static Future<Repairs> update(FormData formData) async {
    try {
      var response = await DioProvider()
          .dio()
          .post('/repairing/update', data: formData);

      return Future.value(Repairs.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //delete
  static Future<Repairs> delete({String id, String userId}) async {
    try {
      var response = await DioProvider().dio().delete('/repairing/delete',queryParameters: {"id" : id,"user_id" : userId});

      return Future.value(Repairs.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

//search
  static Future<dynamic> search(Map<String, dynamic> params) async {
      try {
        var response =
            await DioProvider().dio().get('repairing/repairing_search', queryParameters: params);

        return Future.value(response.data);
      } catch (e) {
        return Future.error(_handleError(e));
      }
    }
  //getByid
  static Future<Repairs> getById(String id) async {
    try {
      var response = await DioProvider()
          .dio()
          .get('/repairing/info', queryParameters: {"id": id});

      return Future.value(Repairs.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
