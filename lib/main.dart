import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pollenapp/l10n/app_localizations.dart';

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
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
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
