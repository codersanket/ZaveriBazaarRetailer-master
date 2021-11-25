import 'dart:convert';

import 'package:sonaar_retailer/models/status.dart';

class Orders {
  int id;
  int userId;
  String date;
  String customerName;
  String customerNumber;
  String deliveryDate;
  String visible;
  int status;
  String createdAt;
  List<OrderItem> orderItem;
  Status statusDetail;
  //UserDetail userDetail;

  Orders(
      {this.id,
      this.userId,
      this.date,
      this.customerName,
      this.customerNumber,
      this.deliveryDate,
      this.visible,
      this.status,
      this.createdAt,
      this.orderItem,
      this.statusDetail,
      //this.userDetail
      });

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    date = json['date'];
    customerName = json['customer_name'];
    customerNumber = json['customer_number'];
    deliveryDate = json['delivery_date'];
    visible = json['visible'];
    status = json['status'];
    createdAt = json['created_at'];
    if (json['order_item'] != null) {
      orderItem = new List<OrderItem>();
      json['order_item'].forEach((v) {
        orderItem.add(new OrderItem.fromJson(v));
      });
    }
    statusDetail = json['status_detail'] != null
        ? new Status.fromJson(json['status_detail'])
        : null;
    // userDetail = json['user_detail'] != null
    //     ? new UserDetail.fromJson(json['user_detail'])
    //     : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['date'] = this.date;
    data['customer_name'] = this.customerName;
    data['customer_number'] = this.customerNumber;
    data['delivery_date'] = this.deliveryDate;
    data['visible'] = this.visible;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    if (this.orderItem != null) {
      data['order_item'] = this.orderItem.map((v) => v.toJson()).toList();
    }
    if (this.statusDetail != null) {
      data['status_detail'] = this.statusDetail.toJson();
    }
    // if (this.userDetail != null) {
    //   data['user_detail'] = this.userDetail.toJson();
    // }
    return data;
  }

  static List<Orders> listFromJson(List<dynamic> list) {
    List<Orders> rows = list.map((i) => Orders.fromJson(i)).toList();
    return rows;
  }

  static List<Orders> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Orders>((json) => Orders.fromJson(json)).toList();
  }
}

class OrderItem {
  int id;
  String categoryType;
  String product;
  int createOrderId;
  String melting;
  int weight;
  int size;
  String image;
  String remark;
  String image2;
  String remark2;
  String image3;
  String remark3;
  String image4;
  String remark4;
  String createdAt;
  Null imageUrl;
  Null thumbUrl;
  Null image2Url;
  Null thumb2Url;
  Null image3Url;
  Null thumb3Url;
  Null image4Url;
  Null thumb4Url;

  OrderItem(
      {this.id,
      this.categoryType,
      this.product,
      this.createOrderId,
      this.melting,
      this.weight,
      this.size,
      this.image,
      this.remark,
      this.image2,
      this.remark2,
      this.image3,
      this.remark3,
      this.image4,
      this.remark4,
      this.createdAt,
      this.imageUrl,
      this.thumbUrl,
      this.image2Url,
      this.thumb2Url,
      this.image3Url,
      this.thumb3Url,
      this.image4Url,
      this.thumb4Url});

  OrderItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryType = json['category_type'];
    product = json['product'];
    createOrderId = json['create_order_id'];
    melting = json['melting'];
    weight = json['weight'];
    size = json['size'];
    image = json['image'];
    remark = json['remark'];
    image2 = json['image2'];
    remark2 = json['remark2'];
    image3 = json['image3'];
    remark3 = json['remark3'];
    image4 = json['image4'];
    remark4 = json['remark4'];
    createdAt = json['created_at'];
    imageUrl = json['image_url'];
    thumbUrl = json['thumb_url'];
    image2Url = json['image2_url'];
    thumb2Url = json['thumb2_url'];
    image3Url = json['image3_url'];
    thumb3Url = json['thumb3_url'];
    image4Url = json['image4_url'];
    thumb4Url = json['thumb4_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category_type'] = this.categoryType;
    data['product'] = this.product;
    data['create_order_id'] = this.createOrderId;
    data['melting'] = this.melting;
    data['weight'] = this.weight;
    data['size'] = this.size;
    data['image'] = this.image;
    data['remark'] = this.remark;
    data['image2'] = this.image2;
    data['remark2'] = this.remark2;
    data['image3'] = this.image3;
    data['remark3'] = this.remark3;
    data['image4'] = this.image4;
    data['remark4'] = this.remark4;
    data['created_at'] = this.createdAt;
    data['image_url'] = this.imageUrl;
    data['thumb_url'] = this.thumbUrl;
    data['image2_url'] = this.image2Url;
    data['thumb2_url'] = this.thumb2Url;
    data['image3_url'] = this.image3Url;
    data['thumb3_url'] = this.thumb3Url;
    data['image4_url'] = this.image4Url;
    data['thumb4_url'] = this.thumb4Url;
    return data;
  }

  static List<OrderItem> listFromJson(List<dynamic> list) {
    List<OrderItem> rows = list.map((i) => OrderItem.fromJson(i)).toList();
    return rows;
  }

  static List<OrderItem> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Orders>((json) => OrderItem.fromJson(json)).toList();
  }
}

