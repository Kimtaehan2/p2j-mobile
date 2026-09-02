import '../../../core/network/api_response.dart';
import '../../../core/network/dio_client.dart';
import 'goal_models.dart';

class GoalApi {
  const GoalApi(this._client);

  final ApiClient _client;

  /// 커서 페이지네이션이 있지만 이번 범위는 첫 페이지만 쓴다.
  /// page 가 와도 무시한다.
  Future<List<Goal>> fetchActive() async {
    final response = await _client.get(
      '/goals',
      query: <String, dynamic>{'status': 'active'},
    );
    return PagedResponse.parse(response, Goal.fromJson).items;
  }
}
