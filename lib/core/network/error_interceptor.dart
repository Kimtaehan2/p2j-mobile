import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_exception.dart';

/// 서버 error.code 를 [ApiException] 으로 바꿔 붙인다.
///
/// AuthInterceptor 뒤에 등록해야 한다. 재발급 판단이 원본 401 을 먼저 봐야 하기
/// 때문이다.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = ApiException.fromDio(err);

    if (kDebugMode) {
      debugPrint(
        '[API] ${err.requestOptions.method} ${err.requestOptions.path} '
        '-> $apiException',
      );
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        stackTrace: err.stackTrace,
      ),
    );
  }
}
