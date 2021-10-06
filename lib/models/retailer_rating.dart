import 'dart:convert';

import 'package:sonaar_retailer/models/wholesaler_firm.dart';

class RetailerRating {
  String id;
  String wholesalerFirmId;
  String name;
  String mobile;
  String review;
  String imageUrl;
  String thumbUrl;
  String createdAt;
  WholesalerFirm wholesalerFirm;

  RetailerRating({
    this.id,
    this.wholesalerFirmId,
    this.name,
    this.mobile,
    this.review,
    this.imageUrl,
    this.thumbUrl,
    this.createdAt,
    this.wholesalerFirm,
  });

  factory RetailerRating.fromJson(Map<String, dynamic> parsedJson) {
    return RetailerRating(
      id: parsedJson['id']?.toString(),
      wholesalerFirmId: parsedJson['wholesaler_firm_id']?.toString(),
      name: parsedJson['name']?.toString(),
      mobile: parsedJson['mobile']?.toString(),
      review: parsedJson['review']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      wholesalerFirm: parsedJson['wholesaler_firm'] == null
          ? null
          : WholesalerFirm.fromJson(parsedJson['wholesaler_firm']),
    );
  }

  static List<RetailerRating> listFromJson(List<dynamic> list) {
    List<RetailerRating> rows =
        list.map((i) => RetailerRating.fromJson(i)).toList();
    return rows;
  }

  static List<RetailerRating> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<RetailerRating>((json) => RetailerRating.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wholesaler_firm_id': wholesalerFirmId,
        'name': name,
        'mobile': mobile,
        'review': review,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
        'createdAt': createdAt,
        'wholesaler_firm': wholesalerFirm,
      };
}
