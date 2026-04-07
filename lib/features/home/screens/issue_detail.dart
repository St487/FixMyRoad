import 'package:fix_my_road/features/home/controllers/detailController.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/utils/app_text.dart';
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
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;
    final controller = context.watch<DetailController>();
    const kPrimaryColor = Color(0xFF7864C8);
    const kBgColor = Color(0xFFF8F9FE);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setLanguage(lang);
    });

    if (controller.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    if (controller.errorMessage != null || controller.issue == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: Center(child: Text(controller.errorMessage ?? AppText.issueNotFound(lang))),
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [_buildStatusChip(issue['status'], lang)],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            AppText.issueType(issue['issue_type'], lang).toUpperCase(),
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
                          Text(AppText.resolutionJourney(lang), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          _buildModernStepper(issue['status'], lang),
                          const SizedBox(height: 35),
                          Row(
                            children: [
                              _buildSummaryCard(AppText.reportedDate(lang), _formatDate(issue['created_at'], lang), Icons.event_note, Colors.blue),
                              const SizedBox(width: 15),
                              _buildSummaryCard(AppText.priority(lang), "Standard", Icons.bolt, Colors.orange),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Text(AppText.description(lang), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              issue['description'] ?? AppText.noDescription(lang),
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
                                    issue['location_text'] ?? AppText.locationDetailUnavailable(lang),
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

           Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: 65,
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
                      onTap: () {
                        // TODO: navigation
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
                                  AppText.navigateToLocation(lang).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppText.openInMaps(lang),
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
            ),
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

  Widget _buildStatusChip(String status, bool lang) {
    bool isInProgress = status == 'in_progress';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isInProgress ? Colors.orange.withOpacity(0.12) : const Color(0xFF7864C8).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isInProgress ? AppText.statusInProgress(lang) : AppText.statusReported(lang),
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

  Widget _buildModernStepper(String status, bool lang) {
    final stages = ['approved', 'in_progress', 'completed'];
    String stageText;
    int currentIdx = stages.indexOf(status);

    return Row(
      children: List.generate(stages.length, (i) {
        bool isPassed = i <= currentIdx;
        switch (stages[i]) {
          case 'approved':
            stageText = AppText.stageApproved(lang);
            break;
          case 'in_progress':
            stageText = AppText.stageInProgress(lang);
            break;
          case 'completed':
            stageText = AppText.stageCompleted(lang);
            break;
          default:
            stageText = stages[i];
        }
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
                stageText,
                style: TextStyle(fontSize: 10, fontWeight: isPassed ? FontWeight.bold : FontWeight.normal, color: isPassed ? Colors.black : Colors.grey),
              )
            ],
          ),
        );
      }),
    );
  }

  static String _formatDate(String dateStr, bool lang) {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(dateStr));
    } catch (e) {
      return AppText.unknownDate(lang);
    }
  }
}