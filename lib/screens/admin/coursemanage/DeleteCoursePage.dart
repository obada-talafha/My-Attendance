import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteCoursePage extends StatefulWidget {
  const DeleteCoursePage({super.key});

  @override
  State<DeleteCoursePage> createState() => _DeleteCoursePageState();
}

class _DeleteCoursePageState extends State<DeleteCoursePage> {
  final List<Map<String, dynamic>> _allCourses = [
    {
      'courseId': 'CS101',
      'courseName': 'Introduction to Programming',
      'sectionNumber': 1,
      'lineNumber': 'L01',
      'college': 'Engineering',
      'department': 'Computer Science',
      'creditHours': 3,
      'instructor': 'Dr. John Doe',
      'hall': 'N/A',
      'days': 'Sun, Tue, Thu',
      'time': '10:00 - 11:30 AM',
      'students': 3,
    },
    // Add more courses if needed
  ];

  List<Map<String, dynamic>> _filteredCourses = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCourses = _allCourses;
  }

  void _filterCourses(String query) {
    final filtered = _allCourses.where((course) {
      final courseName = course['courseName'].toString().toLowerCase();
      final courseId = course['courseId'].toString().toLowerCase();
      return courseName.contains(query.toLowerCase()) ||
          courseId.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredCourses = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Delete Course',
          style: GoogleFonts.jost(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCourses,
              decoration: InputDecoration(
                hintText: 'Search by Course Name or ID...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredCourses.isEmpty
                ? const Center(child: Text('No courses found.'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _filteredCourses.length,
              itemBuilder: (context, index) {
                final course = _filteredCourses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          runSpacing: 8,
                          spacing: 20,
                          children: [
                            _buildHorizontalDetail('Course ID', course['courseId']),
                            _buildHorizontalDetail('Course Name', course['courseName']),
                            _buildHorizontalDetail('Section', course['sectionNumber'].toString()),
                            _buildHorizontalDetail('Line', course['lineNumber']),
                            _buildHorizontalDetail('College', course['college']),
                            _buildHorizontalDetail('Department', course['department']),
                            _buildHorizontalDetail('Hours', course['creditHours'].toString()),
                            _buildHorizontalDetail('Instructor', course['instructor']),
                            _buildHorizontalDetail('Hall', course['hall']),
                            _buildHorizontalDetail('Days', course['days']),
                            _buildHorizontalDetail('Time', course['time']),
                            _buildHorizontalDetail('Students', course['students'].toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                            ),
                            onPressed: () => _confirmDelete(context, course['courseName']),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete Course'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalDetail(String title, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$title: ",
          style: GoogleFonts.jost(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.jost(
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String courseName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$courseName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _filteredCourses.removeWhere((course) => course['courseName'] == courseName);
                _allCourses.removeWhere((course) => course['courseName'] == courseName);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('"$courseName" deleted successfully!')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
