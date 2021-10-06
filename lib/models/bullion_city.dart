import 'dart:convert';

class BullionCity {
  String id;
  String name;
  String state;
  String created_at;
  String display_name;
  String rattings;
  double gold;
  double silver;

  BullionCity({
    this.id,
    this.name,
    this.state,
    this.created_at,
    this.display_name,
    this.rattings,
    this.gold,
    this.silver,
  });

  factory BullionCity.fromJson(Map<String, dynamic> parsedJson) {
    return BullionCity(
      id: parsedJson['id']?.toString(),
      name: parsedJson['name']?.toString(),
      state: parsedJson['state']?.toString(),
      created_at: parsedJson['created_at']?.toString(),
      display_name: parsedJson['display_name']?.toString(),
      rattings: parsedJson['rattings']?.toString(),
      gold: double.parse(parsedJson['gold'].toString()),
      silver: double.parse(parsedJson['silver'].toString()),
    );
  }

  static List<BullionCity> listFromJson(List<dynamic> list) {
    List<BullionCity> rows = list.map((i) => BullionCity.fromJson(i)).toList();
    return rows;
  }

  static List<BullionCity> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<BullionCity>((json) => BullionCity.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'created_at': created_at,
        'display_name': display_name,
        'rattings': rattings,
        'gold': gold,
        'silver': silver,
      };
}
