import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/shine_progress_bar.dart';
import '../../../../core/widgets/sunburst.dart';
import '../../data/todo_models.dart';

/// 오늘의 달성률.
///
/// 화면에서 유일하게 색이 꽉 찬 덩어리다. 뒤에서 빛살이 천천히 돌아
/// 숫자가 빛나 보인다. 성취를 보여주는 게 이 앱의 핵심이라 화려함은
/// 여기 한 곳에만 몰아 준다.
class AchievementHero extends StatelessWidget {
  const AchievementHero({required this.summary, super.key});

  final TodoSummary summary;

  @override
  Widget build(BuildContext context) {
    final rate = summary.achievementRate.clamp(0.0, 1.0);
    final percent = (rate * 100).round();
    final cleared = summary.total > 0 && summary.done == summary.total;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r20),
      child: Stack(
        children: [
          const Positioned.fill(child: Sunburst()),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.s24,
              AppSpacing.s24,
              AppSpacing.s24,
              AppSpacing.s20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  cleared ? '오늘 할 일을 다 끝냈어요' : '오늘의 달성률',
                  textAlign: TextAlign.center,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.onGoldMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.s4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      percent.toString(),
                      style: AppTypography.display.copyWith(
                        color: AppColors.onGold,
                      ),
                    ),
                    Text(
                      '%',
                      style: AppTypography.titleL.copyWith(
                        color: AppColors.onGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s20),
                ShineProgressBar(
                  value: rate,
                  trackColor: AppColors.goldLight,
                  fillColor: AppColors.onGoldFill,
                  stripeColor: AppColors.goldLight,
                ),
                const SizedBox(height: AppSpacing.s12),
                Row(
                  children: [
                    Text(
                      '${summary.total}개 중 ${summary.done}개 완료',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.onGoldMuted,
                      ),
                    ),
                    const Spacer(),
                    if (summary.totalEstimatedMinutes > 0)
                      Text(
                        '예상 ${summary.totalEstimatedMinutes}분',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.onGoldMuted,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
