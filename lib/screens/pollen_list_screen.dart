import 'package:flutter/material.dart';

import '../main.dart';
import '../models/app_location.dart';
import '../models/pollen_entry.dart';
import '../services/pollen_api_service.dart';
import 'location_picker_screen.dart';

class PollenListScreen extends StatefulWidget {
  const PollenListScreen({
    required this.initialLocation,
    required this.onLocaleChanged,
    super.key,
  });

  final AppLocation initialLocation;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<PollenListScreen> createState() => _PollenListScreenState();
}

class _PollenListScreenState extends State<PollenListScreen> {
  late Future<List<PollenEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<PollenEntry>> _load() {
    return PollenApiService.fetchPollenData(
      latitude: widget.initialLocation.latitude,
      longitude: widget.initialLocation.longitude,
    );
  }

  Color _colorByIntensity(String intensity) {
    final String normalized = intensity.toLowerCase();
    if (normalized.contains('high') || normalized.contains('very high')) {
      return Colors.red.shade300;
    }
    if (normalized.contains('medium') || normalized.contains('moderate')) {
      return Colors.orange.shade300;
    }
    if (normalized.contains('low')) {
      return Colors.green.shade300;
    }
    return Colors.blueGrey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    final AppStrings strings = AppStrings.of(context);

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
      body: FutureBuilder<List<PollenEntry>>(
        future: _future,
        builder:
            (BuildContext context, AsyncSnapshot<List<PollenEntry>> snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(strings.apiError, textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _future = _load();
                            });
                          },
                          child: Text(strings.refresh),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final List<PollenEntry> entries =
                  snapshot.data ?? <PollenEntry>[];
              if (entries.isEmpty) {
                return Center(child: Text(strings.noData));
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _future = _load();
                  });
                  await _future;
                },
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const Divider(height: 0),
                  itemBuilder: (BuildContext context, int index) {
                    final PollenEntry entry = entries[index];
                    return ListTile(
                      title: Text(entry.name),
                      trailing: Chip(
                        backgroundColor: _colorByIntensity(entry.intensity),
                        label: Text(entry.intensity),
                      ),
                    );
                  },
                ),
              );
            },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            _future = _load();
          });
        },
        icon: const Icon(Icons.refresh),
        label: Text(strings.refresh),
      ),
    );
  }
}
