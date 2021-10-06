import 'dart:convert';

class WholesalerFirm {
  String id;
  String name;
  String mobile;
  String address;
  String pincode;
  String gst;
  String imageUrl;
  String thumbUrl;
  String qrImageUrl;
  String followId;
  List<String> marks;
  List<String> meltings;

  List<String> emailAddresses;
  List<String> icomNumbers;
  List<String> landlineNumbers;
  Map<String, dynamic> links;

  WholesalerFirm({
    this.id,
    this.name,
    this.mobile,
    this.address,
    this.pincode,
    this.gst,
    this.imageUrl,
    this.thumbUrl,
    this.qrImageUrl,
    this.followId,
    this.marks,
    this.meltings,
    this.emailAddresses,
    this.icomNumbers,
    this.landlineNumbers,
    this.links,
  });

  factory WholesalerFirm.fromJson(Map<String, dynamic> parsedJson) {
    return WholesalerFirm(
      id: parsedJson['id']?.toString(),
      name: parsedJson['name']?.toString(),
      mobile: parsedJson['mobile']?.toString(),
      address: parsedJson['address']?.toString(),
      pincode: parsedJson['pincode']?.toString(),
      gst: parsedJson['gst']?.toString(),
      imageUrl: parsedJson['image_url']?.toString(),
      thumbUrl: parsedJson['thumb_url']?.toString(),
      qrImageUrl: parsedJson['qr_image_url']?.toString(),
      followId: parsedJson['follow_id']?.toString(),
      marks: parsedJson['marks'] == null
          ? []
          : List<String>.from(parsedJson['marks']),
      meltings: parsedJson['meltings'] == null
          ? []
          : List<String>.from(parsedJson['meltings']),
      emailAddresses: parsedJson['email_addresses'] == null
          ? []
          : List<String>.from(parsedJson['email_addresses']),
      icomNumbers: parsedJson['icom_numbers'] == null
          ? []
          : List<String>.from(parsedJson['icom_numbers']),
      landlineNumbers: parsedJson['landline_numbers'] == null
          ? []
          : List<String>.from(parsedJson['landline_numbers']),
      links: parsedJson['links'],
    );
  }

  static List<WholesalerFirm> listFromJson(List<dynamic> list) {
    List<WholesalerFirm> rows =
        list.map((i) => WholesalerFirm.fromJson(i)).toList();
    return rows;
  }

  static List<WholesalerFirm> listFromString(String responseBody) {
    final parsed = json.decode(responseBody).cast<Map<String, dynamic>>();
    return parsed
        .map<WholesalerFirm>((json) => WholesalerFirm.fromJson(json))
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'address': address,
        'pincode': pincode,
        'gst': gst,
        'image_url': imageUrl,
        'thumb_url': thumbUrl,
        'qr_image_url': qrImageUrl,
        'marks': marks,
        'meltings': meltings,
        'follow_id': followId,
      };
}
