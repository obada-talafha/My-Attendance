import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'instructor_course_page.dart';
import 'instructordrawer.dart';

class InstructorHomePage extends StatelessWidget {
  final List<Map<String, String>> courses = [
    {
      "title": "Computer Architecture",
      "code": "CS242",
      "section": "3",
      "time": "10:30 - 11:30",
      "days": "Sun, Tue",
    },
    {
      "title": "Cryptography",
      "code": "CS451",
      "section": "1",
      "time": "09:30 - 10:30",
      "days": "Sun, Tue",
    },
    {
      "title": "Operating Systems",
      "code": "CS332",
      "section": "2",
      "time": "11:30 - 12:30",
      "days": "Mon, Wed",
    },
    {
      "title": "AI Fundamentals",
      "code": "CS481",
      "section": "1",
      "time": "12:30 - 01:30",
      "days": "Sun, Tue",
    },
  ];

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.jost(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.jost(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      drawer: isSmallScreen ? const Instructordrawer() : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            const SizedBox(
              width: 200,
              child: ColoredBox(
                color: Colors.white,
                child: Instructordrawer(),
              ),
            ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerRight,
                  child: Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.black87),
                        onPressed: () {
                          // Handle notifications
                        },
                      ),
                      Positioned(
                        right: 11,
                        top: 11,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          int crossAxisCount = 1;
                          if (constraints.maxWidth > 1200) {
                            crossAxisCount = 3;
                          } else if (constraints.maxWidth > 800) {
                            crossAxisCount = 2;
                          }

                          return GridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2.2,
                            children: courses.map((course) {
                              return Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.blue, width: 1.1),
                                ),
                                elevation: 3,
                                shadowColor: Colors.black.withOpacity(0.08),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Center(
                                        child: Text(
                                          course["title"]!,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.jost(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Divider(thickness: 1, color: Color(0xFFE0E0E0)),
                                      const SizedBox(height: 4),
                                      Table(
                                        border: TableBorder.symmetric(
                                          inside: const BorderSide(color: Color(0xFFE0E0E0), width: 0.6),
                                        ),
                                        columnWidths: const {
                                          0: FlexColumnWidth(2),
                                          1: FlexColumnWidth(3),
                                        },
                                        children: [
                                          buildTableRow("Code", course["code"]!),
                                          buildTableRow("Section", course["section"]!),
                                          buildTableRow("Time", course["time"]!),
                                          buildTableRow("Days", course["days"]!),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => InstructorCoursePage(
                                                  courseTitle: course["title"]!,
                                                  courseId: course["code"]!,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0961F5),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24),
                                            ),
                                          ),
                                          child: Text(
                                            "View Course",
                                            style: GoogleFonts.jost(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
