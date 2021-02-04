class SignUpRequest {
  String username;
  String password;
  String referral;
  String email;
  String name;

  Map<String, String> reqBody() {
    Map<String, String> qParams = {
      'username': username,
      'password': password,
      'email': email,
      'referal': referral,
      'name' : name
    };
    return qParams;
  }

  SignUpRequest(this.username, this.password, this.referral, this.email, this.name);
}
