import 'dart:convert';

import 'package:sonaar_retailer/models/subcategory.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';

class Product {
  String id;
  String wholesalerFirmId;
  String categoryId;
  String brandId;
  String typeId;
  String melting;
  String weightRange;
  String tags;
  String mark;
  String createdAt;
  String imageUrl;
  String thumbUrl;
  String shareLink;
  String categoryName;
  String brandName;
  String typeName;
  bool bookmarked;
  WholesalerFirm firm;
  List<Subcategory> subcategories;

  Product({
    this.id,
    this.wholesalerFirmId,
    this.categoryId,
    this.brandId,
    this.typeId,
    this.melting,
    this.weightRange,
    this.tags,
    this.mark,
    this.createdAt,
    this.imageUrl,
    this.thumbUrl,
    this.shareLink,
    this.categoryName,
    this.brandName,
    this.typeName,
    this.firm,
    this.subcategories,
    this.bookmarked = false,
  });

  factory Product.fromJson(Map<String, dynamic> parsedJson) {
    return Product(
      id: parsedJson['id'].toString(),
      wholesalerFirmId: parsedJson['wholesaler_firm_id']?.toString(),
      categoryId: parsedJson['category_id']?.toString(),
      brandId: parsedJson['brand_id']?.toString(),
      typeId: parsedJson['type_id']?.toString(),
      melting: parsedJson['melting']?.toString(),
      weightRange: parsedJson['weight_range']?.toString(),
      tags: parsedJson['tags']?.toString(),
      mark: parsedJson['mark']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
      shareLink: parsedJson['share_link']?.toString(),
      categoryName: parsedJson['category_name']?.toString(),
      brandName: parsedJson['brand_name']?.toString(),
      typeName: parsedJson['type_name']?.toString(),
      bookmarked: parsedJson['bookmarked'],
      firm: parsedJson['firm'] == null
          ? null
          : WholesalerFirm.fromJson(parsedJson['firm']),
      subcategories: parsedJson['subcategories'] == null
          ? null
          : Subcategory.listFromJson(parsedJson['subcategories']),
    );
  }

  static List<Product> listFromJson(List<dynamic> list) {
    List<Product> rows = list.map((i) => Product.fromJson(i)).toList();
    return rows;
  }

  static List<Product> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Product>((json) => Product.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wholesaler_firm_id': wholesalerFirmId,
        'category_id': categoryId,
        'brand_id': brandId,
        'type_id': typeId,
        'melting': melting,
        'weight_range': weightRange,
        'tags': tags,
        'mark': mark,
        'created_at': createdAt,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
        'share_link': shareLink,
        'category_name': categoryName,
        'brand_name': brandName,
        'type_name': typeName,
        'bookmarked': bookmarked,
        'firm': firm != null ? firm.toJson() : null,
      };
}
