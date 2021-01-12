class SignUpRequest {
  String username;
  String password;
  String referral;
  String email;

  Map<String, String> reqBody() {
    Map<String, String> qParams = {
      'username': username,
      'password': password,
      'email': email,
      'referal': referral
    };
    return qParams;
  }

  SignUpRequest(this.username, this.password, this.referral, this.email);
}
