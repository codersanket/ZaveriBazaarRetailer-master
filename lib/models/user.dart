import 'dart:convert';

import 'package:sonaar_retailer/models/app_preference.dart';

class User {
  String id;
  String name;
  String username;
  String mobile;
  String thumbUrl;
  String imageUrl;
  String retailerFirmName;
  String pincode;
  String cityId;
  String city;
  int approved;
  Map<String, dynamic> extras;

  AppPreference preference;

  User({
    this.id,
    this.name,
    this.username,
    this.mobile,
    this.thumbUrl,
    this.imageUrl,
    this.retailerFirmName,
    this.pincode,
    this.cityId,
    this.city,
    this.preference,
    this.extras,
    this.approved
  });

  factory User.fromJson(Map<String, dynamic> parsedJson) => User(
        id: parsedJson['id']?.toString(),
        name: parsedJson['name']?.toString(),
        username: parsedJson['username']?.toString(),
        mobile: parsedJson['mobile']?.toString(),
        thumbUrl: parsedJson['thumb_url']?.toString(),
        imageUrl: parsedJson['image_url']?.toString(),
        retailerFirmName: parsedJson['retailer_firm_name']?.toString(),
        pincode: parsedJson['pincode']?.toString(),
        cityId: parsedJson['city_id']?.toString(),
        city: parsedJson['city']?.toString(),
        extras: parsedJson['extras'],
        preference: parsedJson['app_preference'] == null
            ? null
            : AppPreference.fromJson(parsedJson['app_preference']),
        approved: parsedJson['approved'],
      );

  static List<User> listFromJson(List<dynamic> list) {
    List<User> rows = list.map((i) => User.fromJson(i)).toList();
    return rows;
  }

  static List<User> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'mobile': mobile,
        'thumb_url': thumbUrl,
        'image_url': imageUrl,
        'retailer_firm_name': retailerFirmName,
        'pincode': pincode,
        'city_id': cityId,
        'preference': preference,
        'approved': approved,
      };

  String getExtraValue(String key) {
    return extras != null &&
            extras.containsKey(key) &&
            extras[key] != null &&
            extras[key].toString().trim().length > 0
        ? extras[key].toString()
        : null;
  }
}
