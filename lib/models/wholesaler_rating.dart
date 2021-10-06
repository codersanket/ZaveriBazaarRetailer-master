import 'dart:convert';

import 'package:sonaar_retailer/models/retailer.dart';

class WholesalerRating {
  String id;
  String retailerId;
  int rating;
  String name;
  String mobile;
  String review;
  String recommended;
  String imageUrl;
  String thumbUrl;
  String createdAt;
  Retailer retailer;
  bool canModify;

  WholesalerRating({
    this.id,
    this.retailerId,
    this.rating,
    this.name,
    this.mobile,
    this.review,
    this.recommended,
    this.canModify,
    this.imageUrl,
    this.thumbUrl,
    this.createdAt,
    this.retailer,
  });

  factory WholesalerRating.fromJson(Map<String, dynamic> parsedJson) {
    return WholesalerRating(
      id: parsedJson['id']?.toString(),
      retailerId: parsedJson['retailer_id']?.toString(),
      rating: int.tryParse(parsedJson['rating']?.toString()) ?? 0,
      name: parsedJson['name']?.toString(),
      mobile: parsedJson['mobile']?.toString(),
      review: parsedJson['review']?.toString(),
      recommended: parsedJson['recommended']?.toString(),
      canModify: parsedJson['can_modify'],
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      retailer: parsedJson['retailer'] == null
          ? null
          : Retailer.fromJson(parsedJson['retailer']),
    );
  }

  static List<WholesalerRating> listFromJson(List<dynamic> list) {
    List<WholesalerRating> rows =
        list.map((i) => WholesalerRating.fromJson(i)).toList();
    return rows;
  }

  static List<WholesalerRating> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<WholesalerRating>((json) => WholesalerRating.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'retailer_id': retailerId,
        'rating': rating,
        'name': name,
        'mobile': mobile,
        'review': review,
        'can_modify': canModify,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
        'createdAt': createdAt,
        'retailer': retailer,
      };
}
