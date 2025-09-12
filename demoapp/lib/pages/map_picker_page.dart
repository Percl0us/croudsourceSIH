// lib/pages/map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  final LatLng? initialLocation; // Optional initial location

  const MapPickerPage({super.key, this.initialLocation});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? _pickedLocation;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _pickedLocation ??= _currentLocation;
      });
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  void _onTap(TapPosition tapPos, LatLng latlng) {
    setState(() => _pickedLocation = latlng);
  }

  void _confirmLocation() {
    if (_pickedLocation != null) {
      Navigator.pop(context, _pickedLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _pickedLocation ?? _currentLocation ?? LatLng(28.6139, 77.2090); // Delhi fallback

    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: FlutterMap(
        options: MapOptions(
          onTap: _onTap,
          initialCenter: center,
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.demoapp",
          ),
          if (_pickedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _pickedLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _confirmLocation,
        icon: const Icon(Icons.check),
        label: const Text("Confirm"),
      ),
    );
  }
}
