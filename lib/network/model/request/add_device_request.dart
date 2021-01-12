class AddDeviceRequest {
  String name;
  String description;
  String hardwareId;
  String userId;

  Map<String, String> reqBody() {
    Map<String, String> qParams = {
      'name': name,
      'description': description,
      'hardwareId': hardwareId,
      'userId': userId,
    };
    return qParams;
  }

  AddDeviceRequest(this.name, this.description, this.hardwareId, this.userId);
}
