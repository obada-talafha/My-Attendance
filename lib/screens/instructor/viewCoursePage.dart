import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'TakeAttendanceMethodPage.dart';
import 'ViewAttendanceRecordPage.dart';

class InstructorCoursePage extends StatefulWidget {
  final String courseTitle;
  final int sessionNumber;

  const InstructorCoursePage({
    super.key,
    required this.courseTitle,
    required this.sessionNumber,
  });

  @override
  State<InstructorCoursePage> createState() => _InstructorCoursePageState();
}

class _InstructorCoursePageState extends State<InstructorCoursePage> {
  DateTime selectedDate = DateTime.now();

  void _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025), // Prevent past dates
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final bool isToday = DateUtils.isSameDay(selectedDate, DateTime.now());

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
          widget.courseTitle,
          style: GoogleFonts.jost(
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose Date Of Attendance:",
                  style: GoogleFonts.jost(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _pickDate(context),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        const BoxShadow(
                          color: Color.fromRGBO(128, 128, 128, 0.15),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.black54),
                        const SizedBox(width: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            isToday ? "$formattedDate (Today)" : formattedDate,
                            key: ValueKey(formattedDate),
                            style: GoogleFonts.jost(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildMenuButton(
                  title: "Take Attendance",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TakeAttendanceMethodPage(
                          courseTitle: widget.courseTitle,
                          selectedDate: selectedDate,
                          sessionNumber: widget.sessionNumber,                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildMenuButton(
                  title: "View Attendance Records",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewAttendancePage(
                          courseTitle: widget.courseTitle,
                          selectedDate: selectedDate,
                          sessionNumber: widget.sessionNumber,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required String title,
    required VoidCallback onTap,
  }) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: isSmallScreen ? 16 : 20,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            const BoxShadow(
              color: Color.fromRGBO(128, 128, 128, 0.12),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.jost(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }
}
