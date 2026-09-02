import 'dart:math';

import 'package:dio/dio.dart';

import '../../mock/mock_scenario.dart';
import '../../mock/mock_store.dart';

/// Dio 요청을 가로채 가짜 서버([MockStore]) 응답으로 바꾼다.
///
/// 실서버 모드에서는 아예 등록되지 않는다. 그래서 Repository 와 화면 코드는
/// Mock 의 존재를 모른다.
class MockInterceptor extends Interceptor {
  MockInterceptor({required this.scenario, Random? random})
      : _random = random ?? Random();

  final MockScenario scenario;
  final Random _random;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 로딩 상태를 실제로 볼 수 있게 200~600ms 지연을 준다.
    await Future<void>.delayed(
      Duration(milliseconds: 200 + _random.nextInt(401)),
    );

    if (scenario == MockScenario.networkError) {
      handler.reject(
        DioException.connectionError(
          requestOptions: options,
          reason: 'mock: 연결 실패 시나리오',
        ),
        // AuthInterceptor / ErrorInterceptor 가 이어서 처리하도록 넘긴다.
        true,
      );
      return;
    }

    await MockStore.instance.ensureInitialized(scenario);

    final result = MockStore.instance.handle(
      method: options.method.toUpperCase(),
      path: options.path,
      query: options.queryParameters,
      body: options.data,
      scenario: scenario,
    );

    final response = Response<dynamic>(
      requestOptions: options,
      statusCode: result.statusCode,
      data: result.body,
    );

    if (result.isError) {
      handler.reject(
        DioException.badResponse(
          statusCode: result.statusCode,
          requestOptions: options,
          response: response,
        ),
        true,
      );
      return;
    }

    handler.resolve(response);
  }
}
