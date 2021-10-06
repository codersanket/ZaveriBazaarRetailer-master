import 'dart:convert';

class BullionVendorRating {
  String id;
  String bullion_id;
  double ratting;
  String review;
  int recommend;
  String user_id;
  String created_at;
  String updated_at;

  BullionVendorRating({
    this.id,
    this.bullion_id,
    this.ratting,
    this.review,
    this.recommend,
    this.user_id,
    this.created_at,
    this.updated_at,
  });

  factory BullionVendorRating.fromJson(Map<String, dynamic> parsedJson) {
    return BullionVendorRating(
      id: parsedJson['id']?.toString(),
      bullion_id: parsedJson['bullion_id']?.toString(),
      ratting: double.parse(parsedJson['ratting']?.toString()),
      review: parsedJson['review']?.toString(),
      recommend: int.parse(parsedJson['recommend']?.toString()),
      user_id: parsedJson['user_id']?.toString(),
      created_at: parsedJson['created_at']?.toString(),
    );
  }

  static List<BullionVendorRating> listFromJson(List<dynamic> list) {
    List<BullionVendorRating> rows =
        list.map((i) => BullionVendorRating.fromJson(i)).toList();
    return rows;
  }

  static List<BullionVendorRating> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<BullionVendorRating>((json) => BullionVendorRating.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bullion_id': bullion_id,
        'ratting': ratting,
        'review': review,
        'recommend': recommend,
        'user_id': user_id,
        'created_at': created_at,
        'updated_at': updated_at,
      };
}
