import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pollen_entry.dart';

class PollenApiException implements Exception {
  const PollenApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PollenApiService {
  static const String _apiKey = String.fromEnvironment('GOOGLE_POLLEN_API_KEY');

  static Future<List<PollenEntry>> fetchPollenData({
    required double latitude,
    required double longitude,
  }) async {
    if (_apiKey.isEmpty) {
      throw const PollenApiException('Missing Google Pollen API key.');
    }

    final Uri uri = Uri.https('pollen.googleapis.com', '/v1/forecast:lookup', {
      'location.latitude': latitude.toString(),
      'location.longitude': longitude.toString(),
      'days': '1',
      'key': _apiKey,
    });

    final http.Response response;
    try {
      response = await http.get(uri);
    } on Object {
      throw const PollenApiException('Unable to connect to Google Pollen API.');
    }

    if (response.statusCode >= 400) {
      throw PollenApiException(
        'Google Pollen API request failed with status ${response.statusCode}.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const PollenApiException(
        'Google Pollen API returned invalid JSON.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const PollenApiException(
        'Google Pollen API returned unexpected data.',
      );
    }

    final Object? dailyInfo = decoded['dailyInfo'];
    if (dailyInfo is! List || dailyInfo.isEmpty) {
      return <PollenEntry>[];
    }

    final Object? firstDay = dailyInfo.first;
    if (firstDay is! Map<String, dynamic>) {
      return <PollenEntry>[];
    }

    final Object? plantInfo = firstDay['plantInfo'];
    if (plantInfo is! List) {
      return <PollenEntry>[];
    }

    return plantInfo
        .whereType<Map<String, dynamic>>()
        .map(_parsePollenEntry)
        .whereType<PollenEntry>()
        .toList();
  }

  static PollenEntry? _parsePollenEntry(Map<String, dynamic> item) {
    final String? name = _firstNonEmptyString(<Object?>[
      item['displayName'],
      item['code'],
    ]);
    if (name == null) {
      return null;
    }

    final Object? rawIndexInfo = item['indexInfo'];
    final Map<String, dynamic> indexInfo = rawIndexInfo is Map<String, dynamic>
        ? rawIndexInfo
        : <String, dynamic>{};
    final String intensity =
        _firstNonEmptyString(<Object?>[
          indexInfo['category'],
          indexInfo['displayName'],
          indexInfo['value'],
        ]) ??
        'Unknown';

    return PollenEntry(name: name, intensity: intensity);
  }

  static String? _firstNonEmptyString(List<Object?> values) {
    for (final Object? value in values) {
      final String? text = switch (value) {
        final String raw => raw.trim(),
        final num raw => raw.toString(),
        _ => null,
      };

      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return null;
  }
}
