import 'dart:convert';

import 'package:flutter/services.dart';

/// fixture JSON 을 읽고 날짜 플레이스홀더를 오늘 기준으로 치환한다.
///
/// fixture 에 `2026-09-15` 같은 날짜를 하드코딩하면 내일 실행할 때 빈 화면이
/// 나온다. 그래서 `{{TODAY}}`, `{{TODAY-3}}`, `{{TODAY+27}}`, `{{NOW}}` 만 쓴다.
abstract final class FixtureLoader {
  static const String _basePath = 'lib/mock/fixtures';

  static final RegExp _datePattern = RegExp(r'\{\{TODAY([+-]\d+)?\}\}');

  static Future<Map<String, dynamic>> loadMap(
    String fileName, {
    required DateTime today,
  }) async {
    final raw = await rootBundle.loadString('$_basePath/$fileName');
    final resolved = resolve(raw, today: today);
    return jsonDecode(resolved) as Map<String, dynamic>;
  }

  static Future<List<dynamic>> loadList(
    String fileName, {
    required DateTime today,
  }) async {
    final raw = await rootBundle.loadString('$_basePath/$fileName');
    final resolved = resolve(raw, today: today);
    return jsonDecode(resolved) as List<dynamic>;
  }

  /// 문자열 안의 날짜 플레이스홀더를 치환한다.
  static String resolve(String raw, {required DateTime today}) {
    final withDates = raw.replaceAllMapped(_datePattern, (match) {
      final offset = int.tryParse(match.group(1) ?? '') ?? 0;
      return formatDate(today.add(Duration(days: offset)));
    });
    return withDates.replaceAll('{{NOW}}', '${formatDate(today)}T08:00:00+09:00');
  }

  static String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static DateTime parseDate(String value) {
    final parts = value.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }
}
