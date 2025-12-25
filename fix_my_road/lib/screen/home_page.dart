import 'package:fix_my_road/support_widget/action_card.dart';
import 'package:fix_my_road/support_widget/issue_card.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color.fromARGB(255, 247, 235, 255),
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
                    'Good Morning, User!',
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
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 110,
                      child: ActionCard(
                        icon: Icons.map,
                        label: "View Map",
                        color: const Color.fromARGB(255, 204, 192, 249),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 110,
                      child: ActionCard(
                        icon: Icons.history,
                        label: "Report Status",
                        color: const Color.fromARGB(255, 252, 217, 192),
                        onTap: () {},
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
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 110),
              physics: const BouncingScrollPhysics(),
              itemCount: 5, // Max 6 cards
              itemBuilder: (context, index) {
                return IssueCard(
                  title: "Pothole on Road ${index + 1}",
                  distance: "${(index + 1) * 0.5} km away",
                  status: "Reported",
                  icon: Icons.warning_amber_rounded,
                );
              },
            ),
          ),
        ],
      ),

      
    );
  }
}