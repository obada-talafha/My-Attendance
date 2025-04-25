import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'NotificationDetailsPage.dart';

class StudentNotificationsPage extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'reminder',
      'title': 'Lecture Started',
      'course': 'Computer Architecture',
      'hall': 'A2-124',
      'date': 'Apr 14, 2025',
      'unread': true,
    },
    {
      'type': 'warning',
      'title': 'Absence Warning',
      'course': 'Cryptography',
      'date': 'Apr 13, 2025',
      'unread': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F9FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.jost(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = notifications[index];

          String subtitleText = item['type'] == 'reminder'
              ? 'Your ${item['course']} lecture has started.'
              : 'You are at risk of being deprived from ${item['course']}.';

          return Container(
            decoration: BoxDecoration(
              color: item['unread'] ? const Color(0xFFEAF3FF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                String detailText;
                if (item['type'] == 'reminder') {
                  detailText =
                  "Reminder: Your ${item['course']} lecture has started. Please head to lecture hall ${item['hall']}.";
                } else {
                  detailText =
                  "Course Absence Warning!\nYou are at risk of being deprived from ${item['course']}.";
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationDetailPage(
                      title: item['title'],
                      detail: detailText,
                    ),
                  ),
                );
              },
              title: Text(
                item['title'],
                style: GoogleFonts.jost(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  subtitleText,
                  style: GoogleFonts.jost(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              trailing: Text(
                item['date'],
                style: GoogleFonts.jost(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}