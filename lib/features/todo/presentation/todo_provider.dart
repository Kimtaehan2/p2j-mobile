import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/presentation/auth_controller.dart';
import '../data/todo_models.dart';
import '../data/todo_repository.dart';

part 'todo_provider.g.dart';

/// 홈에서 보고 있는 날짜.
///
/// 서버 기준 오늘이 바뀌면(04:00 KST 경계 통과) 선택도 오늘로 되돌아간다.
@Riverpod(keepAlive: true)
class SelectedDate extends _$SelectedDate {
  @override
  String build() => ref.watch(serverTodayProvider) ?? '';

  void select(String date) => state = date;
}

/// 특정 날짜의 투두 목록.
///
/// 완료 토글은 서버 응답을 기다리지 않고 즉시 반영한다. 체크박스가 0.5초
/// 멈춰 있으면 앱이 느리게 느껴진다. 실패하면 되돌리고 예외를 다시 던져서
/// 화면이 스낵바를 띄우게 한다.
@riverpod
class DayTodosController extends _$DayTodosController {
  @override
  Future<DayTodos> build(String date) =>
      ref.watch(todoRepositoryProvider).fetchDay(date);

  Future<void> toggle(Todo todo) async {
    final snapshot = state.value;
    if (snapshot == null) return;

    final willComplete = !todo.status.isDone;
    state = AsyncData(
      _recount(
        snapshot,
        snapshot.items
            .map(
              (e) => e.todoId == todo.todoId
                  ? e.copyWith(
                      status: willComplete
                          ? TodoStatus.done
                          : TodoStatus.pending,
                      rawStatus: willComplete ? 'done' : 'pending',
                    )
                  : e,
            )
            .toList(),
      ),
    );
    _syncWeek();

    try {
      if (willComplete) {
        final updated = await ref.read(todoRepositoryProvider).complete(
              todo.todoId,
            );
        final current = state.value;
        if (current == null) return;
        state = AsyncData(
          current.copyWith(
            items: current.items
                .map((e) => e.todoId == updated.todoId ? updated : e)
                .toList(),
          ),
        );
      } else {
        // 204 라 응답 바디가 없다. summary 는 로컬에서 이미 다시 셌다.
        await ref.read(todoRepositoryProvider).uncomplete(todo.todoId);
      }
    } catch (_) {
      state = AsyncData(snapshot);
      _syncWeek();
      rethrow;
    }
  }

  Future<void> add({required String title, int? estimatedMinutes}) async {
    final created = await ref.read(todoRepositoryProvider).create(
          title: title,
          date: date,
          estimatedMinutes: estimatedMinutes,
        );
    final snapshot = state.value;
    if (snapshot == null) return;
    state = AsyncData(_recount(snapshot, [...snapshot.items, created]));
    _syncWeek();
  }

  Future<void> remove(Todo todo) async {
    final snapshot = state.value;
    if (snapshot == null) return;

    state = AsyncData(
      _recount(
        snapshot,
        snapshot.items.where((e) => e.todoId != todo.todoId).toList(),
      ),
    );
    _syncWeek();

    try {
      await ref.read(todoRepositoryProvider).delete(todo.todoId);
    } catch (_) {
      state = AsyncData(snapshot);
      _syncWeek();
      rethrow;
    }
  }

  /// 목록이 바뀌면 summary 를 로컬에서 다시 센다.
  /// 서버 조회 결과의 summary 는 그대로 믿고, 낙관적 변경분만 여기서 반영한다.
  DayTodos _recount(DayTodos source, List<Todo> items) {
    final total = items.length;
    final done = items.where((e) => e.status.isDone).length;
    return source.copyWith(
      items: items,
      summary: source.summary.copyWith(
        total: total,
        done: done,
        achievementRate: total == 0 ? 0 : done / total,
        totalEstimatedMinutes: items.fold<int>(
          0,
          (sum, e) => sum + (e.estimatedMinutes ?? 0),
        ),
      ),
    );
  }

  /// 7일 스트립의 해당 칸도 같이 맞춘다. 재조회하면 스트립이 깜빡인다.
  void _syncWeek() {
    final summary = state.value?.summary;
    if (summary == null) return;
    ref
        .read(weekAchievementsProvider.notifier)
        .patch(date, total: summary.total, done: summary.done);
  }
}

/// 7일 달성률 스트립.
///
/// start_date 를 보내지 않으면 서버가 오늘-6일부터 7행을 항상 채워서 준다.
/// 빈 날짜를 클라이언트가 계산해 채우지 않는다.
@Riverpod(keepAlive: true)
class WeekAchievements extends _$WeekAchievements {
  @override
  Future<List<DayAchievement>> build() {
    // 오늘이 바뀌면 스트립도 다시 불러온다.
    ref.watch(serverTodayProvider);
    return ref.watch(todoRepositoryProvider).fetchWeek();
  }

  void patch(String date, {required int total, required int done}) {
    final days = state.value;
    if (days == null) return;
    state = AsyncData([
      for (final day in days)
        if (day.date == date)
          day.copyWith(
            total: total,
            done: done,
            achievementRate: total == 0 ? 0 : done / total,
          )
        else
          day,
    ]);
  }
}
