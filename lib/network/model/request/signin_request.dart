class SignInRequest {
  String username;
  String password;

  Map<String, String> reqBody() {
    Map<String, String> qParams = {
      'username': username,
      'password': password
    };
    return qParams;
  }

  SignInRequest(this.username, this.password);
}
