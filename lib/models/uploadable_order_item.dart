import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class UploadableItem{
  final String name;
  final String melting;
  final String size;
  final String weight;
  final Asset image1;
  String remark1;

  UploadableItem({
    this.name,
    this.melting,
    this.size,
    this.weight,
    this.image1,
    this.remark1
  });

   Map<String, dynamic> toJson() => {
        'name': name,
        'melting': melting,
        'size': size,
        'weignt': weight,
      };

}