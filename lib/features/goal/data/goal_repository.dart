import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/network/dio_client.dart';
import 'goal_api.dart';
import 'goal_models.dart';

part 'goal_repository.g.dart';

abstract interface class GoalRepository {
  Future<List<Goal>> fetchActive();
}

class GoalRepositoryImpl implements GoalRepository {
  const GoalRepositoryImpl(this._api);

  final GoalApi _api;

  @override
  Future<List<Goal>> fetchActive() => _api.fetchActive();
}

@Riverpod(keepAlive: true)
GoalRepository goalRepository(Ref ref) =>
    GoalRepositoryImpl(GoalApi(ref.watch(apiClientProvider)));
