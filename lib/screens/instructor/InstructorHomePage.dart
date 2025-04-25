import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'instructor_course_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Welcome, Instructor",
          style: GoogleFonts.jost(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Determine how many columns to show based on width
            int crossAxisCount = 1;
            if (constraints.maxWidth > 900) {
              crossAxisCount = 3;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 2;
            }

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: courses.map((course) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InstructorCoursePage(
                          courseTitle: course["title"]!,
                          courseId: course["code"]!, // Pass the course ID
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course["title"]!,
                            style: GoogleFonts.jost(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Code: ${course["code"]} | Section: ${course["section"]}",
                            style: GoogleFonts.jost(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Time: ${course["time"]} | Days: ${course["days"]}",
                            style: GoogleFonts.jost(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
