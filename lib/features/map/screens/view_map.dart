import 'package:fix_my_road/features/map/controller/mapController.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/shared/support_widget/snack_bar.dart';
import 'package:fix_my_road/utils/locationPermission.dart';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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

  Set<Marker> _markers = {};

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // tap outside closes
      builder: (_) {
        return GestureDetector(
          onTap: () => Navigator.pop(context), // tap anywhere to close
          child: Container(
            color: Colors.black.withOpacity(0.9),
            child: Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(imageUrl),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, Map<String, String>> statusMapping = {
    "in_progress": {"en": "In Progress", "ms": "Dalam Proses"},
    "approved": {"en": "Reported", "ms": "Dilaporkan"},
  };

  Map<String, Map<String, String>> issueTypeMappingMalay = {
    "Pothole": {"en": "Pothole", "ms": "Lubang Jalan"},
    "Drainage": {"en": "Drainage", "ms": "Saliran / Banjir"},
    "Street Light": {"en": "Street Light", "ms": "Lampu Jalan"},
    "Traffic Light": {"en": "Traffic Light", "ms": "Lampu Isyarat"},
    "Road Sign": {"en": "Road Sign", "ms": "Tanda Jalan"},
    "Roadside Safety": {"en": "Roadside Safety", "ms": "Keselamatan tepi jalan"},
    "Public Transport Facilities": {"en": "Public Transport Facilities", "ms": "Kemudahan Pengangkutan Awam"},
    "Other": {"en": "Other", "ms": "Lain-lain"},
  };

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
  Set<String> selectedCategories = {"All"};

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

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadIcons();
    if (!mounted) return;

    await _initializeMapFlow();
    if (!mounted) return;

    await _loadIssuesFromAPI();
  }

  Future<void> _initializeMapFlow() async {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    bool isEnglish = languageProvider.isEnglish;

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        _showErrorDialog(isEnglish ? 'GPS is required' : 'GPS diperlukan');
        return;
      }
    }

    bool granted = await LocationPermissionHandler.checkAndRequest(context);
    if (!granted) {
      _showErrorDialog(isEnglish ? 'Location permission denied' : 'Kebenaran lokasi ditolak');
      return;
    }

    if (!mounted) return;
      setState(() {
        _isCheckingPermissions = false;
      });
  }

  Future<void> _loadIssuesFromAPI() async {
    try {
      final data = await MapController.getIssues();

      Set<Marker> markers = await Future.microtask(() {
        return data.where((issue) {
          String status = (issue['status'] ?? '').toString().toLowerCase();
          if (status != 'in_progress' && status != 'approved') return false;

          if (selectedCategories.contains("All")) return true;
          String mapped = issueTypeMapping[issue['category']] ?? issue['category'];
          return selectedCategories.contains(mapped);
        }).map<Marker>((issue) {
          String mapped = issueTypeMapping[issue['category']] ?? issue['category'];
          return Marker(
            markerId: MarkerId(issue['id'].toString()),
            position: LatLng(issue['latitude'], issue['longitude']),
            icon: customIcons[mapped] ?? BitmapDescriptor.defaultMarker,
            onTap: () => _showIssueDetails(issue),
          );
        }).toSet();
      });

      if (!mounted) return;
        setState(() => _markers = markers);
    } catch (e) {
      print(e);
    }
  }

  void _showIssueDetails(Map<String, dynamic> issue) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    bool isEnglish = languageProvider.isEnglish;

    LatLng position = LatLng(issue['latitude'], issue['longitude']);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _buildIssueDetailSheet(issue, position, isEnglish),
      );
    });
  }

  Widget _buildIssueDetailSheet(Map<String, dynamic> issue, LatLng position, bool isEnglish) {
    final statusInfo = getStatusInfo(issue['status'].toString().toLowerCase(), isEnglish);
    final displayStatus = statusInfo['text'];
    final statusColor = statusInfo['color'];
    String rawDate = issue['created_at'] ?? (isEnglish ? "No Date" : "Tiada Tarikh");
    String formattedDate = rawDate.split(' ')[0];
    String issueTypeDisplay = issueTypeMappingMalay[issue['category']]?[(isEnglish ? "en" : "ms")] ?? issue['category'];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FA),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          issue['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayStatus.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(child: _buildModernInfoCard(Icons.category_rounded, isEnglish ? "Category" : "Kategori", issueTypeDisplay)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildModernInfoCard(Icons.calendar_today_rounded, isEnglish ? "Date Reported" : "Tarikh Dilaporkan", formattedDate)),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(isEnglish ? "Report Details" : "Butiran Laporan", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
                    child: Text(issue['description'], style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 15)),
                  ),
                  const SizedBox(height: 30),
                  if (issue['photo1'] != null) ...[
                    Text(isEnglish ? "Photos Provided" : "Gambar Disediakan", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Text(isEnglish ? "Location Tracking" : "Penjejakan Lokasi", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
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
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Material(
                      borderRadius: BorderRadius.circular(30),
                      elevation: 8,
                      shadowColor: const Color(0xFF7864C8).withOpacity(0.5),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7864C8), Color(0xFF9C8CF0)],
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(30),
                          onTap: () async {
                            final url = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=${issue['latitude']},${issue['longitude']}");
                            if (await canLaunchUrl(url)) await launchUrl(url);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.navigation_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 10), 
                                    Text(
                                      isEnglish ? "Navigate to Location" : "Navigasi ke Lokasi",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  isEnglish ? "Open in Maps" : "Buka dalam Peta",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernInfoCard(IconData icon, String label, String value) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF7864C8), size: 22),
      const SizedBox(height: 10),
      Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ]),
  );

  Widget _buildEnhancedImage(String path) {
    String imageUrl = "${MyConfig.myurl}/$path";

    return GestureDetector(
      onTap: () {
        _showFullImage(imageUrl);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_not_supported_outlined),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) => 
    CustomSnackbar.show(
      context,
      message,
      Colors.redAccent,
      Colors.white,
    );

  Map<String, dynamic> getStatusInfo(String status, bool isEnglish) {
    String text = statusMapping[status]?[(isEnglish ? "en" : "ms")] ?? status;
    Color color;
    switch (status) {
      case "in_progress": color = Colors.purple; break;
      case "approved": color = Colors.blue; break;
      default: color = Colors.grey;
    }
    return {"text": text, "color": color};
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

    if (!mounted) return;
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
                    final languageProvider = Provider.of<LanguageProvider>(context);
                    bool isEnglish = languageProvider.isEnglish;

                    // Determine label based on current language
                    String displayLabel;
                    if (cat == "All") {
                      displayLabel = isEnglish ? "All" : "Semua";
                    } else {
                      displayLabel = isEnglish
                          ? cat
                          : issueTypeMappingMalay[cat]?["ms"] ?? cat;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: FilterChip(
                        elevation: isSelected ? 2 : 0,
                        pressElevation: 2,
                        showCheckmark: false,
                        backgroundColor: Colors.white.withOpacity(0.9),
                        selectedColor: const Color(0xFF7864C8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        avatar: ClipOval(
                          child: Container(
                            width: 36,
                            height: 36,
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
                          displayLabel,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (selected) => _toggleCategory(cat),
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