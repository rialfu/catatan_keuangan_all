class LoginSSOModel {
  String? password;
  String? name;
  String idToken;
  LoginSSOModel({required this.idToken, this.password, this.name});
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'token': idToken,
      'password': password,
    };
  }
}
