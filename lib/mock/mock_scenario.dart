/// Mock 응답 시나리오.
///
/// `--dart-define=MOCK_SCENARIO=emptyTodos` 처럼 지정한다.
/// 에러 화면과 빈 화면을 실제로 눈으로 확인하기 위한 스위치다.
enum MockScenario {
  /// 정상 응답.
  normal,

  /// 투두와 목표가 하나도 없는 신규 사용자. 빈 상태 화면을 본다.
  emptyTodos,

  /// 연결 실패. 에러 화면과 재시도 버튼을 본다.
  networkError,

  /// 500 응답.
  serverError,

  /// 로그인 후 첫 보호 요청이 401 TOKEN_EXPIRED 를 낸다.
  /// 재발급 1회 → 재시도 흐름을 확인한다.
  tokenExpired;

  static MockScenario fromName(String name) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return MockScenario.normal;
  }
}
