enum AuthStatus { unknown, authenticated, guest, ssoRegister }

enum AuthError {
  hostUnreachable,
  unknown,
  wrongEmailOrPassword,
  wrongEmailOrPasswordBiometric,
  failedGoogleSSO,
}
