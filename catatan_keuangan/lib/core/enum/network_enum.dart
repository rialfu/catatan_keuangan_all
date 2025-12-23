enum NetworkEnums {
  loginurl('auth/login'),
  loginssourl('login-sso'),
  registerssourl('register-sso'),
  introOff('introOff'),
  token('token');

  final String path;
  const NetworkEnums(this.path);
}
