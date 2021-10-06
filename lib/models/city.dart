import 'dart:convert';

class City {
  String id;
  String name;
  String state;
  String createdAt;
  String displayName;

  bool checked;

  City({
    this.id,
    this.name,
    this.state,
    this.createdAt,
    this.displayName,
    this.checked = false,
  });

  factory City.fromJson(Map<String, dynamic> parsedJson) {
    return City(
      id: parsedJson['id']?.toString(),
      name: parsedJson['name']?.toString(),
      state: parsedJson['state']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      displayName: parsedJson['display_name']?.toString(),
    );
  }

  static List<City> listFromJson(List<dynamic> list) {
    List<City> rows = list.map((i) => City.fromJson(i)).toList();
    return rows;
  }

  static List<City> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<City>((json) => City.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'created_at': createdAt,
        'display_name': displayName,
      };
}
