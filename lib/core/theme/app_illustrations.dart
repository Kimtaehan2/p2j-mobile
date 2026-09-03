/// 마스코트 일러스트 경로.
///
/// 화면마다 문자열을 적으면 오타를 컴파일러가 못 잡는다. 여기 한 곳에 모은다.
/// 2.0x / 3.0x / 4.0x 변형은 Flutter 가 화면 밀도에 맞춰 알아서 고른다.
abstract final class AppIllustrations {
  static const String _dir = 'assets/illustrations';

  /// 인사하는 기본 포즈. 인트로에서 쓴다.
  static const String mascot = 'assets/images/mascot.png';

  /// 수첩을 가리킨다. 오늘 할 일이 비었을 때.
  static const String todayTodo = '$_dir/02_today_todo.png';

  /// 목표 팻말을 들었다. 목표가 비었을 때.
  static const String goalAdd = '$_dir/03_goal_add.png';

  /// 마이크 앞에 앉았다. 음성 입력.
  static const String voiceInput = '$_dir/04_voice_input.png';

  /// 계획을 짜 준다. 인트로에서 약속하는 줄.
  static const String aiPlan = '$_dir/05_ai_plan.png';

  /// 쌓인 할 일과 시계. 계획이 버거울 때.
  static const String loadAdjust = '$_dir/06_load_adjust.png';

  /// 공유 팻말. 그룹.
  static const String groupShare = '$_dir/07_group_share.png';

  /// 트로피를 들었다. 다 끝냈을 때.
  static const String achievement = '$_dir/10_achievement_streak.png';
}
