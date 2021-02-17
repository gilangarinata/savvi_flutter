class StreetModel {
  final String ruasJalan;
  final String referalFrom;
  final List<dynamic> referalFrom2;
  final String referalRuasFrom;

  StreetModel(
      {this.ruasJalan,
      this.referalFrom,
      this.referalFrom2,
      this.referalRuasFrom});

  factory StreetModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return StreetModel(
      ruasJalan: json["ruasJalan"] == null ? null : json["ruasJalan"],
      referalFrom: json["referalFrom"] == null ? null : json["referalFrom"],
      referalFrom2: json["referalFrom2"] == null ? null : json["referalFrom2"],
      referalRuasFrom:
          json["referalRuasFrom"] == null ? null : json["referalRuasFrom"],
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
