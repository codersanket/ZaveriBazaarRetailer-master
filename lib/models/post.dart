import 'dart:convert';

import 'package:sonaar_retailer/models/wholesaler_firm.dart';

class Post {
  String id;
  String wholesalerFirmId;
  String text;
  String createdAt;
  String imageUrl;
  String thumbUrl;
  String videoUrl;
  WholesalerFirm firm;

  Post({
    this.id,
    this.wholesalerFirmId,
    this.text,
    this.createdAt,
    this.imageUrl,
    this.thumbUrl,
    this.videoUrl,
    this.firm,
  });

  factory Post.fromJson(Map<String, dynamic> parsedJson) {
    return Post(
      id: parsedJson['id'].toString(),
      wholesalerFirmId: parsedJson['wholesaler_firm_id']?.toString(),
      text: parsedJson['text']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
      videoUrl: parsedJson['video_url']?.toString(),
      firm: parsedJson['firm'] == null
          ? null
          : WholesalerFirm.fromJson(parsedJson['firm']),
    );
  }

  static List<Post> listFromJson(List<dynamic> list) {
    List<Post> rows = list.map((i) => Post.fromJson(i)).toList();
    return rows;
  }

  static List<Post> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Post>((json) => Post.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'wholesaler_firm_id': wholesalerFirmId,
        'text': text,
        'firm': firm,
        'created_at': createdAt,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
        'video_url': videoUrl,
      };
}
