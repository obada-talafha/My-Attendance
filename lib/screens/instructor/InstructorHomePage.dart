import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'instructor_course_page.dart';
import 'instructordrawer.dart';

class InstructorHomePage extends StatefulWidget {
  const InstructorHomePage({super.key}); // Using super parameter here

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
      // You can use debugPrint for development logs instead of print
      debugPrint("Instructor ID not found");
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'https://my-attendance-1.onrender.com/instructorHome?instructor_id=$instructorId',
        ),
      );

      // Use debugPrint instead of print for debugging
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
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching courses: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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
      appBar:
          isSmallScreen
              ? AppBar(
                title: Text('Instructor Home', style: GoogleFonts.jost()),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 0,
              )
              : null,
      drawer: isSmallScreen ? const Instructordrawer() : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            const SizedBox(
              width: 200,
              child: ColoredBox(color: Colors.white, child: Instructordrawer()),
            ),
          Expanded(
            child: Column(
              children: [
                if (!isSmallScreen)
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.centerRight,
                    child: Stack(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.black87,
                          ),
                          onPressed: () {},
                        ),
                        Positioned(
                          right: 11,
                          top: 11,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              // Using Color with withAlpha() to avoid .withOpacity
                              color: const Color(0xFFFF0000).withAlpha(255),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child:
                      isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : courses.isEmpty
                          ? const Center(child: Text("No courses found."))
                          : SingleChildScrollView(
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
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 2.2,
                                    children:
                                        courses.map((course) {
                                          return Card(
                                            color: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: const BorderSide(
                                                color: Colors.blue,
                                                width: 1.1,
                                              ),
                                            ),
                                            elevation: 3,
                                            shadowColor: Colors.black.withAlpha(
                                              20,
                                            ), // updated from withOpacity(0.08)
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                10.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Center(
                                                    child: Text(
                                                      course["course_name"] ??
                                                          "",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: GoogleFonts.jost(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  const Divider(
                                                    thickness: 1,
                                                    color: Color(0xFFE0E0E0),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Table(
                                                    border:
                                                        TableBorder.symmetric(
                                                          inside:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFFE0E0E0,
                                                                ),
                                                                width: 0.6,
                                                              ),
                                                        ),
                                                    columnWidths: const {
                                                      0: FlexColumnWidth(2),
                                                      1: FlexColumnWidth(3),
                                                    },
                                                    children: [
                                                      buildTableRow(
                                                        "Section",
                                                        course["session_number"]
                                                            .toString(),
                                                      ),
                                                      buildTableRow(
                                                        "Time",
                                                        course["session_time"] ??
                                                            "",
                                                      ),
                                                      buildTableRow(
                                                        "Days",
                                                        course["days"] ?? "",
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (
                                                                  _,
                                                                ) => InstructorCoursePage(
                                                                  courseTitle:
                                                                      course["course_name"] ??
                                                                      "",
                                                                  courseId:
                                                                      course["course_code"] ??
                                                                      "",
                                                                  sessionNumber: int.tryParse(course["session_number"].toString()) ?? 0,

                                                                ),
                                                          ),
                                                        );
                                                        ;
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            const Color(
                                                              0xFF0961F5,
                                                            ),
                                                        foregroundColor:
                                                            Colors.white,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 20,
                                                              vertical: 10,
                                                            ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                24,
                                                              ),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "View Course",
                                                        style: GoogleFonts.jost(
                                                          fontWeight:
                                                              FontWeight.w600,
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
