import '../../mock/mock_scenario.dart';

/// --dart-define 으로 주입되는 빌드 시점 값들.
///
/// const 라서 트리 셰이킹이 되고, 실서버 빌드에는 Mock 코드가 남지 않는다.
abstract final class Env {
  /// Mock 모드 여부. 백엔드가 붙기 전까지 기본값은 true 다.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: true,
  );

  /// 서버 주소. 기본값은 안드로이드 에뮬레이터에서 호스트 PC 의 loopback 이다.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/v1',
  );

  /// Mock 시나리오 이름. MockScenario 의 name 과 같은 문자열을 넣는다.
  static const String mockScenarioName = String.fromEnvironment(
    'MOCK_SCENARIO',
    defaultValue: 'normal',
  );

  static MockScenario get mockScenario =>
      MockScenario.fromName(mockScenarioName);
}
