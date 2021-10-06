class Melting {
  String name;

  bool checked;

  Melting({
    this.name,
    this.checked = false,
  });

  factory Melting.fromJson(dynamic parsedJson) {
    return Melting(
      name: parsedJson.toString(),
    );
  }

  static List<Melting> listFromJson(List<dynamic> list) {
    List<Melting> rows = list.map((i) => Melting.fromJson(i)).toList();
    return rows;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
      };
}
