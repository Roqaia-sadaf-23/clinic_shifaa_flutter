import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../Error/Failure.dart';
import '../network/NetworkChecker .dart';
import 'AuthService.dart';

abstract class Either<L, R> {
  const Either();

  T fold<T>(T Function(L value) left, T Function(R value) right);

  bool get isLeft;
  bool get isRight;
}

class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(T Function(L value) left, T Function(R value) right) => left(value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;
}

class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(T Function(L value) left, T Function(R value) right) => right(value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;
}

class ApiService {
  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (auth) {
      final token = await AuthService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  bool _isSuccess(int statusCode) => statusCode >= 200 && statusCode < 300;

  dynamic _decodeSuccessBody(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } on FormatException {
      throw const FormatException('Invalid JSON response from the server.');
    }
  }

  Future<Either<Failure, dynamic>> _send(
    Future<http.Response> Function() request, {
    required bool auth,
  }) async {
    try {
      if (!await NetworkChecker.hasInternet()) {
        return const Left(NetworkFailure('No internet connection'));
      }

      var response = await request();
      if (response.statusCode == 401 && auth) {
        final refreshed = await AuthService.refreshAccessToken();
        if (!refreshed) {
          await AuthService.clearTokens();
          return const Left(
            ServerFailure('Session expired, please login again', statusCode: 401),
          );
        }
        response = await request();
      }

      return _parseResponse(response);
    } on SocketException {
      return const Left(NetworkFailure('Unable to reach the server.'));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('An unexpected server error occurred.'));
    }
  }

  Either<Failure, dynamic> _parseResponse(http.Response response) {
    if (_isSuccess(response.statusCode)) {
      try {
        return Right(_decodeSuccessBody(response.body));
      } on FormatException catch (error) {
        return Left(ServerFailure(error.message, statusCode: response.statusCode));
      }
    }

    return Left(_failureFromResponse(response));
  }

  Failure _failureFromResponse(http.Response response) {
    final statusCode = response.statusCode;
    final message = _backendMessage(response.body) ?? _defaultMessage(statusCode);
    return ServerFailure(message, statusCode: statusCode);
  }

  String? _backendMessage(String body) {
    if (body.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return null;

      final errors = decoded['errors'];
      if (errors is Map) {
        final messages = <String>[];
        for (final value in errors.values) {
          if (value is Iterable) {
            messages.addAll(value.map((item) => item.toString()));
          } else if (value != null) {
            messages.add(value.toString());
          }
        }
        if (messages.isNotEmpty) return messages.join('\n');
      }

      for (final field in ['message', 'error', 'title']) {
        final value = decoded[field];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  String _defaultMessage(int statusCode) {
    return switch (statusCode) {
      400 => 'Validation failed.',
      401 => 'Invalid credentials.',
      403 => 'You do not have permission to perform this action.',
      404 => 'The requested resource was not found.',
      409 => 'An account with these details already exists.',
      429 => 'Too many attempts. Please try again later.',
      500 => 'The server encountered an error. Please try again later.',
      _ => 'Request failed with status code $statusCode.',
    };
  }

  Future<Either<Failure, dynamic>> get(String url, {bool auth = false}) {
    return _send(
      () async => http.get(Uri.parse(url), headers: await _headers(auth: auth)),
      auth: auth,
    );
  }

  Future<Either<Failure, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) {
    return _send(
      () async => http.post(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(data),
      ),
      auth: auth,
    );
  }

  Future<Either<Failure, dynamic>> put(
    String url,
    Map<String, dynamic> data, {
    bool auth = false,
  }) {
    return _send(
      () async => http.put(
        Uri.parse(url),
        headers: await _headers(auth: auth),
        body: jsonEncode(data),
      ),
      auth: auth,
    );
  }

  Future<Either<Failure, dynamic>> delete(String url, {bool auth = false}) {
    return _send(
      () async => http.delete(Uri.parse(url), headers: await _headers(auth: auth)),
      auth: auth,
    );
  }

  Future<Either<Failure, dynamic>> uploadImage(
    String url,
    String imagePath, {
    bool auth = false,
  }) async {
    try {
      if (!await NetworkChecker.hasInternet()) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (auth) {
        final token = await AuthService.getAccessToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));

      final streamedResponse = await request.send();
      return _parseResponse(await http.Response.fromStream(streamedResponse));
    } on SocketException {
      return const Left(NetworkFailure('Unable to reach the server.'));
    } on FormatException catch (error) {
      return Left(ServerFailure(error.message));
    } catch (_) {
      return const Left(ServerFailure('Unable to upload the image.'));
    }
  }
}
