import 'dart:convert';

class GetLivePrice {
  double gold;
  double silver;

  GetLivePrice({this.gold, this.silver});

  factory GetLivePrice.fromJson(Map<String, dynamic> parsedJson) {
    return GetLivePrice(
      gold: double.parse(parsedJson['gold'].toString()),
      silver: double.parse(parsedJson['silver'].toString()),
    );
  }

  static List<GetLivePrice> listFromJson(List<dynamic> list) {
    List<GetLivePrice> rows =
        list.map((i) => GetLivePrice.fromJson(i)).toList();
    return rows;
  }

  static List<GetLivePrice> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<GetLivePrice>((json) => GetLivePrice.fromJson(json))
        .toList();
  }

  /*
  * get json for bullion request
  */
  Map<String, dynamic> toJson() => {
        'gold': gold,
        'silver': silver,
      };
}
