import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../storage/token_storage.dart';
import 'api_exception.dart';

/// 액세스 토큰 주입 + 401 재발급.
///
/// 핵심은 **동시 요청 큐잉**이다. 홈 화면은 /auth/me, /todos, /todos/week 를
/// 동시에 부른다. 토큰이 만료된 순간이면 셋 다 401 을 받는데, 그대로 두면
/// refresh 가 3번 나간다. 서버가 refresh 토큰 rotation 을 쓰면 첫 번째만
/// 성공하고 나머지 둘은 무효 토큰으로 죽는다.
/// 그래서 진행 중인 refresh 를 [_inFlightRefresh] 하나로 묶고, 늦게 온 요청은
/// 같은 Future 를 기다렸다가 새 토큰으로 재시도한다.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio refreshDio,
    required VoidCallback onSessionExpired,
  })  : _tokenStorage = tokenStorage,
        _refreshDio = refreshDio,
        _onSessionExpired = onSessionExpired;

  /// 재시도 요청을 흘려보낼 Dio. dio_client 에서 생성 직후 채운다.
  late final Dio retryDio;

  final TokenStorage _tokenStorage;
  final Dio _refreshDio;
  final VoidCallback _onSessionExpired;

  /// 재시도한 요청인지 표시. 무한 루프를 막는다.
  static const String _retriedKey = '__p2j_retried';

  /// 토큰을 붙이지 않고, 401 이 와도 재발급을 시도하지 않는 경로.
  static const Set<String> _publicPaths = <String>{
    '/auth/login',
    '/auth/signup',
    '/auth/refresh',
  };

  Future<String?>? _inFlightRefresh;

  bool _isPublic(String path) => _publicPaths.any(path.endsWith);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await _tokenStorage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    if (response?.statusCode != 401 || _isPublic(err.requestOptions.path)) {
      handler.next(err);
      return;
    }

    // 토큰을 붙여 보낸 요청만 재발급 대상이다.
    // Mock 모드에서는 MockInterceptor 가 먼저 응답을 만들어 헤더가 붙지 않으므로,
    // 저장된 토큰이 있는지도 함께 본다.
    final authenticatedRequest =
        err.requestOptions.headers.containsKey('Authorization') ||
            await _tokenStorage.readAccessToken() != null;
    if (!authenticatedRequest) {
      handler.next(err);
      return;
    }

    // 로그인 자격 오류는 재발급 대상이 아니다. 폼에 그대로 보여준다.
    if (_serverErrorCode(response) == ApiErrorCode.invalidCredentials.wire) {
      handler.next(err);
      return;
    }

    // 이미 한 번 재시도한 요청이면 여기서 끝낸다. 재발급은 1회만 시도한다.
    if (err.requestOptions.extra[_retriedKey] == true) {
      await _expireSession();
      handler.next(err);
      return;
    }

    final newToken = await _refreshOnce();
    if (newToken == null) {
      await _expireSession();
      handler.next(err);
      return;
    }

    try {
      final options = err.requestOptions
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra[_retriedKey] = true;
      handler.resolve(await retryDio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// 진행 중인 재발급이 있으면 그 결과를 같이 기다린다.
  Future<String?> _refreshOnce() {
    return _inFlightRefresh ??= _refresh().whenComplete(() {
      _inFlightRefresh = null;
    });
  }

  Future<String?> _refresh() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _refreshDio.post<dynamic>(
        '/auth/refresh',
        data: <String, dynamic>{'refresh_token': refreshToken},
      );
      final body = response.data;
      if (body is! Map) return null;
      final data = body['data'];
      if (data is! Map) return null;

      final accessToken = data['access_token'] as String?;
      if (accessToken == null) return null;

      await _tokenStorage.save(
        accessToken: accessToken,
        // 서버가 refresh 토큰도 새로 준다(rotation).
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
      );
      return accessToken;
    } on DioException {
      return null;
    }
  }

  Future<void> _expireSession() async {
    await _tokenStorage.clear();
    _onSessionExpired();
  }

  String? _serverErrorCode(Response<dynamic>? response) {
    final body = response?.data;
    if (body is Map && body['error'] is Map) {
      return (body['error'] as Map)['code'] as String?;
    }
    return null;
  }
}
