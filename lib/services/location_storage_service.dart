import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_location.dart';

class LocationStorageService {
  static const String _latKey = 'location_lat';
  static const String _lngKey = 'location_lng';
  static const String _labelKey = 'location_label';

  static Future<void> saveLocation(AppLocation location) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, location.latitude);
    await prefs.setDouble(_lngKey, location.longitude);
    await prefs.setString(_labelKey, location.label);
  }

  static Future<AppLocation?> getSavedLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? lat = prefs.getDouble(_latKey);
    final double? lng = prefs.getDouble(_lngKey);

    if (lat == null || lng == null) {
      return null;
    }

    final String label = prefs.getString(_labelKey) ?? 'Selected location';
    return AppLocation(latitude: lat, longitude: lng, label: label);
  }
}
