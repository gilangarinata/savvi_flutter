class AddDeviceRequest {
  String name;
  String description;
  String hardwareId;
  String userId;
  String ruasJalan;
  String referalRuasFrom;

  Map<String, String> reqBody() {
    Map<String, String> qParams = {
      'name': name,
      'description': description,
      'hardwareId': hardwareId,
      'userId': userId,
      'ruasJalan': ruasJalan,
      'referalRuasFrom': referalRuasFrom
    };
    return qParams;
  }

  AddDeviceRequest(this.name, this.description, this.hardwareId, this.userId,
      this.ruasJalan, this.referalRuasFrom);
}
