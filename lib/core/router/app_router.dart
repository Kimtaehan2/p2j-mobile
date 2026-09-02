import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/data/auth_models.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/goal/presentation/goal_list_screen.dart';
import '../../features/onboarding/presentation/onboarding_provider.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/shell/presentation/main_shell.dart';
import '../../features/shell/presentation/placeholder_screen.dart';
import '../../features/shell/presentation/splash_screen.dart';
import '../../features/todo/presentation/home_screen.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// 앱 라우터.
///
/// 인증 게이트는 화면마다 두지 않고 redirect 한 곳에서만 판단한다.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  // GoRouter 는 Listenable 을 받으므로 인증 상태를 여기에 옮겨 담는다.
  final authState =
      ValueNotifier<AsyncValue<User?>>(const AsyncLoading<User?>());

  final onboardingState = ValueNotifier<bool>(false);

  ref.listen<AsyncValue<User?>>(
    authControllerProvider,
    (_, next) => authState.value = next,
    fireImmediately: true,
  );
  ref.listen<bool>(
    onboardingDoneProvider,
    (_, next) => onboardingState.value = next,
    fireImmediately: true,
  );

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: Listenable.merge([authState, onboardingState]),
    redirect: (context, state) {
      final auth = authState.value;
      final introDone = onboardingState.value;
      final location = state.matchedLocation;

      // 판정 중에는 스플래시를 유지한다.
      if (auth.isLoading) {
        return location == Routes.splash ? null : Routes.splash;
      }

      // 자동 로그인이 실패했을 때도 스플래시에 머문다. 실패는 대개 오프라인이라,
      // 로그인 화면으로 보내면 로그아웃된 것처럼 보인다.
      if (auth.hasError) {
        return location == Routes.splash ? null : Routes.splash;
      }

      final loggedIn = auth.value != null;
      final onAuthPage = location == Routes.login;

      if (loggedIn) {
        if (onAuthPage ||
            location == Routes.splash ||
            location == Routes.onboarding) {
          return Routes.home;
        }
        return null;
      }

      // 로그인하지 않았으면 켤 때마다 인트로부터 보여준다.
      if (!introDone) {
        return location == Routes.onboarding ? null : Routes.onboarding;
      }

      return onAuthPage ? null : Routes.login;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.goals,
                builder: (context, state) => const GoalListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.group,
                builder: (context, state) => const PlaceholderScreen(
                  title: '그룹',
                  description: '아침에 선언하고 저녁에 인증하는 그룹 기능은\n12주차에 열립니다.',
                  icon: Icons.groups_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.stats,
                builder: (context, state) => const PlaceholderScreen(
                  title: '통계',
                  description: '달성률 추이와 목표별 분석은\n11주차에 열립니다.',
                  icon: Icons.insights_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    authState.dispose();
    onboardingState.dispose();
  });

  return router;
}
