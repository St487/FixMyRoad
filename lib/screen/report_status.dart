import 'package:fix_my_road/screen/edit_report.dart';
import 'package:flutter/material.dart';

class ReportStatus extends StatefulWidget {
  const ReportStatus({super.key});

  @override
  State<ReportStatus> createState() => _ReportStatusState();
}

class _ReportStatusState extends State<ReportStatus> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Pending', 'In Progress', 'Completed'];
  final Map<String, IconData> filterIcons = {
    'All': Icons.grid_view_rounded,
    'Pending': Icons.schedule_rounded,
    'In Progress': Icons.pending_actions_rounded,
    'Completed': Icons.check_circle_outline_rounded,
  };

  final List<Map<String, dynamic>> reports = [
    {
      'title': 'Large Pothole',
      'location': 'Jalan Changlun',
      'date': 'Jan 02, 2024',
      'status': 'Pending',
      'description': 'Deep pothole causing traffic issues.',
      'photo': 'Photo',
    },
    {
      'title': 'Broken Streetlight',
      'location': 'Industrial Area',
      'date': 'Dec 28, 2023',
      'status': 'In Progress',
      'description': 'Light has been out for a week.',
      'photo': 'Photo',
    },
    {
      'title': 'Fallen Tree',
      'location': 'Park Avenue',
      'date': 'Dec 20, 2023',
      'status': 'Completed',
      'description': 'Tree blocking the sidewalk.',
      'photo': 'Photo',
    },
    {
      'title': 'Pothole',
      'location': 'Main Street, Block A',
      'date': 'Jan 02, 2024',
      'status': 'Pending',
      'description': 'Deep pothole causing traffic issues.',
      'photo': 'Photo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    Future<void> _handleRefresh() async {
      await Future.delayed(const Duration(seconds: 2)); 
      
      setState(() {
      });
    }

    final filteredReports = selectedFilter == 'All'
        ? reports
        : reports.where((r) => r['status'] == selectedFilter).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 235, 255),
      appBar: AppBar(
        title: const Text("Report Status", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          //Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: filters.length,
              itemBuilder: (context, index) {
                String filterName = filters[index];
                bool isSelected = selectedFilter == filters[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    avatar: Icon(
                    filterIcons[filterName], 
                    size: 18, 
                    color: isSelected ? Colors.white : const Color(0xFF7864C8),
                  ),
                  label: Text(filterName),
                  selected: isSelected,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    setState(() {
                      selectedFilter = filterName;
                    });
                  },
                    selectedColor: const Color(0xFF7864C8),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF7864C8),
              onRefresh: _handleRefresh,
              child: filteredReports.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No reports found.")),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                      itemCount: filteredReports.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 15),
                      itemBuilder: (context, index) {
                        return _buildReportCard(filteredReports[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    bool isPending = report['status'] == 'Pending';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7864C8).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(height: 4, color: _getStatusColor(report['status'])),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          report['title'],
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _statusBadge(report['status']),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Text(report['location'], style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("SUBMITTED ON", style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
                          Text(report['date'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          if (isPending)
                            IconButton.filled(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditReport(
                                    initialData: {
                                      'title': report['title'],
                                      'description': report['description'],
                                      'location': report['location'],
                                      'type': report['title'].contains('Pothole') ? 'Pothole' : 'Road Damage',
                                    },
                                  )),
                                );
                              },
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF7864C8).withOpacity(0.1),
                                foregroundColor: const Color(0xFF7864C8),
                              ),
                            ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () => _showReportDetails(context, report),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7864C8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("Details"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Completed': return Colors.green;
      default: return Colors.grey;
    }
  }

  Widget _statusBadge(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(25),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Report Details", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                      _statusBadge(report['status']),
                    ],
                  ),
                  const SizedBox(height: 25),
                  
                  _detailItem(Icons.title, "Subject", report['title']),
                  _detailItem(Icons.location_on_rounded, "Location", report['location']),
                  _detailItem(Icons.calendar_today_rounded, "Submitted On", report['date']),
                  
                  const Divider(height: 40),
                  
                  Text("Description", 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Text(
                    report['description'] ?? "No description provided.",
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),
                  
                  const SizedBox(height: 25),
                  Text("Photo", 
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1)),
                  const SizedBox(height: 10),
                  Text(
                    report['photo'] ?? "No photo provided.",
                    style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                  ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF7864C8)),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}