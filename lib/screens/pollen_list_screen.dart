import 'package:flutter/material.dart';
import 'package:pollenapp/l10n/app_localizations.dart';

import '../models/app_location.dart';
import '../models/pollen_entry.dart';
import '../services/pollen_api_service.dart';
import '../services/pollen_data_loader.dart';
import 'location_picker_screen.dart';

class PollenListScreen extends StatefulWidget {
  const PollenListScreen({
    required this.initialLocation,
    required this.onLocaleChanged,
    this.pollenDataLoader,
    super.key,
  });

  final AppLocation initialLocation;
  final ValueChanged<Locale> onLocaleChanged;
  final PollenDataLoader? pollenDataLoader;

  @override
  State<PollenListScreen> createState() => _PollenListScreenState();
}

class _PollenListScreenState extends State<PollenListScreen> {
  List<PollenEntry>? _entries;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } else {
      setState(() {
        _hasError = false;
      });
    }

    try {
      final PollenDataLoader loader =
          widget.pollenDataLoader ?? PollenApiService.fetchPollenData;
      final List<PollenEntry> entries = await loader(
        latitude: widget.initialLocation.latitude,
        longitude: widget.initialLocation.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _entries = entries;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _hasError = true;
      });
    } finally {
      if (mounted && showLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _colorByIntensity(String intensity) {
    switch (intensity.trim().toLowerCase()) {
      case 'very high':
      case 'high':
        return Colors.red.shade300;
      case 'moderate':
      case 'medium':
        return Colors.orange.shade300;
      case 'low':
        return Colors.green.shade300;
      default:
        return Colors.blueGrey.shade300;
    }
  }

  String _localizedIntensity(AppLocalizations strings, String intensity) {
    switch (intensity.trim().toLowerCase()) {
      case 'very high':
        return strings.intensityVeryHigh;
      case 'high':
        return strings.intensityHigh;
      case 'moderate':
      case 'medium':
        return strings.intensityMedium;
      case 'low':
        return strings.intensityLow;
      default:
        return intensity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${strings.pollenFor}: ${widget.initialLocation.label}'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => LocationPickerScreen(
                    onLocaleChanged: widget.onLocaleChanged,
                    pollenDataLoader: widget.pollenDataLoader,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.map),
            tooltip: strings.changeLocation,
          ),
          PopupMenuButton<Locale>(
            onSelected: widget.onLocaleChanged,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              PopupMenuItem<Locale>(
                value: const Locale('en'),
                child: Text(strings.english),
              ),
              PopupMenuItem<Locale>(
                value: const Locale('pl'),
                child: Text(strings.polish),
              ),
            ],
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: _buildBody(strings),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _load(),
        icon: const Icon(Icons.refresh),
        label: Text(strings.refresh),
      ),
    );
  }

  Widget _buildBody(AppLocalizations strings) {
    if (_isLoading && _entries == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _entries == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(strings.apiError, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _load(),
                child: Text(strings.refresh),
              ),
            ],
          ),
        ),
      );
    }

    final List<PollenEntry> entries = _entries ?? <PollenEntry>[];
    if (entries.isEmpty) {
      return Center(child: Text(strings.noData));
    }

    return RefreshIndicator(
      onRefresh: () => _load(showLoading: false),
      child: Stack(
        children: [
          ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, _) => const Divider(height: 0),
            itemBuilder: (BuildContext context, int index) {
              final PollenEntry entry = entries[index];
              return ListTile(
                title: Text(entry.name),
                trailing: Chip(
                  backgroundColor: _colorByIntensity(entry.intensity),
                  label: Text(_localizedIntensity(strings, entry.intensity)),
                ),
              );
            },
          ),
          if (_hasError)
            Align(
              alignment: Alignment.topCenter,
              child: MaterialBanner(
                content: Text(strings.apiError),
                actions: [
                  TextButton(
                    onPressed: () => _load(),
                    child: Text(strings.refresh),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
