import 'dart:convert';

class ProductType {
  String id;
  String name;
  String createdAt;
  String imageUrl;
  String thumbUrl;

  bool checked;

  ProductType({
    this.id,
    this.name,
    this.createdAt,
    this.imageUrl,
    this.thumbUrl,
    this.checked = false,
  });

  factory ProductType.fromJson(Map<String, dynamic> parsedJson) {
    return ProductType(
      id: parsedJson['id']?.toString(),
      name: parsedJson['name']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
    );
  }

  static List<ProductType> listFromJson(List<dynamic> list) {
    List<ProductType> rows = list.map((i) => ProductType.fromJson(i)).toList();
    return rows;
  }

  static List<ProductType> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<ProductType>((json) => ProductType.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'created_at': createdAt,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
      };
}
