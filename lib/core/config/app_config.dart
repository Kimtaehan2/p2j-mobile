import '../../mock/mock_scenario.dart';
import 'env.dart';

/// 앱 전역 설정.
///
/// **실서버로 전환할 때 고쳐야 하는 파일은 여기 하나뿐이다.**
/// 화면 코드와 Repository 는 Mock 여부를 전혀 모른다.
abstract final class AppConfig {
  /// 운영 서버. 배포 빌드에서 --dart-define=API_BASE_URL 로 지정한다.
  static const String prodBaseUrl = 'https://api.p2j.dev/v1';

  static bool get useMock => Env.useMock;

  static MockScenario get mockScenario => Env.mockScenario;

  /// 전환은 --dart-define 으로만 한다. 이 파일을 고칠 일이 없다.
  static String get baseUrl => Env.apiBaseUrl;

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// 서버가 KST 기준으로 응답한다. 클라이언트는 날짜를 직접 계산하지 않는다.
  static const Duration kstOffset = Duration(hours: 9);
}
