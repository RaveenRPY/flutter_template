class Data {
  final String? code;
  final String? description;

  Data({
    this.code,
    this.description,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    code: json["code"],
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "description": description,
  };
}