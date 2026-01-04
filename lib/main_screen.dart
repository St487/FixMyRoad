import 'package:fix_my_road/screen/add_report.dart';
import 'package:fix_my_road/screen/home_page.dart';
import 'package:fix_my_road/screen/profile.dart';
import 'package:fix_my_road/screen/report_status.dart';
import 'package:fix_my_road/screen/view_map.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  int _selectedIndex = 0;

  // The primary color from your design
  final Color primaryPurple = const Color(0xFF7864C8);
  final Color lightPurple = const Color(0xFFD6C6FF);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BottomBar(
        fit: StackFit.expand,
        borderRadius: BorderRadius.circular(500),
        duration: const Duration(milliseconds: 500),
        curve: Curves.decelerate,
        showIcon: true,
        width: MediaQuery.of(context).size.width * 0.9, 
        barColor: Colors.white,
        start: 2,
        end: 0,
        offset: 15,
        barAlignment: Alignment.bottomCenter,
        iconHeight: 35,
        iconWidth: 35,
        reverse: false,
        hideOnScroll: true,
        scrollOpposite: false,
        
        barDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(500),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),

        icon: (width, height) => Center(
          child: Icon(
            Icons.arrow_upward_rounded,
            color: primaryPurple,
            size: width,
          ),
        ),

        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            TabBar(
              dividerColor: Colors.transparent,
              controller: tabController,
              indicatorColor: Colors.transparent, 
              labelColor: primaryPurple,
              unselectedLabelColor: Colors.grey.shade400,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              indicatorSize: TabBarIndicatorSize.label,
              indicator: UnderlineTabIndicator(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(
                  color: primaryPurple,
                  width: 4,
                ),
                insets: const EdgeInsets.symmetric(horizontal: 20),
              ),
              tabs: const [
                Tab(icon: Icon(Icons.home_rounded, size: 28)),
                Tab(icon: Icon(Icons.map_rounded, size: 28)),
                Tab(child: SizedBox(width: 40)), 
                Tab(icon: Icon(Icons.list_alt_rounded, size: 28)),
                Tab(icon: Icon(Icons.person_rounded, size: 28)),
              ],
            ),
            Positioned(
              top: -20,
              child: Container(
                width: 60, 
                height: 60,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddReport()),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: lightPurple,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: lightPurple.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        body: (context, controller) => TabBarView(
          controller: tabController,
          dragStartBehavior: DragStartBehavior.down,
          physics: const BouncingScrollPhysics(),
          children: [
            HomePage(
              onNavigate: (index) {
                tabController.animateTo(index);
              },
            ), 
            ViewMap(),
            AddReport(),
            ReportStatus(),
            const ProfileScreen(),
          ],
        ),
      ),
    );
  }
}