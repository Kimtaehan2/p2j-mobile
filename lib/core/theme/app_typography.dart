import 'package:flutter/material.dart';

/// P2J 디자인 토큰 — 타이포.
///
/// Pretendard 가변 폰트를 쓴다. 한글 자간과 숫자 균형이 시스템 폰트보다 낫다.
/// Flutter 는 가변 폰트에서 [TextStyle.fontWeight] 를 wght 축에 자동으로
/// 이어주지 않는다. 그래서 굵기마다 [FontVariation] 을 함께 지정한다.
/// 둘 중 하나만 쓰면 플랫폼에 따라 가짜 볼드가 나오거나 굵기가 무시된다.
///
/// 이 앱의 대담함은 색이 아니라 글자 크기에서 나온다. 제목과 숫자를 크고
/// 굵게 쓰고 나머지는 조용히 둔다. 한글 가독성을 위해 행간을 넉넉히 주고
/// 자간을 살짝 좁힌다. 숫자에는 tabular figures 를 걸어 값이 바뀔 때 폭이
/// 흔들리지 않게 한다.
abstract final class AppTypography {
  static const String fontFamily = 'Pretendard';

  static const List<FontVariation> _w500 = <FontVariation>[
    FontVariation('wght', 500),
  ];
  static const List<FontVariation> _w600 = <FontVariation>[
    FontVariation('wght', 600),
  ];
  static const List<FontVariation> _w700 = <FontVariation>[
    FontVariation('wght', 700),
  ];

  static const List<FontFeature> _tabular = <FontFeature>[
    FontFeature.tabularFigures(),
  ];

  /// 달성률 숫자 전용. 화면당 한 번만 쓴다.
  static const TextStyle display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 52,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
    height: 1.05,
    letterSpacing: -2,
    fontFeatures: _tabular,
  );

  /// 인트로처럼 한 화면에 한 문장만 두는 곳. 가운데 정렬해서 쓴다.
  static const TextStyle story = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
    height: 1.45,
    letterSpacing: -0.7,
  );

  /// 화면을 여는 질문. 한 화면에 하나만.
  static const TextStyle titleXL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
    height: 1.35,
    letterSpacing: -0.6,
  );

  /// 앱바 제목, 섹션 제목.
  static const TextStyle titleL = TextStyle(
    fontFamily: fontFamily,
    fontSize: 21,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
    height: 1.35,
    letterSpacing: -0.5,
  );

  /// 카드 제목.
  static const TextStyle titleM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    fontVariations: _w600,
    height: 1.4,
    letterSpacing: -0.35,
  );

  /// 본문, 투두 제목.
  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontVariations: _w500,
    height: 1.5,
    letterSpacing: -0.3,
  );

  /// 본문 강조, 버튼 라벨.
  static const TextStyle bodyStrong = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontVariations: _w600,
    height: 1.5,
    letterSpacing: -0.3,
  );

  /// 보조 설명, 메타 정보.
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontVariations: _w500,
    height: 1.45,
    letterSpacing: -0.2,
  );

  /// 배지, 요일, 작은 라벨.
  static const TextStyle label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    fontVariations: _w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  /// 중간 크기 수치.
  static const TextStyle numberM = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    fontVariations: _w700,
    height: 1,
    letterSpacing: -0.8,
    fontFeatures: _tabular,
  );
}
