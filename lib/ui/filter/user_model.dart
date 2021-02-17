class UserModelNew {
  final String id;
  final DateTime createdAt;
  final String name;
  final String avatar;
  final String position;
  final String username;
  final String referal;
  final List<dynamic> referalFrom2;

  UserModelNew(
      {this.id,
      this.createdAt,
      this.name,
      this.avatar,
      this.position,
      this.username,
      this.referal,
      this.referalFrom2});

  factory UserModelNew.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return UserModelNew(
        id: json["_id"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        name: json["name"] == null ? "undefined" : json["name"],
        avatar: json["avatar"],
        username: json["username"],
        position: json["position"],
        referal: json["referal"] == null ? "undefined" : json["referal"],
        referalFrom2:
            json["referalFrom2"] == null ? "undefined" : json["referalFrom2"]);
  }

  static List<UserModelNew> fromJsonList(List list) {
    if (list == null) return null;
    return list.map((item) => UserModelNew.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#${this.id} ${this.name}';
  }

  ///this method will prevent the override of toString
  bool userFilterByCreationDate(String filter) {
    return this?.createdAt?.toString()?.contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(UserModelNew model) {
    return this?.id == model?.id;
  }

  @override
  String toString() => name;
}
