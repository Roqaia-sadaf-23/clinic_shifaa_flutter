class TokenModel {
  final bool isSuccess;
  final String accessToken;
  final String refreshToken;
  final String roleName;

  final String? message;

  const TokenModel({
    required this.isSuccess,
    required this.accessToken,
    required this.refreshToken,
    required this.roleName,
    this.message,
  });

  factory TokenModel.fromJson(Map<String, dynamic> json) {
    return TokenModel(
      isSuccess: json['isSuccess'] == true,
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      roleName: json['roleName']?.toString() ?? '',
      message: json['message']?.toString(),
    );
  }
}
