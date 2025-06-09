import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'student_drawer.dart';
import 'absents_page.dart';
import 'qr_scan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Course {
  final String courseName;
  final String sessionNum;
  final String studentId;
  final List<String> days; // Changed here from String to List<String>
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
    this.absents = "0",
  });

  factory Course.fromJson(Map<String, dynamic> json, String studentId) {
    return Course(
      courseName: json['course_name'],
      sessionNum: json['session_number'].toString(),
      studentId: studentId,
      days: List<String>.from(json['days'] ?? []), // Parsing the list safely
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
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('userId');

    if (studentId == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final url = Uri.parse('https://my-attendance-1.onrender.com/studentHome?student_id=$studentId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonBody = response.body;
        final decoded = jsonDecode(jsonBody);

        if (decoded['success'] == true) {
          final List<dynamic> data = decoded['courses'];
          final List<Course> loadedCourses = data
              .map((c) => Course.fromJson(c as Map<String, dynamic>, studentId))
              .toList();

          setState(() {
            courses = loadedCourses;
            isLoading = false;
          });
        } else {
          throw Exception(decoded['message'] ?? 'Failed to load courses');
        }
      } else {
        throw Exception('Failed to load courses. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading courses: $e");
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
        title: Text(
          '',
          style: GoogleFonts.jost(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: const [],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 64, color: Colors.grey),
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
            child: RefreshIndicator(
              onRefresh: loadCourses,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.9, end: 1),
                    duration: Duration(milliseconds: 500 + index * 150),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: CourseCard(course: course),
                  );
                },
              ),
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
              final prefs = await SharedPreferences.getInstance();
              final studentId = prefs.getString('userId');
              if (studentId == null) return;

              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScanPage(studentId: studentId)),
              );
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
  final Course course;

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
              course.courseName,
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
                buildTableRow("Sec No.", course.sessionNum),
                // Join the List<String> days into a comma separated string
                buildTableRow("Days", course.days.join(", ")),
                buildTableRow("Time", course.time),
                buildTableRow("Hall", course.hall),
                buildTableRow("Instructor", course.instructor),
                buildTableRow("Credit Hours", course.creditHours),
              ],
            ),
            const SizedBox(height: 10),
            AbsenceButton(
              absents: course.absents,
              courseName: course.courseName,
              sessionNum: course.sessionNum,
              studentId: course.studentId,
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
            style: GoogleFonts.jost(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class AbsenceButton extends StatelessWidget {
  final String absents;
  final String courseName;
  final String sessionNum;
  final String studentId;

  const AbsenceButton({
    super.key,
    required this.absents,
    required this.courseName,
    required this.sessionNum,
    required this.studentId,
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AbsentsPage(
                  courseTitle: courseName,
                  sessionNum: int.parse(sessionNum),
                  studentId: studentId,
                ),
              ),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Absents",
                style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 14,
                child: Text(
                  absents,
                  style: GoogleFonts.jost(color: Color(0xFF0961F5), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
