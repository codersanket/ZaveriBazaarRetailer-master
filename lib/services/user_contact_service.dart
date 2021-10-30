import 'package:dio/dio.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/user_contact.dart';
import 'package:sonaar_retailer/services/Exception.dart';

class UserContactService {
  /// Get all contacts
  static Future<dynamic> getAll(Map<String, dynamic> params) async {
    try {
      var response = await DioProvider()
          .dio()
          .get('/user-contacts', queryParameters: params);

      return Future.value(response.data);
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Get all contacts', e.toString())));
    }
  }

  /// Get contact by id
  static Future<UserContact> getById(String id) async {
    try {
      var response = await DioProvider().dio().get('/user-contacts/$id');

      return Future.value(UserContact.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('get Contact by id', e.toString())));
    }
  }

  /// Create contact
  static Future<UserContact> create(UserContact contact) async {
    try {
      var response =
          await DioProvider().dio().post('/user-contacts', data: contact);

      return Future.value(UserContact.fromJson(response.data));
    } catch (e) {
      return Future.error(_handleError(UserException1.userException('Create contact', e.toString())));
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
      return Future.error(_handleError(UserException1.userException('Sync contact', e.toString())));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
