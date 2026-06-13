import 'dart:convert';
import 'package:http/http.dart' as http;

import '../Error/Failure.dart';
import '../network/NetworkChecker .dart';
import 'AuthService.dart';

abstract class Either<L, R> {
  const Either();

  T fold<T>(T Function(L l) left, T Function(R r) right);

  bool get isLeft;
  bool get isRight;
}

class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L l) left, T Function(R r) right) => left(value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;
}

class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L l) left, T Function(R r) right) => right(value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;
}

class ApiService {
  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {"Content-Type": "application/json"};
    /* 
    if (auth) {
      final token = await AuthService.getAccessToken();

      if (token != null && token.isNotEmpty) {
        headers["Authorization"] = "Bearer $token";
      }
    } */

    return headers;
  }

  dynamic _decode(String body) {
    if (body.isEmpty) return null;
    return jsonDecode(body);
  }

  bool _isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) async {
    try {
      if (!await NetworkChecker.hasInternet()) {
        return Left(NetworkFailure("No internet connection"));
      }

      var response = await http.get(
        Uri.parse(url),
        headers: await _headers(auth: auth),
      );

      /*  if (response.statusCode == 401 && auth) {
        final refreshed = await AuthService.refreshAccessToken();

        if (refreshed) {
          response = await http.get(
            Uri.parse(url),
            headers: await _headers(auth: auth),
          );
        } else {
          await AuthService.clearTokens();
          return Left(ServerFailure("Session expired, please login again"));
        }
      } */

      if (_isSuccess(response.statusCode)) {
        return Right(_decode(response.body));
      }

      return Left(ServerFailure("Server error: ${response.statusCode}"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    try {
      if (!await NetworkChecker.hasInternet()) {
        return Left(NetworkFailure("No internet connection"));
      }

      var response = await http.post(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(data),
      );

      /*   if (response.statusCode == 401 && auth) {
        final refreshed = await AuthService.refreshAccessToken();

        if (refreshed) {
          response = await http.post(
            Uri.parse(url),
            headers: await _headers(auth: auth),
            body: jsonEncode(data),
          );
        } else {
          await AuthService.clearTokens();
          return Left(ServerFailure("Session expired, please login again"));
        }
      }
 */
      if (_isSuccess(response.statusCode)) {
        return Right(_decode(response.body));
      }

      return Left(ServerFailure("Server error: ${response.statusCode}"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> put(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) async {
    try {
      if (!await NetworkChecker.hasInternet()) {
        return Left(NetworkFailure("No internet connection"));
      }

      var response = await http.put(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(data),
      );

      /*     if (response.statusCode == 401 && auth) {
        final refreshed = await AuthService.refreshAccessToken();

        if (refreshed) {
          response = await http.put(
            Uri.parse(url),
            headers: await _headers(auth: auth),
            body: jsonEncode(data),
          );
        } else {
          await AuthService.clearTokens();
          return Left(ServerFailure("Session expired, please login again"));
        }
      } */

      if (_isSuccess(response.statusCode)) {
        return Right(_decode(response.body));
      }

      return Left(ServerFailure("Server error: ${response.statusCode}"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> delete(
    String url, {
    bool auth = false,
  }) async {
    try {
      if (!await NetworkChecker.hasInternet()) {
        return Left(NetworkFailure("No internet connection"));
      }

      var response = await http.delete(
        Uri.parse(url),
        headers: await _headers(auth: auth),
      );

      /*     if (response.statusCode == 401 && auth) {
        final refreshed = await AuthService.refreshAccessToken();

        if (refreshed) {
          response = await http.delete(
            Uri.parse(url),
            headers: await _headers(auth: auth),
          );
        } else {
          await AuthService.clearTokens();
          return Left(ServerFailure("Session expired, please login again"));
        }
      } */

      if (_isSuccess(response.statusCode)) {
        return Right(_decode(response.body));
      }

      return Left(ServerFailure("Server error: ${response.statusCode}"));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
