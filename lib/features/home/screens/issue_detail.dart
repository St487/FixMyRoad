import 'package:fix_my_road/features/home/controllers/detailController.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fix_my_road/utils/myconfig.dart';

class IssueDetailPage extends StatelessWidget {
  final int issueId;

  const IssueDetailPage({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DetailController(issueId: issueId)..init(),
      child: const _IssueDetailView(),
    );
  }
}

class _IssueDetailView extends StatelessWidget {
  const _IssueDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DetailController>();
    const kPrimaryColor = Color(0xFF7864C8);
    const kBgColor = Color(0xFFF8F9FE);

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    if (controller.errorMessage != null || controller.issue == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: Text(controller.errorMessage ?? "Failed to load issue details")),
      );
    }

    final issue = controller.issue!;
    final photos = controller.photos;

    return Scaffold(
      backgroundColor: kBgColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 380,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        onPageChanged: controller.setCurrentImageIndex,
                        itemCount: photos.isEmpty ? 1 : photos.length,
                        itemBuilder: (_, index) {
                          return photos.isEmpty
                              ? Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                )
                              : Image.network(
                                  "${MyConfig.myurl}/${photos[index]}",
                                  fit: BoxFit.cover,
                                );
                        },
                      ),
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.transparent,
                                Colors.black.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (photos.length > 1)
                        Positioned(
                          bottom: 50,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${controller.currentImageIndex + 1} / ${photos.length}",
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -35),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kBgColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(25, 30, 25, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [_buildStatusChip(issue['status'])],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            (issue['issue_type'] ?? "Road Issue").toString().toUpperCase(),
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          if (issue['title'] != null && issue['title'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                issue['title'],
                                style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
                              ),
                            ),
                          const SizedBox(height: 20),
                          const Text("Resolution Journey", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildModernStepper(issue['status']),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              _buildSummaryCard("Reported Date", _formatDate(issue['created_at']), Icons.event_note, Colors.blue),
                              const SizedBox(width: 15),
                              _buildSummaryCard("Priority", "Standard", Icons.bolt, Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 30),
                          const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              issue['description'] ?? "No description provided",
                              style: TextStyle(color: Colors.grey[800], height: 1.6, fontSize: 15),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Color(0xFFFFE8E8),
                                  radius: 18,
                                  child: Icon(Icons.location_on, color: Colors.redAccent, size: 20),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    issue['location_text'] ?? "Location details unavailable",
                                    style: const TextStyle(fontSize: 14, height: 1.4, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    bool isInProgress = status == 'in_progress';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isInProgress ? Colors.orange.withOpacity(0.12) : const Color(0xFF7864C8).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isInProgress ? "In Progress" : "Reported",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isInProgress ? Colors.orange : const Color(0xFF7864C8),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accent, size: 22),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildModernStepper(String status) {
    final stages = ['approved', 'in_progress', 'completed'];
    int currentIdx = stages.indexOf(status);

    return Row(
      children: List.generate(stages.length, (i) {
        bool isPassed = i <= currentIdx;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: Container(height: 3, color: i == 0 ? Colors.transparent : (isPassed ? const Color(0xFF7864C8) : Colors.grey[200]))),
                  Icon(isPassed ? Icons.check_circle : Icons.circle_outlined, color: isPassed ? const Color(0xFF7864C8) : Colors.grey[300], size: 28),
                  Expanded(child: Container(height: 3, color: i == stages.length - 1 ? Colors.transparent : (i < currentIdx ? const Color(0xFF7864C8) : Colors.grey[200]))),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                stages[i].replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: isPassed ? FontWeight.bold : FontWeight.normal, color: isPassed ? Colors.black : Colors.grey),
              )
            ],
          ),
        );
      }),
    );
  }

  static String _formatDate(String dateStr) {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return "Unknown Date";
    }
  }
}