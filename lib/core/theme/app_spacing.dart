/// P2J 디자인 토큰 — 스페이싱. 4의 배수만 쓴다.
///
/// 이름이 곧 값이라 헷갈릴 여지가 없다.
abstract final class AppSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;

  /// 화면 좌우 기본 여백.
  static const double screenH = s20;
}

/// P2J 디자인 토큰 — 라운드.
///
/// 위계에 따라 다르게 준다. 모든 요소를 같은 라운드 카드에 넣지 않는다.
abstract final class AppRadius {
  /// 배지, 체크박스, 작은 칩.
  static const double r8 = 8;

  /// 일반 카드, 입력 필드, 버튼.
  static const double r12 = 12;

  /// 히어로 블록(달성률 카드), 바텀시트.
  static const double r20 = 20;

  /// 완전한 알약 모양.
  static const double pill = 999;
}
