import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'CourseDetailsPage.dart'; // ✅ Create this file after

class ViewCoursesPage extends StatelessWidget {
  const ViewCoursesPage({super.key});

  final List<Map<String, dynamic>> courses = const [
    {
      'courseID': 'CS101',
      'courseName': 'Introduction to Programming',
      'sectionNumber': '1',
      'lineNumber': 'L01',
      'college': 'Engineering',
      'department': 'Computer Science',
      'creditHours': 3,
      'instructorName': 'Dr. John Doe',
      'days': 'Sun, Tue, Thu',
      'time': '10:00 - 11:30 AM',
      'students': [
        {'id': '20230001', 'name': 'Alice Johnson'},
        {'id': '20230002', 'name': 'Bob Smith'},
        {'id': '20230003', 'name': 'Charlie Brown'},
      ],
    },
    {
      'courseID': 'CS201',
      'courseName': 'Data Structures',
      'sectionNumber': '2',
      'lineNumber': 'L02',
      'college': 'Engineering',
      'department': 'Computer Science',
      'creditHours': 3,
      'instructorName': 'Dr. Jane Smith',
      'days': 'Mon, Wed',
      'time': '1:00 - 2:30 PM',
      'students': [
        {'id': '20230004', 'name': 'David Miller'},
        {'id': '20230005', 'name': 'Eva Adams'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Courses',
          style: GoogleFonts.jost(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F9FF),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final course = courses[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                course['courseName'],
                style: GoogleFonts.jost(fontWeight: FontWeight.w600),
              ),
              subtitle: Text('Instructor: ${course['instructorName']}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseDetailsPage(course: course),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
