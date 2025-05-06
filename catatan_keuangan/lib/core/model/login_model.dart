class LoginModel {
  String? email;
  String? password;
  String? name;

  LoginModel({
    this.email,
    this.password,
    this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toSaveJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }
}
