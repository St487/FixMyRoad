import 'package:fix_my_road/features/report/controllers/report.dart';
import 'package:fix_my_road/features/report/screens/edit_report.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportStatus extends StatefulWidget {
  const ReportStatus({super.key});

  @override
  State<ReportStatus> createState() => _ReportStatusState();
}

class _ReportStatusState extends State<ReportStatus> {
  String selectedFilter = 'All';
  bool sortAsc = false; // ✅ sort order flag

  final List<String> filters = [
    'All', 
    'Pending', 
    'Approved',  
    'In Progress', 
    'Rejected',  
    'Completed'
  ];

  final Map<String, IconData> filterIcons = {
    'All': Icons.grid_view_rounded,
    'Pending': Icons.schedule_rounded,
    'Approved': Icons.thumb_up_alt_rounded,
    'In Progress': Icons.pending_actions_rounded,
    'Rejected': Icons.thumb_down_alt_rounded,
    'Completed': Icons.check_circle_outline_rounded,
  };

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final report = context.read<ReportController>();
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('user_id');

    if (userId != null) {
      await report.getReports(userId);
    }
  }

  String formatStatus(String status, bool lang) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppText.pending(lang);
      case 'approved':
        return AppText.approved(lang);
      case 'in_progress':
      case 'in progress':
        return AppText.inProgress(lang);
      case 'rejected':
        return AppText.rejected(lang);
      case 'completed':
        return AppText.completed(lang);
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
      case 'Menunggu':
        return Colors.orange;
      case 'Approved':
      case 'Diluluskan':
        return Colors.teal;
      case 'In Progress':
      case 'Dalam Proses': 
        return Colors.blue;
      case 'Rejected':
      case 'Ditolak':
        return Colors.red;
      case 'Completed':
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
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

  Future<void> _handleRefresh() async {
    await _loadReports();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;

    final reportController = context.watch<ReportController>();
    final reports = reportController.reports;
    
    // Filter reports
    final filteredReports = selectedFilter == 'All'
        ? reports
        : reports.where((r) {
            String status = (r['status'] ?? "").toString().toLowerCase();
            String filter = selectedFilter.toLowerCase();
            if (filter == "in progress") filter = "in_progress";
            return status == filter;
          }).toList();

    // Sort reports by title (asc/desc)
    filteredReports.sort((a, b) {
      final aDate = DateTime.tryParse(a['created_at'] ?? "") ?? DateTime(2000);
      final bDate = DateTime.tryParse(b['created_at'] ?? "") ?? DateTime(2000);

      return sortAsc
          ? aDate.compareTo(bDate)
          : bDate.compareTo(aDate);
    });

    String getFilterLabel(String key, bool lang) {
      switch (key) {
        case "All": return AppText.all(lang);
        case "Pending": return AppText.pending(lang);
        case "Approved": return AppText.approved(lang);
        case "In Progress": return AppText.inProgress(lang);
        case "Rejected": return AppText.rejected(lang);
        case "Completed": return AppText.completed(lang);
        default: return key;
      }
    }
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 235, 255),
      appBar: AppBar(
        title: Text(AppText.reportStatus(lang), style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(sortAsc ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                sortAsc = !sortAsc; // toggle sort order
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
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
                    label: Text(getFilterLabel(filterName, lang)),
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
                      children: [
                        SizedBox(height: 200),
                        Center(child: Text(AppText.noReports(lang))),
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
    bool isPending = report['status'] == 'pending';
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;

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
            Container(height: 4, color: _getStatusColor(formatStatus(report['status'], lang))),
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
                      _statusBadge(formatStatus(report['status'], lang)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          report['location'] ?? "",
                          style: TextStyle(color: Colors.grey.shade600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                          Text(AppText.submittedOn(lang).toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.grey, letterSpacing: 1)),
                          Text(report['date'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      Row(
                        children: [
                          if (isPending)
                            IconButton.filled(
                              onPressed: () async {
                                final updated = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditReport(
                                      reportId: report['id'] is int 
                                          ? report['id'] 
                                          : int.parse(report['id'].toString()),
                                    ),
                                  )
                                );

                                if (updated == true) {
                                  _loadReports();
                                }
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
                            child: Text(AppText.details(lang)),
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

  // Remaining detail modal and image view code (same as your previous implementation)
  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    List<String> photos = List<String>.from(report['photos'] ?? []);
    final languageProvider = context.read<LanguageProvider>();
    final lang = languageProvider.isEnglish;

    String capitalizeWords(String s) {
      return s
          .split(' ')
          .map((word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase())
          .join(' ');
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // drag handle
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
                    controller: scrollController,
                    padding: const EdgeInsets.all(25),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              capitalizeWords(
                                AppText.issueType(report['issue_type'], lang),
                              ),
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _statusBadge(
                            formatStatus(report['status'] ?? "", lang),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      _detailItem(
                        Icons.title,
                        AppText.title(lang),
                        report['title'] ?? "",
                      ),
                      _detailItem(
                        Icons.location_on_rounded,
                        AppText.location(lang),
                        report['location'] ?? "",
                      ),
                      _detailItem(
                        Icons.calendar_today_rounded,
                        AppText.submittedOn(lang),
                        report['date'] ?? "",
                      ),

                      const Divider(height: 40),

                      // Description
                      Text(
                        AppText.description(lang),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        report['description'] ??
                            AppText.noDescription(lang),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Photos
                      Text(
                        AppText.photos(lang),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),

                      photos.isNotEmpty
                          ? SizedBox(
                              height: 120,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: photos.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  String photoUrl = photos[index];
                                  return GestureDetector(
                                    onTap: () =>
                                        _showFullImage(context, photoUrl),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        photoUrl,
                                        width: 120,
                                        height: 120,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 120,
                                            height: 120,
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Text(
                              AppText.noPhoto(lang),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(10),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: Image.network(imageUrl),
          ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis, 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}