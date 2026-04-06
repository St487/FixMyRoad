import 'package:fix_my_road/features/home/screens/issue_detail.dart';
import 'package:flutter/material.dart';
import 'package:fix_my_road/features/home/controllers/homeController.dart';
import 'package:fix_my_road/utils/myconfig.dart';

class NearbyIssuesPage extends StatelessWidget {
  final HomeController controller;
  const NearbyIssuesPage({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Colors maintained from HomePage
    const kBackground = Color.fromARGB(255, 247, 235, 255);
    const kGradientStart = Color.fromARGB(255, 251, 195, 226);
    const kGradientEnd = Color.fromARGB(255, 252, 217, 192);
    const kAccentPurple = Color.fromARGB(255, 120, 100, 200);

    return Scaffold(
      backgroundColor: kBackground,
      // Standard AppBar instead of SliverAppBar
      appBar: AppBar(
        title: const Text(
          "Nearby Issues",
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
              colors: [kGradientStart, kGradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        color: kAccentPurple,
        onRefresh: () async => await controller.initUserData(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle area
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Issues reported near your area",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Scrollable List Area
            Expanded(
              child: Builder(
                builder: (_) {
                  if (controller.locationPermissionDenied) {
                    return const _StatusMessage(
                      icon: Icons.location_off_rounded,
                      message: "Location permission not allowed",
                      color: Colors.redAccent,
                    );
                  }

                  final filteredIssues = controller.nearbyIssues
                      .where((issue) =>
                          issue['status'] == 'approved' ||
                          issue['status'] == 'in_progress')
                      .toList();

                  if (filteredIssues.isEmpty) {
                    return const _StatusMessage(
                      icon: Icons.map_outlined,
                      message: "No nearby issues found.\nBe the first to report!",
                      color: Colors.grey,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    physics: const BouncingScrollPhysics(),
                    itemCount: filteredIssues.length,
                    itemBuilder: (context, index) {
                      final issue = filteredIssues[index];
                      bool isInProgress = issue['status'] == 'in_progress';

                      return _BeautifulIssueCard(
                        issue: issue,
                        isInProgress: isInProgress,
                      );
                    },
                  );
                },
              ),
            ),
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
            onTap: () { Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => IssueDetailPage(issueId: issue['id'])),
            ); },
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
                        errorBuilder: (_, __, ___) => Image.asset(
                          "assets/default_icon.png",
                          fit: BoxFit.cover,
                        ),
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
                          issue['issue_type'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8), // Added slight spacing
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "${issue['distance']} away",
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                            const Spacer(), // Pushes the status tag to the right
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isInProgress 
                                    ? Colors.orange.withOpacity(0.12) 
                                    : Color.fromARGB(255, 120, 100, 200).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isInProgress ? "In Progress" : "Reported",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isInProgress 
                                      ? Colors.orange 
                                      : Color.fromARGB(255, 120, 100, 200),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8), // Gap before the chevron
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