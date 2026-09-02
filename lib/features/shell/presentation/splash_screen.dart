import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/error_view.dart';
import '../../auth/presentation/auth_controller.dart';

/// 저장된 토큰으로 자동 로그인을 판정하는 동안 보이는 화면.
///
/// 판정이 실패하면(대개 오프라인) 여기서 에러와 재시도를 보여준다.
/// 로그인 화면으로 보내면 사용자는 로그아웃된 줄 안다.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);

    if (auth.hasError) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ErrorView(
                  error: auth.error!,
                  onRetry: () => ref.invalidate(authControllerProvider),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s24),
                child: TextButton(
                  onPressed: () =>
                      ref.read(authControllerProvider.notifier).logout(),
                  child: Text(
                    '다른 계정으로 로그인',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(AppRadius.r20),
              ),
              alignment: Alignment.center,
              child: Text(
                'P2J',
                style: AppTypography.titleM.copyWith(color: AppColors.espresso),
              ),
            ),
            const SizedBox(height: AppSpacing.s20),
            Text(
              '오늘 할 일을 불러오는 중',
              style: AppTypography.caption.copyWith(
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
