import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

/// 이번 실행에서 인트로를 벗어났는지.
///
/// 기기에 남기지 않는다. 계정이 없는 사용자는 앱을 켤 때마다 인트로를 다시
/// 본다. 로그인을 마치면 자동 로그인이 인트로를 건너뛴다.
@Riverpod(keepAlive: true)
class OnboardingDone extends _$OnboardingDone {
  @override
  bool build() => false;

  /// 로그인 화면으로 빠져나갈 때.
  void complete() => state = true;

  /// 로그인 화면에서 다시 가입하러 돌아올 때.
  void restart() => state = false;
}
