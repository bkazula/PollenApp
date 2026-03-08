// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Pylenie dzisiaj';

  @override
  String get selectLocation => 'Wybierz lokalizację';

  @override
  String get chooseOnMap => 'Wybierz na mapie lub wpisz miasto';

  @override
  String get saveLocation => 'Zapisz lokalizację';

  @override
  String get changeLocation => 'Zmień lokalizację';

  @override
  String get useCurrentLocation => 'Użyj mojej lokalizacji';

  @override
  String get cityHint => 'Np. Kraków';

  @override
  String get citySearch => 'Szukaj miasta';

  @override
  String get pollenFor => 'Pylenie dla';

  @override
  String get refresh => 'Odśwież';

  @override
  String get apiError => 'Błąd pobierania danych z Google Pollen API.';

  @override
  String get noData => 'Brak danych dla tej lokalizacji.';

  @override
  String get english => 'English';

  @override
  String get polish => 'Polski';
}
