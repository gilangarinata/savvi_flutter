class UpdateLampRequest {
  String hardwareId;
  bool state;

  Map<String, String> reqBody() {
    Map<String, String> qParams = {
      'hardwareId': hardwareId,
      'lamp': state.toString(),
    };
    return qParams;
  }

  UpdateLampRequest(this.hardwareId, this.state);
}
