import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'viewCoursePage.dart';
import 'instructordrawer.dart';

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key});

  @override
  State<InstructorHomePage> createState() => _InstructorHomePageState();
}

class _InstructorHomePageState extends State<InstructorHomePage> {
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final instructorId = prefs.getString('userId');

    if (instructorId == null) {
      debugPrint("Instructor ID not found");
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://my-attendance-1.onrender.com/instructorHome?instructor_id=$instructorId'),
      );

      debugPrint('API status: ${response.statusCode}');
      debugPrint('API body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          courses = List<Map<String, dynamic>>.from(jsonData['courses']);
          isLoading = false;
        });
      } else {
        debugPrint('Failed to load courses');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      setState(() => isLoading = false);
    }
  }

  TableRow buildTableRow(String label, String value, double fontSize) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.jost(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Center(
            child: Text(
              value,
              style: GoogleFonts.jost(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildCourseCard(Map<String, dynamic> course, bool isSmallScreen) {
    final screenWidth = MediaQuery.of(context).size.width;

    final titleSize = (screenWidth / 25).clamp(14, 20).toDouble();
    final tableFontSize = (screenWidth / 35).clamp(11, 14).toDouble();
    final buttonFontSize = (screenWidth / 40).clamp(12, 16).toDouble();

    final paddingValue = isSmallScreen ? 10.0 : 14.0;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.blue, width: 1.1),
      ),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(paddingValue).copyWith(bottom: paddingValue / 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Text(
                  course["course_name"] ?? "",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.jost(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(thickness: 1),
                Table(
                  border: TableBorder.symmetric(
                    inside: const BorderSide(
                      color: Color(0xFFE0E0E0),
                      width: 0.6,
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(3),
                  },
                  children: [
                    buildTableRow("Section", course["session_number"]?.toString() ?? "", tableFontSize),
                    buildTableRow("Time", course["session_time"] ?? "", tableFontSize),
                    buildTableRow("Days", course["days"] ?? "", tableFontSize),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InstructorCoursePage(
                        courseTitle: course["course_name"] ?? "",
                        sessionNumber: int.tryParse(course["session_number"].toString()) ?? 0,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0961F5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  "View Course",
                  style: GoogleFonts.jost(
                    fontWeight: FontWeight.w600,
                    fontSize: buttonFontSize,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: isSmallScreen
          ? AppBar(
        title: Text('Instructor Home', style: GoogleFonts.jost()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      )
          : null,
      drawer: isSmallScreen ? const Instructordrawer() : null,
      body: SafeArea(
        child: Row(
          children: [
            if (!isSmallScreen)
              const SizedBox(
                width: 200,
                child: ColoredBox(color: Colors.white, child: Instructordrawer()),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : courses.isEmpty
                  ? const Center(child: Text("No courses found."))
                  : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1;
                      double aspectRatio = 2;

                      if (constraints.maxWidth > 1200) {
                        crossAxisCount = 3;
                        aspectRatio = 2.2;
                      } else if (constraints.maxWidth > 800) {
                        crossAxisCount = 2;
                        aspectRatio = 2.2;
                      }

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: aspectRatio,
                        children: courses.map((course) {
                          return buildCourseCard(course, isSmallScreen);
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
    );
  }
}
