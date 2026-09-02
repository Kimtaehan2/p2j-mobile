import 'package:flutter/material.dart';

/// P2J 디자인 토큰 — 컬러.
///
/// Material 3 의 원칙을 따른다. 중립색(배경·표면·텍스트)을 강조색과 같은
/// 소스에서 뽑아 온도를 맞추고, 강조는 한 계열로 아껴 쓴다. 색이 세 갈래로
/// 흩어지면 어떤 요소도 위계를 못 만든다.
///
/// 이 앱의 강조는 **금색 하나**다. 성취를 보여주는 앱이고, 금은 그 뜻이
/// 설명 없이 읽히는 몇 안 되는 색이다. 대신 금은 밝은 면에서 대비가
/// 안 나오므로 톤을 둘로 나눠 쓴다 — 어두운 면엔 [gold], 밝은 면엔 [accent].
abstract final class AppColors {
  // --- 중립. 전부 웜(hue ~40) 계열이라 금색과 온도가 맞는다. ---

  /// 본문, 큰 숫자, 제목. 배경 위 대비 15:1.
  static const Color ink = Color(0xFF211D16);

  /// 눌러야 하는 본문. 목록 부제 등.
  static const Color inkSub = Color(0xFF4E463A);

  /// 보조 텍스트, 라벨. 배경 위 대비 4.7:1.
  static const Color muted = Color(0xFF756B5C);

  /// 비활성 텍스트, placeholder. 대비 기준 밖(비활성 요소는 예외).
  static const Color disabled = Color(0xFFADA394);

  /// 화면 배경. 순백이 아니라 흰 카드가 뜬다.
  static const Color background = Color(0xFFF4F1EA);

  /// 카드, 리스트, 바텀시트.
  static const Color surface = Color(0xFFFFFFFF);

  /// 옅은 채움. 입력 필드, 진행률 트랙, 배지.
  static const Color fill = Color(0xFFEBE6DB);

  /// 구분선.
  static const Color line = Color(0xFFE0DACE);

  // --- 어두운 면. 같은 웜 계열이라 배경과 한 몸으로 읽힌다. ---

  /// 달성률 블록과 인트로의 바탕. 청회색이 아니라 짙은 웜 브라운이다.
  static const Color espresso = Color(0xFF241E17);

  /// 어두운 면 위 본문. 대비 14.9:1.
  static const Color onEspresso = Color(0xFFF6F2EA);

  /// 어두운 면 위 보조 텍스트. 대비 6.2:1.
  static const Color onEspressoMuted = Color(0xFFA79C8A);

  /// 어두운 면 위 옅은 채움. 진행률 트랙, 선택지 버튼.
  static const Color espressoFill = Color(0xFF3A3126);

  // --- 강조. 금색 한 계열, 바탕 밝기에 따라 톤만 바꾼다. ---

  /// 어두운 면 위 금색. espresso 위 대비 10.3:1.
  static const Color gold = Color(0xFFF2C55C);

  /// 금색 위를 흐르는 옅은 노랑 줄무늬.
  static const Color goldPale = Color(0xFFFFE9A8);

  /// 달성률 카드의 바탕. 빛살이 뻗어 나오는 금색 면이다.
  static const Color goldBase = Color(0xFFEFC352);

  /// 바탕 가운데의 밝은 금색. 빛이 모이는 곳.
  static const Color goldLight = Color(0xFFF8DE8E);

  /// 회전하는 빛살. 바탕보다 밝은 연노랑.
  static const Color goldRay = Color(0xFFFFF4D2);

  /// 금색 면 위 큰 숫자. 대비 11.3:1.
  static const Color onGold = Color(0xFF2E2408);

  /// 금색 면 위 보조 텍스트. 대비 5.0:1.
  static const Color onGoldMuted = Color(0xFF61501A);

  /// 금색 면 위 진행률 채움. 트랙 대비 3.8:1.
  static const Color onGoldFill = Color(0xFF8A6A16);

  /// 밝은 면 위 금색. 흰 배경 대비 4.3:1 이라 그래픽 3:1 기준을 넘는다.
  /// 얇은 선이나 본문 텍스트에는 쓰지 않는다.
  static const Color accent = Color(0xFF9C7318);

  /// 강조 계열 옅은 채움.
  static const Color accentSurface = Color(0xFFF7EDD6);

  // --- 상태 ---

  /// 에러, 파괴적 액션. 흰 배경 대비 5.2:1.
  static const Color danger = Color(0xFFB3402C);

  /// 에러 배너 배경.
  static const Color dangerSurface = Color(0xFFFBEDE9);
}
