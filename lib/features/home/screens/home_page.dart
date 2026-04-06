import 'package:fix_my_road/features/home/controllers/homeController.dart';
import 'package:fix_my_road/features/home/screens/issue_detail.dart';
import 'package:fix_my_road/features/home/screens/nearby_issue_page.dart';
import 'package:fix_my_road/features/report/screens/add_report.dart';
import 'package:fix_my_road/features/chatbot/screens/ai_chatbot.dart';
import 'package:fix_my_road/shared/support_widget/action_card.dart';
import 'package:fix_my_road/shared/support_widget/issue_card.dart';
import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigate;
  const HomePage({super.key, required this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final homeController = HomeController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = HomeController();
        controller.setGreeting();
        controller.initUserData(); 
        return controller;
      },
      child: Consumer<HomeController>(
        builder: (context, controller, _) {
          return Scaffold(
            extendBody: true,
            backgroundColor: const Color.fromARGB(255, 247, 235, 255),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 70.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AiChatbot()),
                  );
                },
                backgroundColor: const Color.fromARGB(255, 217, 163, 239),
                child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
              ),
            ),
            body: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.elliptical(140, 30), 
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 251, 195, 226),
                          Color.fromARGB(255, 252, 217, 192),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, 
                      children: [
                        Text(
                          controller.firstName == "User"
                            ? "Loading..."
                            : '${controller.greeting}, ${controller.firstName}!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Let\'s fix some roads today',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),            
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, bottom: 10.0),
                    child: Text(
                      'What would you like to do?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 0, 15.0, 15.0),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(10, 10),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 110, 
                            child: ActionCard(
                              icon: Icons.add,
                              label: "Add Report",
                              color: const Color.fromARGB(255, 248, 187, 222),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AddReport()),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 110,
                            child: ActionCard(
                              icon: Icons.map,
                              label: "View Map",
                              color: const Color.fromARGB(255, 204, 192, 249),
                              onTap: () {
                                widget.onNavigate(1);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 110,
                            child: ActionCard(
                              icon: Icons.history,
                              label: "Report Status",
                              color: const Color.fromARGB(255, 252, 217, 192),
                              onTap: () {
                                widget.onNavigate(3);
                              },
                            ),
                          ),
                        ]
                      ),
                    )
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        'Nearby Issues',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NearbyIssuesPage()),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Show All',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 120, 100, 200),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: Color.fromARGB(255, 120, 100, 200),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
          
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.initUserData(); // Reload profile + nearby issues
                    },
                    child: Builder(
                      builder: (_) {
                        if (controller.locationPermissionDenied) {
                          return const Center(
                            child: Text(
                              "Location permission not allowed",
                              style: TextStyle(fontSize: 16, color: Colors.red),
                            ),
                          );
                        } else if (controller.nearbyIssues.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          // Filter only approved and in_progress
                          final filteredIssues = controller.nearbyIssues.where((issue) =>
                            issue['status'] == 'approved' || issue['status'] == 'in_progress'
                          ).toList();

                          if (filteredIssues.isEmpty) {
                            return const Center(
                              child: Text(
                                "No nearby issues found.",
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.only(top: 10, bottom: 20),
                            itemCount: filteredIssues.length,
                            itemBuilder: (context, index) {
                              final issue = filteredIssues[index];
                              String statusText = issue['status'] == 'approved' ? 'Reported' : 'In Progress';

                              return IssueCard(
                                title: issue['issue_type'],
                                distance: "${issue['distance']} away",
                                status: statusText,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IssueDetailPage(issueId: issue['id']),
                                    ),
                                  );
                                },
                                iconWidget: Image.network(
                                  "${MyConfig.myurl}/${issue['icon']}",
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.asset(
                                    "assets/default_icon.png",
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}