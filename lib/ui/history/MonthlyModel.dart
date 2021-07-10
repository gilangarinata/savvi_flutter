
class MonthlyModel {
  final List<Data> data;

  MonthlyModel(
      {this.data});

  factory MonthlyModel.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return MonthlyModel(
        data: json["data"] == null ? null : Data.fromJsonList(json["data"])
    );
  }

  static MonthlyModel fromJsonObject(Object object) {
    if (object == null) return null;
    return MonthlyModel.fromJson(object);
  }
}

class Data {
  final String segment;
  final double kwhs;

  Data(
      {this.segment,
        this.kwhs});

  factory Data.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return Data(
        segment: json["segment"] == null ? null : json["segment"],
        kwhs: json["kwhs"] == null ? null : json["kwhs"].toDouble()
    );
  }

  static List<Data> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => Data.fromJson(item)).toList();
  }

}
