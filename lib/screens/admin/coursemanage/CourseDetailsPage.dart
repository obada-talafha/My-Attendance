import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:excel/excel.dart';

class CourseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> course;
  const CourseDetailsPage({super.key, required this.course});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Map<String, dynamic> courseData;
  List<Map<String, String>> students = [
    {'name': 'Alice Johnson', 'id': 'S001'},
    {'name': 'Bob Smith', 'id': 'S002'},
    {'name': 'Charlie Brown', 'id': 'S003'},
  ];
  String searchStudent = '';

  @override
  void initState() {
    super.initState();
    courseData = Map<String, dynamic>.from(widget.course);
  }

  List<Map<String, String>> get filteredStudents {
    if (searchStudent.isEmpty) return students;
    return students.where((student) {
      final nameMatch = student['name']!.toLowerCase().contains(searchStudent.toLowerCase());
      final idMatch = student['id']!.toLowerCase().contains(searchStudent.toLowerCase());
      return nameMatch || idMatch;
    }).toList();
  }

  Future<void> _addStudent() async {
    String name = '';
    String id = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: const InputDecoration(labelText: 'Name'), onChanged: (v) => name = v),
            TextField(decoration: const InputDecoration(labelText: 'ID'), onChanged: (v) => id = v),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty && id.isNotEmpty) {
                  setState(() => students.add({'name': name, 'id': id}));
                  Navigator.pop(context);
                }
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteStudent(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to remove this student?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      setState(() => students.removeAt(index));
    }
  }

  Future<void> _exportStudentsAsExcel() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Students'];

    // Add headers
    sheet.appendRow(['Name', 'ID']);

    // Add data
    for (var student in students) {
      sheet.appendRow([student['name'], student['id']]);
    }

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/students.xlsx';
    final fileBytes = excel.save();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);

    Share.shareXFiles([XFile(filePath)], text: 'Student List Excel');
  }

  void _editCourseDetails() {
    String courseName = courseData['courseName'];
    String instructorName = courseData['instructorName'];
    String days = courseData['days'];
    String time = courseData['time'];
    String hall = courseData['hall'] ?? '';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Course Details', style: GoogleFonts.jost(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Course Name'),
                controller: TextEditingController(text: courseName),
                onChanged: (value) => courseName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Instructor Name'),
                controller: TextEditingController(text: instructorName),
                onChanged: (value) => instructorName = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Days'),
                controller: TextEditingController(text: days),
                onChanged: (value) => days = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Time'),
                controller: TextEditingController(text: time),
                onChanged: (value) => time = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Hall'),
                controller: TextEditingController(text: hall),
                onChanged: (value) => hall = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () {
                  setState(() {
                    courseData['courseName'] = courseName;
                    courseData['instructorName'] = instructorName;
                    courseData['days'] = days;
                    courseData['time'] = time;
                    courseData['hall'] = hall;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDetailCard(String title, String value) {
    return Container(
      width: 220,
      margin: const EdgeInsets.all(6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.jost(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.blueGrey)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.jost(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent]),
          ),
        ),
        title: Text('Course Details (${students.length} Students)', style: GoogleFonts.jost(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: _editCourseDetails),
          IconButton(icon: const Icon(Icons.upload_file), onPressed: _exportStudentsAsExcel),
          IconButton(icon: const Icon(Icons.person_add), onPressed: _addStudent),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCourseDetailCard('Course ID', courseData['courseID']),
                _buildCourseDetailCard('Course Name', courseData['courseName']),
                _buildCourseDetailCard('Section Number', courseData['sectionNumber']),
                _buildCourseDetailCard('Line Number', courseData['lineNumber']),
                _buildCourseDetailCard('College', courseData['college']),
                _buildCourseDetailCard('Department', courseData['department']),
                _buildCourseDetailCard('Credit Hours', courseData['creditHours'].toString()),
                _buildCourseDetailCard('Instructor', courseData['instructorName']),
                _buildCourseDetailCard('Hall', courseData['hall'] ?? 'N/A'),
                _buildCourseDetailCard('Days', courseData['days']),
                _buildCourseDetailCard('Time', courseData['time']),
                _buildCourseDetailCard('Students', students.length.toString()),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Search student by name or ID...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (v) => setState(() => searchStudent = v),
            ),
            const SizedBox(height: 16),
            filteredStudents.isEmpty
                ? Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Text('😔 No students found.', style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.w500)),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredStudents.length,
              itemBuilder: (context, index) {
                final student = filteredStudents[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(student['name']!, style: GoogleFonts.jost(fontWeight: FontWeight.bold)),
                    subtitle: Text('ID: ${student['id']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteStudent(index),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
