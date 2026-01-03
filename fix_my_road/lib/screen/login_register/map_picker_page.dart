import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _controller;
  LatLng _selectedPosition = const LatLng(6.4576, 100.5038);
  String _selectedAddress = '';
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _updateAddress(_selectedPosition); // get initial address
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) await Permission.location.request();
  }

  Future<void> _goToCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng current = LatLng(position.latitude, position.longitude);
    setState(() {
      _selectedPosition = current;
    });

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(current, 16));
    await _updateAddress(current);
  }

  Future<void> _updateAddress(LatLng pos) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String formatted =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}";
        setState(() {
          _selectedAddress = formatted;
          _searchController.text = formatted;
        });
      }
    } catch (_) {
      setState(() {
        _selectedAddress =
            "${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}";
        _searchController.text = _selectedAddress;
      });
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(query);
      List<String> addresses = [];
      for (var loc in locations) {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(loc.latitude, loc.longitude);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          addresses.add(
              "${place.street}, ${place.subLocality}, ${place.locality}, ${place.country}");
        }
      }
      setState(() => _suggestions = addresses);
    } catch (_) {
      setState(() => _suggestions = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: _selectedPosition, zoom: 16),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _controller = controller,
            onTap: (pos) async {
              setState(() => _selectedPosition = pos);
              await _updateAddress(pos);
            },
            markers: {
              Marker(
                markerId: const MarkerId("picked"),
                position: _selectedPosition,
                draggable: true,
                onDragEnd: (newPos) async {
                  setState(() => _selectedPosition = newPos);
                  await _updateAddress(newPos);
                },
              ),
            },
          ),

          // Search Bar + OK Button + Back Button
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: "Search location",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: _searchLocation,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                            context, {"position": _selectedPosition, "address": _selectedAddress});
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ),
                // Suggestions List
                if (_suggestions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4)
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_suggestions[index]),
                          onTap: () async {
                            List<Location> locs =
                                await locationFromAddress(_suggestions[index]);
                            if (locs.isNotEmpty) {
                              final newPos =
                                  LatLng(locs.first.latitude, locs.first.longitude);
                              setState(() {
                                _selectedPosition = newPos;
                                _suggestions = [];
                              });
                              _controller
                                  ?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 16));
                              await _updateAddress(newPos);
                            }
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Current Location Button at Bottom Right
          Positioned(
            bottom: 100,
            right: 15,
            child: FloatingActionButton(
              mini: true,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
