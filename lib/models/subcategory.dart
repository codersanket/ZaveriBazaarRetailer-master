import 'dart:convert';

class Subcategory {
  String id;
  String categoryId;
  String name;
  String createdAt;
  String imageUrl;
  String thumbUrl;

  bool checked;

  Subcategory({
    this.id,
    this.categoryId,
    this.name,
    this.createdAt,
    this.imageUrl,
    this.thumbUrl,
    this.checked = false,
  });

  factory Subcategory.fromJson(Map<String, dynamic> parsedJson) {
    return Subcategory(
      id: parsedJson['id']?.toString(),
      categoryId: parsedJson['category_id']?.toString(),
      name: parsedJson['name']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
    );
  }

  static List<Subcategory> listFromJson(List<dynamic> list) {
    List<Subcategory> rows = list.map((i) => Subcategory.fromJson(i)).toList();
    return rows;
  }

  static List<Subcategory> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<Subcategory>((json) => Subcategory.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'name': name,
        'created_at': createdAt,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
      };
}
