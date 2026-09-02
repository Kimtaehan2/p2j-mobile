import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

/// 인증 엔드포인트 호출만 담당한다. 토큰 저장 같은 부수효과는 없다.
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<AuthSession> signup({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final response = await _client.post(
      '/auth/signup',
      data: <String, dynamic>{
        'email': email,
        'password': password,
        'nickname': nickname,
      },
    );
    return ApiResponse.object(response, AuthSession.fromJson).data;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      data: <String, dynamic>{'email': email, 'password': password},
    );
    return ApiResponse.object(response, AuthSession.fromJson).data;
  }

  Future<User> fetchMe() async {
    final response = await _client.get('/auth/me');
    return ApiResponse.object(response, User.fromJson).data;
  }

  Future<void> logout() => _client.post('/auth/logout');
}
