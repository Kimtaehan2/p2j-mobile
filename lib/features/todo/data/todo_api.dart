import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'todo_models.dart';

class TodoApi {
  const TodoApi(this._client);

  final ApiClient _client;

  Future<DayTodos> fetchDay(String date) async {
    final response = await _client.get(
      '/todos',
      query: <String, dynamic>{'date': date},
    );
    return ApiResponse.object(response, DayTodos.fromJson).data;
  }

  /// start_date 를 넘기지 않으면 서버가 오늘-6일부터 7일을 준다.
  /// 클라이언트가 날짜를 계산하지 않기 위해 기본값을 그대로 쓴다.
  Future<List<DayAchievement>> fetchWeek({String? startDate}) async {
    final response = await _client.get(
      '/todos/week',
      query: startDate == null
          ? null
          : <String, dynamic>{'start_date': startDate},
    );
    return ApiResponse.list(response, DayAchievement.fromJson).data;
  }

  Future<Todo> create({
    required String title,
    required String date,
    int? estimatedMinutes,
    int? goalId,
  }) async {
    final response = await _client.post(
      '/todos',
      data: <String, dynamic>{
        'title': title,
        'date': date,
        if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
        if (goalId != null) 'goal_id': goalId,
      },
    );
    return ApiResponse.object(response, Todo.fromJson).data;
  }

  Future<Todo> updateTitle(int todoId, String title) async {
    final response = await _client.patch(
      '/todos/$todoId',
      data: <String, dynamic>{'title': title},
    );
    return ApiResponse.object(response, Todo.fromJson).data;
  }

  /// 이번 UI 에 소요시간 입력이 없으므로 actual_minutes 는 필드째 생략한다.
  Future<Todo> complete(int todoId) async {
    final response = await _client.post(
      '/todos/$todoId/complete',
      data: <String, dynamic>{},
    );
    final body = ApiResponse.object(response, (json) => json).data;
    final todo = body['todo'];
    if (todo is Map) {
      return Todo.fromJson(Map<String, dynamic>.from(todo));
    }
    // goal_progress 와 personal_streak 은 이번 범위 화면에서 쓰지 않는다.
    return Todo.fromJson(body);
  }

  Future<void> uncomplete(int todoId) =>
      _client.post('/todos/$todoId/uncomplete');

  Future<void> delete(int todoId) => _client.delete('/todos/$todoId');
}
