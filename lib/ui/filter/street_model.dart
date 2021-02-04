class StreetModel {
  final String ruasJalan;

  StreetModel({this.ruasJalan});

  factory StreetModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return StreetModel(
      ruasJalan: json["ruasJalan"] == null ? null : json["ruasJalan"]
    );
  }

  static List<StreetModel> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => StreetModel.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.ruasJalan} ${this.ruasJalan}';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(StreetModel model) {
    return this?.ruasJalan == model?.ruasJalan;
  }

  @override
  String toString() => ruasJalan;
}
