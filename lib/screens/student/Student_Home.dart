import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_drawer.dart';
import 'absents_page.dart';
import 'student_notifications_page.dart';
import 'qr_scan_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final List<Map<String, dynamic>> courses = [
    {
      "title": "Computer Architecture",
      "secNo": "3",
      "lineNo": "152445",
      "days": "Sun Tue",
      "time": "10:30 - 11:30",
      "hall": "A2-124",
      "instructor": "Obada Talafha",
      "creditHours": "3",
      "absents": "3",
      "absentDates": [
        {"day": "Sunday", "date": "2025-03-01"},
        {"day": "Tuesday", "date": "2025-03-03"},
        {"day": "Sunday", "date": "2025-03-08"},
      ],
    },
    {
      "title": "Cryptography",
      "secNo": "1",
      "lineNo": "242524",
      "days": "Sun Tue",
      "time": "09:30 - 10:30",
      "hall": "A3-102",
      "instructor": "Dr. Ahmed Khalid",
      "creditHours": "3",
      "absents": "2",
      "absentDates": [
        {"day": "Tuesday", "date": "2025-02-25"},
        {"day": "Sunday", "date": "2025-03-02"},
      ],
    }
  ];

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
                  builder: (context) =>  StudentNotificationsPage(),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
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
                  child: CourseCard(course: course), // ✅ no const here!
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
              if (scannedCode != null) {
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

  const CourseCard({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
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
              absentDates: course["absentDates"],
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
  final List<Map<String, String>> absentDates;
  final String courseTitle;

  const AbsenceButton({
    Key? key,
    required this.absents,
    required this.absentDates,
    required this.courseTitle,
  }) : super(key: key);

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
                  absentDates: absentDates,
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
