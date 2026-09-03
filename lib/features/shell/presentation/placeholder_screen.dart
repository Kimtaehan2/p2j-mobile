import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// 아직 만들지 않은 탭에 붙이는 화면.
///
/// 그룹·통계는 12~13주차, 11주차 작업이라 이번 범위가 아니다.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.title,
    required this.description,
    required this.imagePath,
    super.key,
  });

  final String title;
  final String description;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, height: 180, fit: BoxFit.contain),
              const SizedBox(height: AppSpacing.s16),
              Text('곧 만나요', style: AppTypography.titleM),
              const SizedBox(height: AppSpacing.s8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
