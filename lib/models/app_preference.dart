import 'dart:convert';

class AppPreference {
  String productWhatsapp;
  Map<String, dynamic> iOS;
  Map<String, dynamic> android;

  AppPreference({
    this.productWhatsapp,
    this.iOS,
    this.android,
  });

  factory AppPreference.fromJson(Map<String, dynamic> parsedJson) {
    return AppPreference(
      productWhatsapp: parsedJson['product_whatsapp']?.toString(),
      iOS: parsedJson['iOS'],
      android: parsedJson['android'],
    );
  }

  static List<AppPreference> listFromJson(List<dynamic> list) {
    List<AppPreference> rows =
        list.map((i) => AppPreference.fromJson(i)).toList();
    return rows;
  }

  static List<AppPreference> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<AppPreference>((json) => AppPreference.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'product_whatsapp': productWhatsapp,
        'iOS': iOS,
        'android': android,
      };
}
