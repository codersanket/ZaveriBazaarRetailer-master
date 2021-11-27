import 'dart:convert';

import 'package:sonaar_retailer/models/status.dart';
import 'package:sonaar_retailer/models/user.dart';

class Repairs{

  int id;
  int userId;
  String customerName;
  String customerNumber;
  String remark;
  int weight;
  int assignedStatus;
  String createdAt;
  String imageUrl;
  String thumbUrl;
  //Map<String, dynamic> statusDetails;
  Status statusDetails;
  String inwardDate;
  //User user;

  Repairs({
    this.id,
    this.userId,
    this.customerName,
    this.customerNumber,
    this.createdAt,
    this.imageUrl,
    this.thumbUrl,
    this.assignedStatus,
    this.statusDetails,
    this.remark,
    this.weight,
    this.inwardDate
  });

  factory Repairs.fromJson(Map<String, dynamic> parsedJson) => Repairs(
        id: parsedJson['id'],
        userId: parsedJson['user_id'],
        customerName: parsedJson['customer_name']?.toString(),
        customerNumber: parsedJson['customer_number']?.toString(),
        thumbUrl: parsedJson['thumb_url']?.toString(),
        imageUrl: parsedJson['image_url']?.toString(),
        statusDetails: parsedJson['assign_status_detail'] == null 
          ? null 
          : Status.fromJson(parsedJson['assign_status_detail']),
        weight: parsedJson['weight'],
        remark: parsedJson['remark'].toString(),
        createdAt: parsedJson['created_at'].toString(),
        assignedStatus: parsedJson['assign_status'],
        inwardDate: parsedJson['inward_date'].toString(),
      );

   Map<String, dynamic> toJson() => {
        'id': id,
        'user_id':userId,
        'customer_name': customerName,
        'customer_number': customerNumber,
        'thumb_url': thumbUrl,
        'image_url': imageUrl,
        'remark': remark,
        'weight': weight,
        "assign_status": assignedStatus,
        "created_at": createdAt,
        "inward_date": inwardDate,      
        "assign_status_detail": statusDetails.toJson(),  
      };

  static List<Repairs> listFromJson(List<dynamic> list) {
    List<Repairs> rows = list.map((i) => Repairs.fromJson(i)).toList();
    return rows;
  }

  static List<Repairs> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Repairs>((json) => Repairs.fromJson(json)).toList();
  }

}


