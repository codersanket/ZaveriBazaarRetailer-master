import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/requirement.dart';


class RequirementService{

  //get all repairs
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response =
          await DioProvider().dio().get('/requirement', queryParameters: params);

      return Future.value(response.data);
    }
    catch (e) {
      return Future.error( _handleError(e));
    }
  }

  //create repair request
  static Future<Requirement> create(FormData formData) async {
    try {
      var response =
          await DioProvider().dio().post('/requirement/insert', data: formData);

      return Future.value(Requirement.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //update
   static Future<Requirement> update(FormData formData) async {
    try {
      var response = await DioProvider()
          .dio()
          .post('/requirement/update', data: formData);

      return Future.value(Requirement.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //delete
  static Future<Requirement> delete({int id, int userId}) async {
    try {
      var response = await DioProvider().dio().delete('/requirement/delete',queryParameters: {"id" : id,"user_id" : userId});

      return Future.value(Requirement.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  //getByid
  static Future<Requirement> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/requirement/info',queryParameters: {"id" : id});

      return Future.value(Requirement.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }


  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}