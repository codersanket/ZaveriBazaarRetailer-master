import 'dart:convert';

import 'bullion_vendor_rating.dart';

class BullionVendor {
  String id;
  String firm_name;
  String mobile;
  String vendor_id;
  String address;
  String gst_no;
  String bank_name;
  String bank_acc_no;
  String bank_ifsc_code;
  String android_app_link;
  String ios_app_link;
  String website;
  String city_id;
  double gold_price_margin;
  double silver_price_margin;
  double estimated_gold_price;
  double estimated_silver_price;
  int is_gold_available;
  int is_silver_available;
  String created_at;
  String updated_at;
  double avg_rating;
  int sum_recommend;
  BullionVendorRating ratting_review_by_user;

  BullionVendor({
    this.id,
    this.firm_name,
    this.mobile,
    this.vendor_id,
    this.address,
    this.gst_no,
    this.bank_name,
    this.bank_acc_no,
    this.bank_ifsc_code,
    this.android_app_link,
    this.ios_app_link,
    this.website,
    this.city_id,
    this.gold_price_margin,
    this.silver_price_margin,
    this.estimated_gold_price,
    this.estimated_silver_price,
    this.is_gold_available,
    this.is_silver_available,
    this.created_at,
    this.updated_at,
    this.avg_rating,
    this.sum_recommend,
    this.ratting_review_by_user,
  });

  factory BullionVendor.fromJson(Map<String, dynamic> parsedJson) {
    return BullionVendor(
      id: parsedJson['id']?.toString(),
      firm_name: parsedJson['firm_name']?.toString(),
      mobile: parsedJson['mobile']?.toString(),
      vendor_id: parsedJson['vendor_id']?.toString(),
      address: parsedJson['address']?.toString(),
      gst_no: parsedJson['gst_no']?.toString(),
      bank_name: parsedJson['bank_name']?.toString(),
      bank_acc_no: parsedJson['bank_acc_no']?.toString(),
      bank_ifsc_code: parsedJson['bank_ifsc_code']?.toString(),
      android_app_link: parsedJson['android_app_link']?.toString(),
      ios_app_link: parsedJson['ios_app_link']?.toString(),
      website: parsedJson['website']?.toString(),
      city_id: parsedJson['city_id']?.toString(),
      gold_price_margin:
          double.parse(parsedJson['gold_price_margin'].toString()),
      silver_price_margin:
          double.parse(parsedJson['silver_price_margin'].toString()),
      estimated_gold_price:
          double.parse(parsedJson['estimated_gold_price'].toString()),
      estimated_silver_price:
          double.parse(parsedJson['estimated_silver_price'].toString()),
      is_gold_available: int.parse(parsedJson['is_gold_available'].toString()),
      is_silver_available:
          int.parse(parsedJson['is_silver_available'].toString()),
      created_at: parsedJson['created_at']?.toString(),
      updated_at: parsedJson['updated_at']?.toString(),
      avg_rating: double.parse(parsedJson['avg_rating'].toString()),
      sum_recommend: int.parse(parsedJson['sum_recommend'].toString()),
      ratting_review_by_user: parsedJson['ratting_review_by_user'] == null
          ? null
          : BullionVendorRating.fromJson(parsedJson['ratting_review_by_user']),
    );
  }

  static List<BullionVendor> listFromJson(List<dynamic> list) {
    List<BullionVendor> rows =
        list.map((i) => BullionVendor.fromJson(i)).toList();
    return rows;
  }

  static List<BullionVendor> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<BullionVendor>((json) => BullionVendor.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firm_name': firm_name,
        'mobile': mobile,
        'vendor_id': vendor_id,
        'address': address,
        'gst_no': gst_no,
        'bank_name': bank_name,
        'bank_acc_no': bank_acc_no,
        'bank_ifsc_code': bank_ifsc_code,
        'android_app_link': android_app_link,
        'ios_app_link': ios_app_link,
        'website': website,
        'city_id': city_id,
        'gold_price_margin': gold_price_margin,
        'silver_price_margin': silver_price_margin,
        'estimated_gold_price': estimated_gold_price,
        'estimated_silver_price': estimated_silver_price,
        'is_gold_available': is_gold_available,
        'is_silver_available': is_silver_available,
        'created_at': created_at,
        'updated_at': updated_at,
        'avg_rating': avg_rating,
        'sum_recommend': sum_recommend,
        'ratting_review_by_user': ratting_review_by_user != null
            ? ratting_review_by_user.toJson()
            : null,
      };
}
