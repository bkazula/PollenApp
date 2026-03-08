import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'models/app_location.dart';
import 'screens/location_picker_screen.dart';
import 'screens/pollen_list_screen.dart';
import 'services/location_storage_service.dart';

void main() {
  runApp(const PollenApp());
}

class PollenApp extends StatefulWidget {
  const PollenApp({super.key});

  @override
  State<PollenApp> createState() => _PollenAppState();
}

class _PollenAppState extends State<PollenApp> {
  Locale? _locale;

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pollen Watch',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: const [Locale('en'), Locale('pl')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: AppBootstrapper(onLocaleChanged: _setLocale),
    );
  }
}

class AppBootstrapper extends StatelessWidget {
  const AppBootstrapper({required this.onLocaleChanged, super.key});

  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocation?>(
      future: LocationStorageService.getSavedLocation(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final AppLocation? location = snapshot.data;
        if (location == null) {
          return LocationPickerScreen(onLocaleChanged: onLocaleChanged);
        }

        return PollenListScreen(
          onLocaleChanged: onLocaleChanged,
          initialLocation: location,
        );
      },
    );
  }
}

class AppStrings {
  AppStrings(this.locale);

  final Locale locale;

  static AppStrings of(BuildContext context) {
    final Locale locale =
        Localizations.maybeLocaleOf(context) ??
        PlatformDispatcher.instance.locale;
    return AppStrings(locale);
  }

  bool get _isPolish => locale.languageCode == 'pl';

  String get appTitle => _isPolish ? 'Pylenie dzisiaj' : 'Pollen today';
  String get selectLocation =>
      _isPolish ? 'Wybierz lokalizację' : 'Select location';
  String get chooseOnMap => _isPolish
      ? 'Wybierz na mapie lub wpisz miasto'
      : 'Choose on map or type a city';
  String get saveLocation => _isPolish ? 'Zapisz lokalizację' : 'Save location';
  String get changeLocation =>
      _isPolish ? 'Zmień lokalizację' : 'Change location';
  String get useCurrentLocation =>
      _isPolish ? 'Użyj mojej lokalizacji' : 'Use my current location';
  String get cityHint => _isPolish ? 'Np. Kraków' : 'e.g. London';
  String get citySearch => _isPolish ? 'Szukaj miasta' : 'Search city';
  String get pollenFor => _isPolish ? 'Pylenie dla' : 'Pollen for';
  String get refresh => _isPolish ? 'Odśwież' : 'Refresh';
  String get apiError => _isPolish
      ? 'Błąd pobierania danych z Google Pollen API.'
      : 'Error loading data from Google Pollen API.';
  String get noData => _isPolish
      ? 'Brak danych dla tej lokalizacji.'
      : 'No data for this location.';
  String get high => _isPolish ? 'Wysokie' : 'High';
  String get medium => _isPolish ? 'Średnie' : 'Medium';
  String get low => _isPolish ? 'Niskie' : 'Low';
  String get unknown => _isPolish ? 'Nieznane' : 'Unknown';
  String get language => _isPolish ? 'Język' : 'Language';
  String get english => 'English';
  String get polish => 'Polski';
}
