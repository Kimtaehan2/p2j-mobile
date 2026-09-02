import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 요일·날짜를 한국어로 찍기 위해 로케일 데이터를 미리 로드한다.
  await initializeDateFormatting('ko_KR');
  runApp(
    ProviderScope(
      // Riverpod 3 은 provider 가 실패하면 기본으로 10회까지 지수 백오프 재시도한다.
      // 그동안 상태가 계속 로딩이라, 오프라인으로 앱을 켜면 스플래시에 갇힌다.
      // 재시도는 에러 화면의 '다시 시도' 버튼으로 사용자가 정하게 한다.
      retry: (retryCount, error) => null,
      child: const P2jApp(),
    ),
  );
}
