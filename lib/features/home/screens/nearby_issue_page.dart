// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:fix_my_road/features/home/screens/issue_detail.dart';
import 'package:fix_my_road/provider/language_provider.dart';
import 'package:fix_my_road/utils/app_text.dart';
import 'package:fix_my_road/utils/locationPermission.dart';
import 'package:flutter/material.dart';
import 'package:fix_my_road/features/home/controllers/homeController.dart';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NearbyIssuesPage extends StatefulWidget {
  const NearbyIssuesPage({super.key});

  @override
  State<NearbyIssuesPage> createState() => _NearbyIssuesPageState();
}

class _NearbyIssuesPageState extends State<NearbyIssuesPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final homeController = Provider.of<HomeController>(context, listen: false);
      
      // 1. Check location permission
      bool granted = await LocationPermissionHandler.checkAndRequest(context);
      if (!granted) {
        // Mark in controller that permission is denied
        homeController.locationPermissionDenied = true;
      } else {
        // 2. Initialize user data if permission granted
        await homeController.initUserData();
      }

      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final lang = languageProvider.isEnglish;
    const kBackground = Color.fromARGB(255, 247, 235, 255);
    const kGradientStart = Color.fromARGB(255, 251, 195, 226);
    // const kGradientEnd = Color.fromARGB(255, 252, 217, 192);
    const kAccentPurple = Color.fromARGB(255, 120, 100, 200);

    final homeController = Provider.of<HomeController>(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(
          AppText.nearbyIssues(lang),
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kGradientStart,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kGradientStart, kBackground],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator(
        color: kAccentPurple,
        onRefresh: () async {
          bool granted = await LocationPermissionHandler.checkAndRequest(context);
          setState(() {
            homeController.locationPermissionDenied = !granted;
          });
          if (granted) await homeController.initUserData();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 20),
          children: [
            if (homeController.locationPermissionDenied)
              _StatusMessage(
                icon: Icons.location_off_rounded,
                message: AppText.locationPermissionDenied(lang),
                color: Colors.redAccent,
              )
            else if (homeController.filteredNearbyIssues.isEmpty)
              _StatusMessage(
                icon: Icons.map_outlined,
                message: AppText.beTheFirstToReport(lang),
                color: Colors.grey,
              )
            else
              ...homeController.filteredNearbyIssues.map((issue) {
                bool isInProgress = issue['status'] == 'in_progress';
                return _BeautifulIssueCard(
                  issue: issue,
                  isInProgress: isInProgress,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _BeautifulIssueCard extends StatelessWidget {
  final dynamic issue;
  final bool isInProgress;

  const _BeautifulIssueCard({required this.issue, required this.isInProgress});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>().isEnglish; // reactive

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => IssueDetailPage(issueId: issue['id']),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 245, 240, 255),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        "${MyConfig.myurl}/${issue['icon']}",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Image.asset("assets/default_icon.jpg", fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                         AppText.issueType(issue['issue_type'], lang),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "${issue['distance']} ${AppText.away(lang)}", // now reactive
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isInProgress
                                    ? Colors.orange.withOpacity(0.12)
                                    : const Color.fromARGB(255, 120, 100, 200)
                                        .withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isInProgress
                                  ? AppText.statusInProgress(lang)
                                  : AppText.statusReported(lang),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isInProgress
                                      ? Colors.orange
                                      : const Color.fromARGB(255, 120, 100, 200),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _StatusMessage({required this.icon, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: color.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}