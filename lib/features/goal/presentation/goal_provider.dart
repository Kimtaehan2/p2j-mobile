import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/goal_models.dart';
import '../data/goal_repository.dart';

part 'goal_provider.g.dart';

/// 진행 중인 목표 목록.
@riverpod
Future<List<Goal>> activeGoals(Ref ref) =>
    ref.watch(goalRepositoryProvider).fetchActive();
