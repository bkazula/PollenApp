import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:pollenapp/l10n/app_localizations.dart';

import '../models/app_location.dart';
import '../services/location_storage_service.dart';
import '../services/pollen_data_loader.dart';
import 'pollen_list_screen.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({
    required this.onLocaleChanged,
    this.pollenDataLoader,
    super.key,
  });

  final ValueChanged<Locale> onLocaleChanged;
  final PollenDataLoader? pollenDataLoader;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final TextEditingController _cityController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _selected = const LatLng(52.2297, 21.0122);
  String _locationLabel = 'Warsaw';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _initFromDeviceLocation();
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _moveMap(LatLng point) {
    _mapController.move(point, _mapController.camera.zoom);
  }

  Future<void> _initFromDeviceLocation() async {
    final AppLocalizations strings = AppLocalizations.of(context);
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.locationServicesDisabled)),
        );
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.locationPermissionDenied)),
        );
      }
      return;
    }

    final Position pos = await Geolocator.getCurrentPosition();
    if (!mounted) {
      return;
    }

    setState(() {
      _selected = LatLng(pos.latitude, pos.longitude);
      _locationLabel =
          '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
    });
    _moveMap(_selected);
  }

  Future<void> _searchCity() async {
    final AppLocalizations strings = AppLocalizations.of(context);
    if (_cityController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final List<Location> results = await locationFromAddress(
        _cityController.text.trim(),
      );
      if (results.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(strings.citySearchFailed)));
        }
        return;
      }

      final Location result = results.first;
      if (!mounted) {
        return;
      }

      setState(() {
        _selected = LatLng(result.latitude, result.longitude);
        _locationLabel = _cityController.text.trim();
      });
      _moveMap(_selected);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(strings.citySearchFailed)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveAndContinue() async {
    final AppLocation location = AppLocation(
      latitude: _selected.latitude,
      longitude: _selected.longitude,
      label: _locationLabel,
    );
    await LocationStorageService.saveLocation(location);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) => PollenListScreen(
          initialLocation: location,
          onLocaleChanged: widget.onLocaleChanged,
          pollenDataLoader: widget.pollenDataLoader,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.selectLocation),
        actions: [
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.chooseOnMap),
            const SizedBox(height: 12),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: strings.cityHint,
                suffixIcon: IconButton(
                  onPressed: _loading ? null : _searchCity,
                  icon: const Icon(Icons.search),
                  tooltip: strings.citySearch,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _initFromDeviceLocation,
              icon: const Icon(Icons.my_location),
              label: Text(strings.useCurrentLocation),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selected,
                    initialZoom: 7,
                    onTap: (_, LatLng point) {
                      setState(() {
                        _selected = point;
                        _locationLabel =
                            '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.pollenapp',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selected,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.place,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('${strings.selectedLocationLabel}: $_locationLabel'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saveAndContinue,
              icon: const Icon(Icons.check),
              label: Text(strings.saveLocation),
            ),
          ],
        ),
      ),
    );
  }
}
