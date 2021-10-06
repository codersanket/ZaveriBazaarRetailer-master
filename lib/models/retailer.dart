import 'dart:convert';

class Retailer {
  String id;
  String name;
  String mobile;
  String thumbUrl;
  String imageUrl;

  Retailer({
    this.id,
    this.name,
    this.mobile,
    this.thumbUrl,
    this.imageUrl,
  });

  factory Retailer.fromJson(Map<String, dynamic> parsedJson) => Retailer(
        id: parsedJson['id']?.toString(),
        name: parsedJson['name']?.toString(),
        mobile: parsedJson['mobile']?.toString(),
        thumbUrl: parsedJson['thumb_url']?.toString(),
        imageUrl: parsedJson['image_url']?.toString(),
      );

  static List<Retailer> listFromJson(List<dynamic> list) {
    List<Retailer> rows = list.map((i) => Retailer.fromJson(i)).toList();
    return rows;
  }

  static List<Retailer> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Retailer>((json) => Retailer.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'thumb_url': thumbUrl,
        'image_url': imageUrl,
      };
}
