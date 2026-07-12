import 'package:flutter/material.dart';
import 'package:pollenapp/l10n/app_localizations.dart';

import 'models/app_location.dart';
import 'screens/location_picker_screen.dart';
import 'screens/pollen_list_screen.dart';
import 'services/location_storage_service.dart';
import 'services/pollen_data_loader.dart';

typedef SavedLocationLoader = Future<AppLocation?> Function();

void main() {
  runApp(const PollenApp());
}

class PollenApp extends StatefulWidget {
  const PollenApp({
    this.savedLocationLoader = LocationStorageService.getSavedLocation,
    this.pollenDataLoader,
    this.autoLocateOnOpen = true,
    super.key,
  });

  final SavedLocationLoader savedLocationLoader;
  final PollenDataLoader? pollenDataLoader;
  final bool autoLocateOnOpen;

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
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: AppBootstrapper(
        onLocaleChanged: _setLocale,
        pollenDataLoader: widget.pollenDataLoader,
        savedLocationLoader: widget.savedLocationLoader,
        autoLocateOnOpen: widget.autoLocateOnOpen,
      ),
    );
  }
}

class AppBootstrapper extends StatefulWidget {
  const AppBootstrapper({
    required this.onLocaleChanged,
    this.pollenDataLoader,
    this.savedLocationLoader = LocationStorageService.getSavedLocation,
    this.autoLocateOnOpen = true,
    super.key,
  });

  final ValueChanged<Locale> onLocaleChanged;
  final PollenDataLoader? pollenDataLoader;
  final SavedLocationLoader savedLocationLoader;
  final bool autoLocateOnOpen;

  @override
  State<AppBootstrapper> createState() => _AppBootstrapperState();
}

class _AppBootstrapperState extends State<AppBootstrapper> {
  late final Future<AppLocation?> _savedLocationFuture;

  @override
  void initState() {
    super.initState();
    _savedLocationFuture = widget.savedLocationLoader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppLocation?>(
      future: _savedLocationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final AppLocation? location = snapshot.data;
        if (location == null) {
          return LocationPickerScreen(
            onLocaleChanged: widget.onLocaleChanged,
            pollenDataLoader: widget.pollenDataLoader,
            autoLocateOnOpen: widget.autoLocateOnOpen,
          );
        }

        return PollenListScreen(
          onLocaleChanged: widget.onLocaleChanged,
          initialLocation: location,
          pollenDataLoader: widget.pollenDataLoader,
        );
      },
    );
  }
}
