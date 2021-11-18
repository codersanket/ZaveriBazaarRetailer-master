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

  static List<Status> listFromJson(List<dynamic> list) {
    List<Status> rows = list.map((i) => Status.fromJson(i)).toList();
    return rows;
  }

  String getStatusName(){
    return statusName;
  }
  
  static List<Status> listOrderStatus(List<dynamic> list) {
    List<Status> rows = list.map((i) => Status.fromJson(i)).where((element) => element.createOrder=="1").toList();
    //List<String> data; 
    //rows.forEach((element) { data.add(element.getStatusName());});
    //return data;
    return rows;
  }

  static List<Status> listRepairStatus(List<dynamic> list) {
    List<Status> rows = list.map((i) => Status.fromJson(i)).where((element) => element.repairing=="1").toList();
    //List<String> data; 
    //rows.forEach((element) { data.add(element.getStatusName());});
    //return data;
    return rows;
  }
}