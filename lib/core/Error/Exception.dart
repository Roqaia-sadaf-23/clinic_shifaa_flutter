class ServerException implements Exception {
  final String message;

  ServerException(this.message);
}

class CacheException implements Exception {
  final String message;

  CacheException([this.message = "An error occurred while accessing the cache."]);
}

class offlineException implements Exception {
  final String message;

  offlineException([this.message = "You are currently offline."]);
}

class NetworkException implements Exception {
  final String message;

  NetworkException([this.message = "An error occurred while accessing the network."]);
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException([this.message = "An error occurred while accessing the database."]);
}

class AuthenticationException implements Exception {
  final String message;

  AuthenticationException([this.message = "An error occurred while authenticating."]);
}

class ValidationException implements Exception {
  final String message;

  ValidationException([this.message = "An error occurred while validating the input."]);
}
