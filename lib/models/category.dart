import 'dart:convert';

class Category {
  String id;
  String name;
  String createdAt;
  String imageUrl;
  String thumbUrl;

  bool checked;

  Category({
    this.id,
    this.name,
    this.createdAt,
    this.imageUrl,
    this.thumbUrl,
    this.checked = false,
  });

  factory Category.fromJson(Map<String, dynamic> parsedJson) {
    return Category(
      id: parsedJson['id']?.toString(),
      name: parsedJson['name']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
    );
  }

  static List<Category> listFromJson(List<dynamic> list) {
    List<Category> rows = list.map((i) => Category.fromJson(i)).toList();
    return rows;
  }

  static List<Category> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Category>((json) => Category.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
      };
}
