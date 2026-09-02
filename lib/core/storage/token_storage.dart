import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 액세스/리프레시 토큰 저장소.
///
/// 이 앱에서 기기에 남기는 유일한 데이터다. 로컬 DB 는 쓰지 않는다.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  static const String _accessKey = 'p2j_access_token';
  static const String _refreshKey = 'p2j_refresh_token';

  final FlutterSecureStorage _storage;

  // 요청마다 secure storage 를 읽으면 느리다. 메모리에 캐시한다.
  String? _accessCache;
  String? _refreshCache;
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _accessCache = await _storage.read(key: _accessKey);
    _refreshCache = await _storage.read(key: _refreshKey);
    _loaded = true;
  }

  Future<String?> readAccessToken() async {
    await _ensureLoaded();
    return _accessCache;
  }

  Future<String?> readRefreshToken() async {
    await _ensureLoaded();
    return _refreshCache;
  }

  Future<bool> hasSession() async => await readAccessToken() != null;

  Future<void> save({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessCache = accessToken;
    _refreshCache = refreshToken;
    _loaded = true;
    await _storage.write(key: _accessKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
  }

  Future<void> clear() async {
    _accessCache = null;
    _refreshCache = null;
    _loaded = true;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
