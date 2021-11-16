class Status {
  int id;
  String statusName;
  String createOrder;
  String repairing;
  String createdAt;

  Status(
      {this.id,
      this.statusName,
      this.createOrder,
      this.repairing,
      this.createdAt});

  Status.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    statusName = json['status_name'];
    createOrder = json['create_order'];
    repairing = json['repairing'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['status_name'] = this.statusName;
    data['create_order'] = this.createOrder;
    data['repairing'] = this.repairing;
    data['created_at'] = this.createdAt;
    return data;
  }
}