import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// 빈 상태 화면.
///
/// 신규 사용자가 처음 보는 화면이다. 안내가 아니라 행동 유도로 쓴다.
class EmptyView extends StatelessWidget {
  const EmptyView({
    required this.title,
    required this.description,
    this.icon = Icons.checklist_rounded,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accentSurface,
                borderRadius: BorderRadius.circular(AppRadius.r20),
              ),
              child: Icon(icon, color: AppColors.accent, size: 30),
            ),
            const SizedBox(height: AppSpacing.s24),
            Text(title, style: AppTypography.titleM, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.s8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(color: AppColors.muted),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s24),
              SizedBox(
                width: 200,
                child: FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
