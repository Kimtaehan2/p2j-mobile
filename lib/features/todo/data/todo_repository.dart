import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import 'todo_api.dart';
import 'todo_models.dart';

part 'todo_repository.g.dart';

/// 투두 저장소. 테스트에서 가짜 구현으로 갈아끼울 수 있게 인터페이스를 분리한다.
abstract interface class TodoRepository {
  Future<DayTodos> fetchDay(String date);

  Future<List<DayAchievement>> fetchWeek();

  Future<Todo> create({
    required String title,
    required String date,
    int? estimatedMinutes,
  });

  Future<Todo> updateTitle(int todoId, String title);

  Future<Todo> complete(int todoId);

  Future<void> uncomplete(int todoId);

  Future<void> delete(int todoId);
}

class TodoRepositoryImpl implements TodoRepository {
  const TodoRepositoryImpl(this._api);

  final TodoApi _api;

  @override
  Future<DayTodos> fetchDay(String date) => _api.fetchDay(date);

  @override
  Future<List<DayAchievement>> fetchWeek() => _api.fetchWeek();

  @override
  Future<Todo> create({
    required String title,
    required String date,
    int? estimatedMinutes,
  }) =>
      // 목표 선택 UI 는 이번 범위 밖이라 goal_id 는 항상 null 이다.
      _api.create(title: title, date: date, estimatedMinutes: estimatedMinutes);

  @override
  Future<Todo> updateTitle(int todoId, String title) =>
      _api.updateTitle(todoId, title);

  @override
  Future<Todo> complete(int todoId) => _api.complete(todoId);

  @override
  Future<void> uncomplete(int todoId) => _api.uncomplete(todoId);

  @override
  Future<void> delete(int todoId) => _api.delete(todoId);
}

@Riverpod(keepAlive: true)
TodoRepository todoRepository(Ref ref) =>
    TodoRepositoryImpl(TodoApi(ref.watch(apiClientProvider)));
