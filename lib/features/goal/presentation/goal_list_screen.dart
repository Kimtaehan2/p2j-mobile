import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import 'goal_provider.dart';
import 'widgets/goal_card.dart';

/// 목표 목록.
///
/// 목표 상세는 이번 범위 밖이라 리스트만 만든다.
class GoalListScreen extends ConsumerWidget {
  const GoalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(activeGoalsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('목표')),
      body: goals.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(activeGoalsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.flag_rounded,
              title: '진행 중인 목표가 없어요',
              description: '이루고 싶은 걸 말하면\n주 단위 계획으로 만들어 드릴게요.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              AppSpacing.s20,
              AppSpacing.screenH,
              AppSpacing.s40,
            ),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.s12),
            itemBuilder: (context, index) => GoalCard(goal: items[index]),
          );
        },
      ),
    );
  }
}
