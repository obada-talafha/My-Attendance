import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'student_drawer.dart';
import 'absents_page.dart';
import 'student_notifications_page.dart';
import 'qr_scan_page.dart';

// Updated Course model
class Course {
  final String courseName;
  final String sessionNum;
  final String studentId;
  final String days;
  final String time;
  final String hall;
  final String creditHours;
  final String instructor;
  final String absents;

  Course({
    required this.courseName,
    required this.sessionNum,
    required this.studentId,
    required this.days,
    required this.time,
    required this.hall,
    required this.creditHours,
    required this.instructor,
    required this.absents,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseName: json['course_name'],
      sessionNum: json['session_number'].toString(),
      studentId: json['student_id'].toString(),
      days: json['days'],
      time: json['session_time'],
      hall: json['session_location'],
      creditHours: json['credit_hours'].toString(),
      instructor: json['instructor_name'] ?? 'N/A',
      absents: json['absents'].toString(),
    );
  }
}

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  List<Course> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    final studentId = '155349'; // Replace with actual logged-in student ID
    try {
      final url = Uri.parse('https://my-attendance-1.onrender.com/studentHome?student_id=$studentId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List data = jsonData['courses'];
        final List<Course> loadedCourses = data.map((c) => Course.fromJson(c)).toList();
        setState(() {
          courses = loadedCourses;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load courses');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error: $e");
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const StudentDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentNotificationsPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No registered courses found.',
              style: GoogleFonts.jost(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 24),
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.9, end: 1),
                  duration: Duration(milliseconds: 500 + index * 150),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: CourseCard(course: {
                    "title": course.courseName,
                    "secNo": course.sessionNum,
                    "lineNo": course.studentId,
                    "days": course.days,
                    "time": course.time,
                    "hall": course.hall,
                    "instructor": course.instructor,
                    "creditHours": course.creditHours,
                    "absents": course.absents,
                  }),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF0961F5),
        child: SizedBox(
          width: double.infinity,
          height: 60,
          child: TextButton(
            onPressed: () async {
              final scannedCode = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QRScanPage()),
              );
              if (scannedCode != null && kDebugMode) {
                print("Scanned QR Code: $scannedCode");
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  "Register Attendance",
                  style: GoogleFonts.jost(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.2),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              course["title"],
              textAlign: TextAlign.center,
              style: GoogleFonts.jost(
                fontSize: isSmallScreen ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(thickness: 1.2, color: Color(0xFFE8F1FF)),
            Table(
              border: TableBorder.all(
                color: const Color(0xFFE8F1FF),
                width: 1.2,
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                buildTableRow("Sec No.", course["secNo"]),
                buildTableRow("Line No.", course["lineNo"]),
                buildTableRow("Days", course["days"]),
                buildTableRow("Time", course["time"]),
                buildTableRow("Hall", course["hall"]),
                buildTableRow("Instructor", course["instructor"]),
                buildTableRow("Credit Hours", course["creditHours"]),
              ],
            ),
            const SizedBox(height: 10),
            AbsenceButton(
              absents: course["absents"],
              courseTitle: course["title"],
            ),
          ],
        ),
      ),
    );
  }

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class AbsenceButton extends StatelessWidget {
  final String absents;
  final String courseTitle;

  const AbsenceButton({
    super.key,
    required this.absents,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 256,
        height: 53,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0961F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AbsentsPage(
                  absentDates: [], // Placeholder for now
                  courseTitle: courseTitle,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Absents",
                style: GoogleFonts.jost(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 14,
                child: Text(
                  absents,
                  style: GoogleFonts.jost(
                    color: const Color(0xFF0961F5),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
