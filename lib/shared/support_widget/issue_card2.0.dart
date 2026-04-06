import 'package:fix_my_road/utils/myconfig.dart';
import 'package:flutter/material.dart';

class BeautifulIssueCard extends StatelessWidget {
  final dynamic issue;
  final bool isInProgress;

  const BeautifulIssueCard({
    super.key,
    required this.issue, 
    required this.isInProgress
  });

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
            onTap: () {  },
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
                                    ? const Color.fromARGB(255, 255, 230, 213) 
                                    : const Color(0xFFFFD5E5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isInProgress ? "In Progress" : "Reported",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isInProgress 
                                      ? const Color.fromARGB(255, 180, 125, 70) 
                                      : const Color.fromARGB(255, 180, 70, 120),
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