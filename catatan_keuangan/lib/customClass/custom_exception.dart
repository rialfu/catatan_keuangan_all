class CustomExceptionForPost implements Exception {
  int codeError;
  var cause;

  CustomExceptionForPost(this.codeError, this.cause);
}
