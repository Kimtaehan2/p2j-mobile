import 'package:dio/dio.dart';

import 'api_exception.dart';

/// 커서 페이지네이션 정보.
class PageInfo {
  const PageInfo({this.nextCursor, this.hasNext = false});

  factory PageInfo.fromJson(Map<String, dynamic> json) => PageInfo(
        nextCursor: json['next_cursor'] as String?,
        hasNext: json['has_next'] as bool? ?? false,
      );

  final String? nextCursor;
  final bool hasNext;
}

/// 서버 공통 응답 래퍼.
///
/// `data` 언랩과 형식 오류 처리를 여기 한 곳에서 한다.
/// Repository 는 항상 이걸 거쳐 모델을 만든다.
class ApiResponse<T> {
  const ApiResponse({required this.data, this.page});

  final T data;
  final PageInfo? page;

  /// `{ "data": { ... } }` 형태를 파싱한다.
  static ApiResponse<T> object<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final body = _asMap(response);
    final data = body['data'];
    if (data is! Map) {
      throw _malformed(response);
    }
    return ApiResponse<T>(
      data: parse(Map<String, dynamic>.from(data)),
      page: _page(body),
    );
  }

  /// `{ "data": [ ... ], "page": { ... } }` 형태를 파싱한다.
  static ApiResponse<List<T>> list<T>(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final body = _asMap(response);
    final data = body['data'];
    if (data is! List) {
      throw _malformed(response);
    }
    return ApiResponse<List<T>>(
      data: data
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList(growable: false),
      page: _page(body),
    );
  }

  static Map<String, dynamic> _asMap(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    throw _malformed(response);
  }

  static PageInfo? _page(Map<String, dynamic> body) {
    final page = body['page'];
    if (page is Map) return PageInfo.fromJson(Map<String, dynamic>.from(page));
    return null;
  }

  static ApiException _malformed(Response<dynamic> response) => ApiException(
        code: ApiErrorCode.unknown,
        message: '서버 응답 형식이 예상과 달라요. 잠시 후 다시 시도하세요.',
        statusCode: response.statusCode,
      );
}

/// 커서 페이지네이션 목록 응답.
///
/// 이번 범위에서는 첫 페이지만 쓰지만, 12~13주차 그룹 피드에서 재사용한다.
class PagedResponse<T> {
  const PagedResponse({required this.items, this.nextCursor, this.hasNext = false});

  factory PagedResponse.parse(
    Response<dynamic> response,
    T Function(Map<String, dynamic> json) parse,
  ) {
    final result = ApiResponse.list(response, parse);
    return PagedResponse<T>(
      items: result.data,
      nextCursor: result.page?.nextCursor,
      hasNext: result.page?.hasNext ?? false,
    );
  }

  final List<T> items;
  final String? nextCursor;
  final bool hasNext;
}
