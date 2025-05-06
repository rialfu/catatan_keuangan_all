class AuthModel {
  String? token;
  String? refreshToken;
  String? name;
  AuthModel({this.token, this.refreshToken, this.name});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    String? newName;
    if (json.containsKey('name')) {
      newName = json['name'] as String;
    }
    return AuthModel(
      token: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      name: newName,
    );
  }
}
