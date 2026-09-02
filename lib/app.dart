import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_controller.dart';

class P2jApp extends ConsumerStatefulWidget {
  const P2jApp({super.key});

  @override
  ConsumerState<P2jApp> createState() => _P2jAppState();
}

class _P2jAppState extends ConsumerState<P2jApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onResume: _handleResume);
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  /// 백그라운드에서 돌아오면 서버 기준 '오늘'이 넘어갔는지 다시 확인한다.
  /// 하루의 경계가 04:00 KST 라 새벽에 앱을 켜둔 채로 날짜가 바뀔 수 있다.
  void _handleResume() {
    if (ref.read(authControllerProvider).value == null) return;
    unawaited(ref.read(authControllerProvider.notifier).refreshToday());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'P2J',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: ref.watch(goRouterProvider),
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
