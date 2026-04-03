import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ViewMap extends StatefulWidget {
  const ViewMap({super.key});

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  late GoogleMapController mapController;
  Location location = Location();
  
  bool _isCheckingPermissions = true; 
  bool _isMapRendering = true;

  String selectedCategory = "All";
  List<String> categories = ["All", "Pothole", "Street Light", "Drainage"];

  final List<Map<String, dynamic>> reportedIssues = [
    {"id": "1", "title": "Large Pothole", "category": "Pothole", "status": "Approved", "pos": const LatLng(3.1415, 101.6865)},
    {"id": "2", "title": "Broken Lamp", "category": "Street Light", "status": "In Progress", "pos": const LatLng(3.1450, 101.6900)},
  ];

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _loadInitialMarkers();
    _initializeMapFlow();
  }

  Future<void> _initializeMapFlow() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showErrorDialog("GPS is required.");
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        _showErrorDialog("Location permission denied.");
        return;
      }
    }

    setState(() {
      _isCheckingPermissions = false;
    });
  }

  void _loadInitialMarkers() {
    _updateMarkers("All");
  }

  void _updateMarkers(String category) {
    setState(() {
      selectedCategory = category;
      _markers = reportedIssues
          .where((issue) => category == "All" || issue['category'] == category)
          .map((issue) {
        return Marker(
          markerId: MarkerId(issue['id']),
          position: issue['pos'],
          infoWindow: InfoWindow(
            title: issue['title'],
            snippet: "Status: ${issue['status']}",
            onTap: () => _showIssueDetails(issue),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            issue['status'] == "Approved" ? BitmapDescriptor.hueRed : BitmapDescriptor.hueOrange,
          ),
        );
      }).toSet();
    });
  }

  void _showIssueDetails(Map<String, dynamic> issue) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    backgroundColor: Colors.transparent, 
    builder: (context) => Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: [
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            issue['title'], 
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
          ),
          const Divider(height: 30),
          Text(
            "Category: ${issue['category']}",
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            "Status: ${issue['status']}",
            style: TextStyle(
              fontSize: 16, 
              color: issue['status'] == "Approved" ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7864C8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    setState(() {
      _isMapRendering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (!_isCheckingPermissions)
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(3.1390, 101.6869),
                zoom: 14,
              ),
              onMapCreated: _onMapCreated,
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, 
              zoomControlsEnabled: false,
            ),

          if (!_isMapRendering)
            Positioned(
              top: 30,
              left: 10,
              right: 10,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: selectedCategory == cat,
                        onSelected: (selected) {
                          if (selected) _updateMarkers(cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          if (!_isMapRendering)
          Positioned(
            right: 15,
            bottom: 100,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
    
                FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.my_location, color: Color(0xFF7864C8)),
                  onPressed: () async {
                    var pos = await location.getLocation();
                    mapController.animateCamera(
                      CameraUpdate.newLatLng(LatLng(pos.latitude!, pos.longitude!)),
                    );
                  },
                ),
                const SizedBox(height: 12),
                
                FloatingActionButton(
                  mini: true,
                  heroTag: "zoomIn",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.add, color: Colors.black87),
                  onPressed: () => mapController.animateCamera(CameraUpdate.zoomIn()),
                ),
                const SizedBox(height: 8),

                FloatingActionButton(
                  mini: true,
                  heroTag: "zoomOut",
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.remove, color: Colors.black87),
                  onPressed: () => mapController.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
          ),

          if (_isCheckingPermissions || _isMapRendering)
            Container(
              color: const Color.fromARGB(255, 247, 235, 255),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF7864C8),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _isCheckingPermissions ? "Verifying GPS..." : "Downloading Map...",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}