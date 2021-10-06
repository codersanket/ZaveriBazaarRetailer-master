import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonaar_retailer/dio_provider.dart';
import 'package:sonaar_retailer/models/error_handler.dart';
import 'package:sonaar_retailer/models/user.dart';

class AuthService {
  final BuildContext _context;

  static User user;

  AuthService(this._context);

  /// User signup
  static Future<User> signup(Map<String, dynamic> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String fcmToken = prefs.getString('fcmToken');

      data['fcm_token'] = fcmToken;
      data['role'] = "retailer";

      var response = await DioProvider().dio().post(
            '/users/signup',
            data: FormData.fromMap(data),
          );

      User user = User.fromJson(response.data);
      AuthService.setUser(user);

      return Future.value(user);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// User Quick signup
  static Future<User> quickSignup(Map<String, dynamic> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String fcmToken = prefs.getString('fcmToken');

      data['fcm_token'] = fcmToken;
      data['role'] = "retailer";

      var response = await DioProvider().dio().post(
            '/m/new-quick-register',
            data: FormData.fromMap(data),
          );

      /*User user = User.fromJson(response.data);
      AuthService.setUser(user);*/

      return Future.value(user);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Verify OTP
  static Future<User> verifyOTP(Map<String, dynamic> data) async {
    try {
      data['role'] = "retailer";

      var response = await DioProvider().dio().post(
            '/m/verify-otp-for-register',
            data: FormData.fromMap(data),
          );

      User user = User.fromJson(response.data);
      AuthService.setUser(user);

      return Future.value(user);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// User login
  static Future<User> login(String username, String password) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String fcmToken = prefs.getString('fcmToken');

      var response = await DioProvider().dio().post(
        '/users/login',
        data: {
          'role': "retailer",
          'username': username,
          'password': password,
          'fcm_token': fcmToken
        },
      );

      User user = User.fromJson(response.data);
      AuthService.setUser(user);

      return Future.value(user);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// User profile
  Future<User> profile() async {
    try {
      var response = await DioProvider().dio().get('/users/me');

      User user = User.fromJson(response.data);
      AuthService.setUser(user);

      return Future.value(user);
    } catch (e) {
      if (e is DioError &&
          e.type == DioErrorType.RESPONSE &&
          e.response.statusCode == 401) {
        Navigator.of(_context).pushNamedAndRemoveUntil('/login', (r) => false);
      }

      return Future.error(_handleError(e));
    }
  }

  /// Update own profile
  static Future<User> update(FormData formData) async {
    try {
      var response = await DioProvider().dio().post(
            '/users/me',
            data: formData,
          );

      user = User.fromJson(response.data);
      AuthService.setUser(user);

      return Future.value(user);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// User password update
  static Future<User> updatePassword(
      String oldPassword, String password) async {
    try {
      var response = await DioProvider().dio().post(
        '/users/me/password',
        data: {'password': oldPassword, 'new_password': password},
      );

      User user = User.fromJson(response.data);
      return Future.value(user);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// User reset password
  static Future<User> resetPassword(String username,
      {String otp, String password}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String fcmToken = prefs.getString('fcmToken');

      final data = {
        'role': "retailer",
        'username': username,
        'fcm_token': fcmToken
      };

      if (otp != null) {
        data['otp'] = otp;
        data['password'] = password;
      }

      var response = await DioProvider().dio().post(
            '/users/reset-password',
            data: data,
          );

      User user = User.fromJson(response.data);
      setUser(user);

      return Future.value(user);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  /// Tokens preference update
  static setUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', json.encode(user.toJson()));
    AuthService.user = user;
  }

  /// Tokens preference get
  static Future<User> getUser() async {
    if (AuthService.user == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      AuthService.user = User.fromJson(json.decode(prefs.getString('user')));
    }

    return AuthService.user;
  }

  /// Tokens preference update
  static updateTokens(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
  }

  /// Tokens preference get
  static Future<Map<String, String>> getTokens() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'accessToken': prefs.getString('accessToken'),
      'refreshToken': prefs.getString('refreshToken'),
    };
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null &&
        prefs.getString('refreshToken') != null;
  }

  /// Clear tokens and logout
  static logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
  }

  /// User sync contacts
  static Future<dynamic> syncContacts(
      List<Map<String, String>> contacts) async {
    try {
      var response =
          await DioProvider().dio().post('/contacts/multiple', data: contacts);

      return Future.value(response);
    } catch (e) {
      return Future.error(_handleError(e));
    }
  }

  static _handleError(e) {
    return ErrorHandler.handleError(e);
  }
}
