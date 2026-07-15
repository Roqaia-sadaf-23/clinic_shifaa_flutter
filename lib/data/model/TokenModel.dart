class TokenModel {
  final bool isSuccess;
  final String accessToken;
  final String refreshToken;
  final String? message;

  const TokenModel({
    required this.isSuccess,
    required this.accessToken,
    required this.refreshToken,
    this.message,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      isSuccess: json['isSuccess'] as bool? ?? false,
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      message: json['message'] as String?,
    );
  }
}
