import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/user_contact.dart';

class UserContactService {
  /// Get all contacts
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response = await DioProvider()
          .dio()
          .get('/user-contacts', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Get contact by id
  static Future<UserContact> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/user-contacts/$id');

      return Future.value(UserContact.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Create contact
  static Future<UserContact> create(UserContact contact) async {
    try {
      var response =
          await DioProvider().dio().post('/user-contacts', data: contact);

      return Future.value(UserContact.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Sync contacts
  static Future<List<UserContact>> sync(
      List<UserContact> contacts, Function(int, int) onSendProgress) async {
    try {
      var response = await DioProvider().dio().post(
            '/user-contacts/sync',
            data: {'contacts': contacts},
            onSendProgress: onSendProgress,
          );

      return Future.value(UserContact.listFromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }


  //new get all for suggestions
  static Future<dynamic> getAllSuggestions(Map<String, dynamic> params) async {
    try {
      var response = await DioProvider()
          .dio()
          .post('/user-contacts/get_contacts_detail_new', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
