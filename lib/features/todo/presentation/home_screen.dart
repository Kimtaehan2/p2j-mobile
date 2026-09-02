import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/presentation/auth_controller.dart';
import 'todo_provider.dart';
import 'widgets/add_todo_sheet.dart';
import 'widgets/day_todo_list.dart';
import 'widgets/week_strip.dart';

/// 홈 — 오늘의 투두.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(serverTodayProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final week = ref.watch(weekAchievementsProvider);

    if (today == null || selectedDate.isEmpty) {
      return const Scaffold(body: LoadingView());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_title(selectedDate, today)),
        actions: [
          IconButton(
            tooltip: '로그아웃',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          ),
          const SizedBox(width: AppSpacing.s8),
        ],
      ),
      body: Column(
        children: [
          week.when(
            loading: () => const SizedBox(height: 82),
            error: (_, __) => const SizedBox(height: 82),
            data: (days) => WeekStrip(
              days: days,
              selectedDate: selectedDate,
              today: today,
              onSelect: (date) =>
                  ref.read(selectedDateProvider.notifier).select(date),
            ),
          ),
          Expanded(child: DayTodoList(date: selectedDate)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.ink,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () => _addTodo(context, ref, selectedDate),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  String _title(String selectedDate, String today) {
    if (selectedDate == today) return '오늘';
    final parsed = DateTime.tryParse(selectedDate);
    if (parsed == null) return selectedDate;
    return DateFormat('M월 d일 (E)', 'ko_KR').format(parsed);
  }

  Future<void> _addTodo(
    BuildContext context,
    WidgetRef ref,
    String date,
  ) async {
    final input = await AddTodoSheet.show(context);
    if (input == null) return;

    try {
      await ref.read(dayTodosControllerProvider(date).notifier).add(
            title: input.title,
            estimatedMinutes: input.estimatedMinutes,
          );
    } on ApiException catch (error) {
      if (!context.mounted) return;
      AppSnackBar.error(context, error.message);
    }
  }
}
