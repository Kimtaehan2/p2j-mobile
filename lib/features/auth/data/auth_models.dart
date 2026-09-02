import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_models.freezed.dart';
part 'auth_models.g.dart';

/// 사용자 정보.
///
/// 로그인/회원가입 응답의 `user` 객체와 `GET /auth/me` 의 `data` 가 완전히
/// 같은 형태라서 모델을 하나만 둔다.
@freezed
abstract class User with _$User {
  const factory User({
    required int userId,
    required String nickname,
    // 서버가 판단한 오늘. 하루의 경계가 04:00 KST 라 클라이언트가 계산하지 않는다.
    required String today,
    String? profileImageUrl,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// 로그인/회원가입 응답.
///
/// 토큰과 사용자 정보가 함께 온다. 그래서 로그인 직후 /auth/me 를 다시 부르지
/// 않는다.
@freezed
abstract class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String refreshToken,
    required User user,
    String? tokenType,
    int? expiresIn,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}
