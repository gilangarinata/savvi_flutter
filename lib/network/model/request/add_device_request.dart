class AddDeviceRequest {
  String name;
  String description;
  String hardwareId;
  String userId;
  String ruasJalan;

  Map<String, String> reqBody() {
    Map<String, String> qParams = {
      'name': name,
      'description': description,
      'hardwareId': hardwareId,
      'userId': userId,
      'ruasJalan' : ruasJalan
    };
    return qParams;
  }

  AddDeviceRequest(this.name, this.description, this.hardwareId, this.userId, this.ruasJalan);
}
