import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

import '../models/app_location.dart';

class CityGeocodingService {
  static Future<AppLocation?> search(String query) {
    final String trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return Future<AppLocation?>.value();
    }

    return kIsWeb ? _searchWeb(trimmedQuery) : _searchNative(trimmedQuery);
  }

  static Future<AppLocation?> _searchNative(String query) async {
    final List<Location> results = await locationFromAddress(query);
    if (results.isEmpty) {
      return null;
    }

    final Location location = results.first;
    return AppLocation(
      latitude: location.latitude,
      longitude: location.longitude,
      label: query,
    );
  }

  static Future<AppLocation?> _searchWeb(String query) async {
    final Uri uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'jsonv2',
      'limit': '1',
    });
    final http.Response response = await http.get(
      uri,
      headers: const <String, String>{'User-Agent': 'PollenApp/1.0'},
    );
    if (response.statusCode >= 400) {
      return null;
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) {
      return null;
    }

    final Object? firstResult = decoded.first;
    if (firstResult is! Map<String, dynamic>) {
      return null;
    }

    final double? latitude = double.tryParse(
      firstResult['lat']?.toString() ?? '',
    );
    final double? longitude = double.tryParse(
      firstResult['lon']?.toString() ?? '',
    );
    if (latitude == null || longitude == null) {
      return null;
    }

    return AppLocation(
      latitude: latitude,
      longitude: longitude,
      label: firstResult['display_name']?.toString() ?? query,
    );
  }
}
