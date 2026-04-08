import 'package:fix_my_road/features/map/controller/mapController.dart';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewMap extends StatefulWidget {
  const ViewMap({super.key});

  @override
  State<ViewMap> createState() => _ViewMapState();
}

class _ViewMapState extends State<ViewMap> {
  Map<String, BitmapDescriptor> customIcons = {};
  late GoogleMapController mapController;
  Location location = Location();
  
  bool _isCheckingPermissions = true; 
  bool _isMapRendering = true;

  Set<String> selectedCategories = {"All"};
  List<String> categories = [
    "All",
    "Pothole",
    "Drainage",
    "Street Light",
    "Traffic Light",
    "Road Sign",
    "Roadside Safety",
    "Public Transport Facilities",
    "Other",
  ];

  Map<String, String> categoryIcons = {
    "Pothole": "assets/icons/pothole.png",
    "Drainage": "assets/icons/drainage.png",
    "Street Light": "assets/icons/street_light.png",
    "Traffic Light": "assets/icons/traffic_light.png",
    "Road Sign": "assets/icons/road_sign.png",
    "Roadside Safety": "assets/icons/safety.png",
    "Public Transport Facilities": "assets/icons/transport.png",
    "Other": "assets/icons/other.png",
  };

  Future<void> _loadIssuesFromAPI() async {
    try {
      final data = await MapController.getIssues();

      Set<Marker> markers = data
          .where((issue) {
            if (selectedCategories.contains("All")) return true;

            String mapped =
                issueTypeMapping[issue['category']] ?? issue['category'];

            return selectedCategories.contains(mapped);
          })
          .map<Marker>((issue) {
        String mapped =
            issueTypeMapping[issue['category']] ?? issue['category'];

        return Marker(
          markerId: MarkerId(issue['id'].toString()),
          position: LatLng(issue['latitude'], issue['longitude']),
          icon: customIcons[mapped] ?? BitmapDescriptor.defaultMarker,
          onTap: () => _showIssueDetails(issue),
        );
      }).toSet();

      setState(() {
        _markers = markers;
      });
    } catch (e) {
      print(e);
    }
  }

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadIcons();          // wait icons
    await _initializeMapFlow();  // permissions
    await _loadIssuesFromAPI();  // THEN load markers
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

  Map<String, String> issueTypeMapping = {
    "Saliran / Banjir": "Drainage",
    "Lubang Jalan": "Pothole",
    "Kemudahan Pengangkutan Awam": "Public Transport Facilities",
    "Tanda Jalan": "Road Sign",
    "Keselamatan tepi jalan": "Roadside Safety",
    "Lampu Jalan": "Street Light",
    "Lampu Isyarat": "Traffic Light",
    "Lain-lain": "Other",
  };

  void _showIssueDetails(Map<String, dynamic> issue) {
  LatLng position = LatLng(issue['latitude'], issue['longitude']);
  String status = issue['status'].toString().toLowerCase();

  // Color logic for status
  Color statusColor = status == 'resolved' ? Colors.green : const Color(0xFF7864C8);
  String rawDate = issue['created_at'] ?? 'No Date';
  String formattedDate = rawDate.split(' ')[0];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.7, // Slightly taller for better first impression
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF8F9FA), // Light grey background for contrast
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 15),
                  height: 6,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      // --- HEADER & STATUS ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween, // Spaced apart if on one line
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 10, // Horizontal gap
                            runSpacing: 8,
                            children: [
                              Text(
                                issue['title'],
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              ]
                          ),
                          
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                        ],
                      ),
                     
                      const SizedBox(height: 25),

                      // --- INFO GRID CARDS (DATE INSTEAD OF AREA) ---
                      Row(
                        children: [
                          _buildModernInfoCard(Icons.category_rounded, "Category", issue['category']),
                          const SizedBox(width: 15),
                          _buildModernInfoCard(Icons.calendar_today_rounded, "Date Reported", formattedDate),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // --- DESCRIPTION SECTION ---
                      const Text("Report Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          issue['description'],
                          style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- ENHANCED EVIDENCE PHOTOS ---
                      if (issue['photo1'] != null) ...[
                        const Text("Evidence Gallery", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 140,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              if (issue['photo1'] != null) _buildEnhancedImage(issue['photo1']),
                              if (issue['photo2'] != null) _buildEnhancedImage(issue['photo2']),
                              if (issue['photo3'] != null) _buildEnhancedImage(issue['photo3']),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 30),

                      // --- MINI MAP PREVIEW ---
                      const Text("Location Tracking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: GoogleMap(
                            liteModeEnabled: true,
                            initialCameraPosition: CameraPosition(target: position, zoom: 16),
                            markers: {Marker(markerId: const MarkerId("prev"), position: position)},
                            zoomControlsEnabled: false,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20,),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7864C8),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.directions_outlined),
                        label: const Text("Start Navigation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          final url = Uri.parse(
                          "https://www.google.com/maps/dir/?api=1&destination=${issue['latitude']},${issue['longitude']}");
                          if (await canLaunchUrl(url)) await launchUrl(url);
                        },
                      ),

                      const SizedBox(height: 20,),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildModernInfoCard(IconData icon, String label, String value) {
  return Expanded(
    child: Container(
      height: 125,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF7864C8), size: 22),
          const SizedBox(height: 10),
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    ),
  );
}

  Widget _buildEnhancedImage(String path) {
  String imageUrl = "${MyConfig.myurl}/$path";

  return GestureDetector(
    onTap: () {
      // Open fullscreen image
      showDialog(
        context: context,
        barrierColor: Colors.black, // Background color
        builder: (_) => GestureDetector(
          onTap: () => Navigator.of(context).pop(), // Tap anywhere to close
          child: Container(
            color: Colors.black,
            child: Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    child: Container(
      margin: const EdgeInsets.only(right: 15),
      width: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey[200],
            child: const Icon(Icons.image_not_supported_outlined),
          ),
        ),
      ),
    ),
  );
}
  // --- HELPER WIDGETS ---

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[100],
            radius: 18,
            child: Icon(icon, size: 18, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildModernImage(String path) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          "${MyConfig.myurl}/$path",
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[200], child: const Icon(Icons.broken_image)),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    try {
      var pos = await location.getLocation();

      LatLng userLatLng = LatLng(pos.latitude!, pos.longitude!);

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(userLatLng, 16),
      );
    } catch (e) {
      print(e);
    }

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
                target: LatLng(0, 0),
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
                  bool isSelected = selectedCategories.contains(cat);
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    child: FilterChip(
                      elevation: isSelected ? 2 : 0, // Reduced elevation for a flatter look
                      pressElevation: 2,
                      showCheckmark: false,
                      backgroundColor: Colors.white.withOpacity(0.9),
                      selectedColor: const Color(0xFF7864C8),
                      // Reduced vertical padding to keep container height same while icons grow
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      avatar: ClipOval(
                      child: Container(
                        width: 36,  // Bigger width
                        height: 36, // Bigger height
                        color: Colors.transparent,
                        child: cat == "All"
                            ? Icon(Icons.layers_outlined, color: isSelected ? Colors.white : Colors.black87)
                            : Image.asset(
                                categoryIcons[cat]!,
                                fit: BoxFit.cover,
                                color: isSelected ? Colors.white : null,
                              ),
                      ),
                    ),
                      label: Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) => _toggleCategory(cat),
                    )
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

  Future<BitmapDescriptor> _createCircleMarker(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    final ui.Codec codec = await ui.instantiateImageCodec(bytes, targetWidth: 100);
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ui.Image image = fi.image;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    const double size = 120.0;
    const double shadowBlur = 2.0;

    final Paint paint = Paint()..isAntiAlias = true;

    // 1. Draw Shadow for depth
    final Path pinPath = Path();
    pinPath.moveTo(size / 2, size); // Bottom point
    pinPath.quadraticBezierTo(size * 0.1, size * 0.6, size * 0.1, size * 0.4); // Left side
    pinPath.arcToPoint(const Offset(size * 0.9, size * 0.4), radius: const Radius.circular(size * 0.4)); // Top curve
    pinPath.quadraticBezierTo(size * 0.9, size * 0.6, size / 2, size); // Right side
    
    canvas.drawShadow(pinPath, Colors.black, shadowBlur, false);

    // 2. Draw Pin Background (White)
    canvas.drawPath(pinPath, Paint()..color = Colors.white);
    
    // 3. Draw Outer Border (The accent color)
    canvas.drawPath(
      pinPath, 
      Paint()
        ..color = const Color.fromARGB(255, 0, 0, 0) 
        ..style = PaintingStyle.stroke 
        ..strokeWidth = 4
    );

    // 4. Clip and Draw Image in a circle at the top of the pin
    canvas.save();
    final Path imageClip = Path()
      ..addOval(Rect.fromLTWH(size * 0.2, size * 0.1, size * 0.6, size * 0.6));
    canvas.clipPath(imageClip);
    
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(size * 0.2, size * 0.1, size * 0.6, size * 0.6),
      paint,
    );
    canvas.restore();

    final img = await recorder.endRecording().toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> _loadIcons() async {
    customIcons["Pothole"] = await _createCircleMarker("assets/icons/pothole.png");
    customIcons["Drainage"] = await _createCircleMarker("assets/icons/drainage.png");
    customIcons["Street Light"] = await _createCircleMarker("assets/icons/street_light.png");
    customIcons["Traffic Light"] = await _createCircleMarker("assets/icons/traffic_light.png");
    customIcons["Road Sign"] = await _createCircleMarker("assets/icons/road_sign.png");
    customIcons["Roadside Safety"] = await _createCircleMarker("assets/icons/safety.png");
    customIcons["Public Transport Facilities"] = await _createCircleMarker("assets/icons/transport.png");
    customIcons["Other"] = await _createCircleMarker("assets/icons/other.png");
  }

  Widget _buildImage(String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          "${MyConfig.myurl}/$path",
          height: 150,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  void _toggleCategory(String category) {
  setState(() {
    if (category == "All") {
      selectedCategories = {"All"};
    } else {
      selectedCategories.remove("All");

      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }

      if (selectedCategories.isEmpty) {
        selectedCategories.add("All");
      }
    }
  });

  _loadIssuesFromAPI();
}
}