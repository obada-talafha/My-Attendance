import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'QrAttendancePage.dart';  // Make sure the relative path is correct
import 'ManualAttendancePage.dart'; // Make sure this path is correct

class TakeAttendanceMethodPage extends StatelessWidget {
  final DateTime selectedDate;
  final String courseTitle;
  final String courseId;
  final int sessionNumber;
  const TakeAttendanceMethodPage({
    Key? key,
    required this.selectedDate,
    required this.courseTitle,
    required this.courseId,
    required this.sessionNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F8FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Choose Attendance Method',
          style: GoogleFonts.jost(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 32, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMethodCard(
                    context,
                    icon: Icons.qr_code_scanner,
                    title: "QR Code & Face Recognition",
                    subtitle: "Scan student QR codes with live face detection",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QrAttendancePage(
                            courseId: courseId,
                            courseTitle: courseTitle,
                            selectedDate: selectedDate,
                            sessionNumber: sessionNumber,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildMethodCard(
                    context,
                    icon: Icons.edit,
                    title: "Manual Attendance",
                    subtitle: "Mark students manually for this session",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManualAttendancePage(
                            courseId: courseId,
                            courseTitle: courseTitle,
                            selectedDate: selectedDate,
                            sessionNumber: sessionNumber,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 40 : 48, color: const Color(0xFF0961F5)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.jost(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.jost(
                      fontSize: isSmallScreen ? 14 : 15,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black87),
          ],
        ),
      ),
    );
  }
}
