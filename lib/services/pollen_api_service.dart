import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pollen_entry.dart';

class PollenApiService {
  static const String _apiKey = String.fromEnvironment('GOOGLE_POLLEN_API_KEY');

  static Future<List<PollenEntry>> fetchPollenData({
    required double latitude,
    required double longitude,
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError(
        'Missing GOOGLE_POLLEN_API_KEY. Pass it with --dart-define=GOOGLE_POLLEN_API_KEY=... during build/run.',
      );
    }

    final Uri uri = Uri.https('pollen.googleapis.com', '/v1/forecast:lookup', {
      'location.latitude': latitude.toString(),
      'location.longitude': longitude.toString(),
      'days': '1',
      'key': _apiKey,
    });

    final http.Response response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw StateError(
        'Google Pollen API returned ${response.statusCode}: ${response.body}',
      );
    }

    final Map<String, dynamic> decoded =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> daily =
        decoded['dailyInfo'] as List<dynamic>? ?? <dynamic>[];
    if (daily.isEmpty) {
      return <PollenEntry>[];
    }

    final Map<String, dynamic> today = daily.first as Map<String, dynamic>;
    final List<dynamic> plants =
        today['plantInfo'] as List<dynamic>? ?? <dynamic>[];

    return plants.map((dynamic raw) {
      final Map<String, dynamic> item = raw as Map<String, dynamic>;
      final Map<String, dynamic> indexInfo =
          item['indexInfo'] as Map<String, dynamic>? ?? <String, dynamic>{};

      final String name =
          (item['displayName'] ?? item['code'] ?? 'Unknown allergen')
              .toString();
      final String intensity =
          (indexInfo['category'] ??
                  indexInfo['displayName'] ??
                  indexInfo['value'] ??
                  'Unknown')
              .toString();

      return PollenEntry(name: name, intensity: intensity);
    }).toList();
  }
}
