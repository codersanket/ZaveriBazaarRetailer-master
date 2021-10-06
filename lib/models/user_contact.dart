import 'dart:convert';

class UserContact {
  String id;
  String userId;
  String deviceId;
  String name;
  String mobile;
  String createdAt;
  bool canFollow;
  bool canInvite;
  bool canRate;

  UserContact({
    this.id,
    this.userId,
    this.deviceId,
    this.name,
    this.mobile,
    this.createdAt,
    this.canFollow = false,
    this.canInvite = true,
    this.canRate = true,
  });

  factory UserContact.fromJson(Map<String, dynamic> parsedJson) {
    return UserContact(
      id: parsedJson['id']?.toString(),
      userId: parsedJson['user_id']?.toString(),
      deviceId: parsedJson['device_id']?.toString(),
      name: parsedJson['name']?.toString(),
      mobile: parsedJson['mobile']?.toString(),
      createdAt: parsedJson['created_at']?.toString(),
      canFollow: parsedJson['can_follow'],
      canInvite: parsedJson['can_invite'],
      canRate: parsedJson['can_rate'],
    );
  }

  static List<UserContact> listFromJson(List<dynamic> list) {
    List<UserContact> rows = list.map((i) => UserContact.fromJson(i)).toList();
    return rows;
  }

  static List<UserContact> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<UserContact>((json) => UserContact.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'device_id': deviceId,
        'name': name,
        'mobile': mobile,
        'created_at': createdAt,
        'can_follow': canFollow,
        'can_invite': canInvite,
        'can_rate': canRate,
      };
}
