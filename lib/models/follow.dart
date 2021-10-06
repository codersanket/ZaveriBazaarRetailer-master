import 'dart:convert';

import 'package:sonaar_retailer/models/retailer.dart';
import 'package:sonaar_retailer/models/wholesaler_firm.dart';

class Follow {
  String id;
  String followedId;
  String followerId;
  bool accepted;
  String createdAt;
  WholesalerFirm followed;
  Retailer follower;

  Follow({
    this.id,
    this.followedId,
    this.followerId,
    this.accepted,
    this.createdAt,
    this.followed,
    this.follower,
  });

  factory Follow.fromJson(Map<String, dynamic> parsedJson) {
    return Follow(
      id: parsedJson['id']?.toString(),
      followedId: parsedJson['followed_id']?.toString(),
      followerId: parsedJson['follower_id']?.toString(),
      accepted: parsedJson['accepted'],
      createdAt: parsedJson['created_at']?.toString(),
      followed: parsedJson['followed'] == null
          ? null
          : WholesalerFirm.fromJson(parsedJson['followed']),
      follower: parsedJson['follower'] == null
          ? null
          : Retailer.fromJson(parsedJson['follower']),
    );
  }

  static List<Follow> listFromJson(List<dynamic> list) {
    List<Follow> rows = list.map((i) => Follow.fromJson(i)).toList();
    return rows;
  }

  static List<Follow> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Follow>((json) => Follow.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'followed_id': followedId,
        'follower_id': followerId,
        'accepted': accepted,
        'createdAt': createdAt,
        'followed': followed,
        'follower': follower,
      };
}
