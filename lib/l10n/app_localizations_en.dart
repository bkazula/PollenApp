// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pollen today';

  @override
  String get selectLocation => 'Select location';

  @override
  String get chooseOnMap => 'Choose on map or type a city';

  @override
  String get saveLocation => 'Save location';

  @override
  String get changeLocation => 'Change location';

  @override
  String get useCurrentLocation => 'Use my current location';

  @override
  String get cityHint => 'e.g. London';

  @override
  String get citySearch => 'Search city';

  @override
  String get pollenFor => 'Pollen for';

  @override
  String get refresh => 'Refresh';

  @override
  String get apiError => 'Error loading data from Google Pollen API.';

  @override
  String get noData => 'No data for this location.';

  @override
  String get english => 'English';

  @override
  String get polish => 'Polski';

  @override
  String get selectedLocationLabel => 'Selected location';

  @override
  String get locationServicesDisabled =>
      'Location services are disabled on this device.';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Please enable it in system settings.';

  @override
  String get citySearchFailed =>
      'Unable to find the city. Please try another query.';

  @override
  String get intensityVeryHigh => 'Very high';

  @override
  String get intensityHigh => 'High';

  @override
  String get intensityMedium => 'Medium';

  @override
  String get intensityLow => 'Low';
}
