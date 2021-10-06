import 'dart:convert';

class Brand {
  String id;
  String name;
  String createdAt;
  String imageUrl;
  String thumbUrl;

  bool checked;

  Brand({
    this.id,
    this.name,
    this.createdAt,
    this.imageUrl,
    this.thumbUrl,
    this.checked = false,
  });

  factory Brand.fromJson(Map<String, dynamic> parsedJson) {
    return Brand(
      id: parsedJson['id']?.toString(),
      name: parsedJson['name']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
    );
  }

  static List<Brand> listFromJson(List<dynamic> list) {
    List<Brand> rows = list.map((i) => Brand.fromJson(i)).toList();
    return rows;
  }

  static List<Brand> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Brand>((json) => Brand.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
      };
}
