import 'dart:convert';

class Requirement {
  int id;
  int userId;
  String customerName;
  String customerNumber;
  String requirementOf;
  String jewelleryType;
  String productCategoryType;
  String image;
  String remark;
  String status;
  String createdAt;
  String imageUrl;
  String thumbUrl;
  //UserDetail userDetail;

  Requirement(
      {this.id,
      this.userId,
      this.customerName,
      this.customerNumber,
      this.requirementOf,
      this.jewelleryType,
      this.productCategoryType,
      this.image,
      this.remark,
      this.status,
      this.createdAt,
      this.imageUrl,
      this.thumbUrl,
      //this.userDetail
      });

  Requirement.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    customerName = json['customer_name'];
    customerNumber = json['customer_number'];
    requirementOf = json['requirement_of'];
    jewelleryType = json['jewellery_type'];
    productCategoryType = json['product_category_type'];
    image = json['image'];
    remark = json['remark'];
    status = json['status'];
    createdAt = json['created_at'];
    imageUrl = json['image_url'];
    thumbUrl = json['thumb_url'];
    //userDetail = json['user_detail'] != null
    //    ? new UserDetail.fromJson(json['user_detail'])
    //    : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['customer_name'] = this.customerName;
    data['customer_number'] = this.customerNumber;
    data['requirement_of'] = this.requirementOf;
    data['jewellery_type'] = this.jewelleryType;
    data['product_category_type'] = this.productCategoryType;
    data['image'] = this.image;
    data['remark'] = this.remark;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['image_url'] = this.imageUrl;
    data['thumb_url'] = this.thumbUrl;
    // if (this.userDetail != null) {
    //   data['user_detail'] = this.userDetail.toJson();
    // }
    return data;
  }

  static List<Requirement> listFromJson(List<dynamic> list) {
    List<Requirement> rows = list.map((i) => Requirement.fromJson(i)).toList();
    return rows;
  }

  static List<Requirement> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Requirement>((json) => Requirement.fromJson(json)).toList();
  }
}



