import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManualAttendancePage extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final int sessionNumber;
  final DateTime selectedDate;

  const ManualAttendancePage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.sessionNumber,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _ManualAttendancePageState createState() => _ManualAttendancePageState();
}

class _ManualAttendancePageState extends State<ManualAttendancePage> {
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final url = Uri.parse(
      'https://my-attendance-1.onrender.com/manualAttendance/${widget.courseId}/${widget.sessionNumber}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          students = data
              .asMap()
              .entries
              .map((entry) => {
            "no": (entry.key + 1).toString().padLeft(2, '0'),
            "name": entry.value["student_name"],
            "stNo": entry.value["student_id"].toString(),
            "absNo": entry.value["absence_count"] ?? 0,
            "isPresent": entry.value["is_present"] ?? false,
          })
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students');
      }
    } catch (e) {
      print('Error fetching students: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> updateAttendance(String studentId, bool isPresent) async {
    final url = Uri.parse('https://my-attendance-1.onrender.com/api/manual-attendance/save');

    // Prepare the students list for the API payload.
    final List<Map<String, dynamic>> updatedStudents = students.map((student) {
      return {
        "student_id": student["stNo"],
        "is_present": student["isPresent"],
      };
    }).toList();

    final body = {
      "course_name": widget.courseId,
      "session_number": widget.sessionNumber,
      "session_date": DateFormat('yyyy-MM-dd').format(widget.selectedDate),
      "students": updatedStudents,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update attendance');
      }
    } catch (e) {
      print('Error updating attendance: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6FAFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Manual Attendance",
          style: GoogleFonts.jost(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${widget.courseTitle} | $dateStr",
              style:
              GoogleFonts.jost(fontSize: 14, color: Colors.black54),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Table(
                  border: TableBorder.all(color: const Color(0xFFE8F1FF)),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(2),
                    4: FlexColumnWidth(2),
                  },
                  children: [
                    _buildTableHeader(),
                    for (var student in students) _buildTableRow(student),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: Color(0xFFE8F1FF)),
      children: [
        _buildHeaderCell("#NO"),
        _buildHeaderCell("Student Name"),
        _buildHeaderCell("#St.No"),
        _buildHeaderCell("#Abs.No"),
        _buildHeaderCell("Status"),
      ],
    );
  }

  TableRow _buildTableRow(Map<String, dynamic> student) {
    Color? bgColor;
    if (student["absNo"] >= 10) {
      bgColor = Colors.redAccent.withOpacity(0.3);
    } else if (student["absNo"] >= 9) {
      bgColor = Colors.yellowAccent.withOpacity(0.3);
    }

    return TableRow(
      decoration: bgColor != null ? BoxDecoration(color: bgColor) : null,
      children: [
        _buildCell(student["no"], bold: true),
        _buildCell(student["name"], color: Colors.blueAccent, bold: true),
        _buildCell(student["stNo"]),
        _buildCell(student["absNo"].toString()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Switch(
            value: student["isPresent"],
            onChanged: (bool value) {
              setState(() {
                if (!value && student["isPresent"]) {
                  student["absNo"] += 1;
                } else if (value &&
                    !student["isPresent"] &&
                    student["absNo"] > 0) {
                  student["absNo"] -= 1;
                }
                student["isPresent"] = value;
              });
              // Update the attendance for all students at once
              updateAttendance(student["stNo"], value);
            },
            activeColor: Colors.green,
            inactiveTrackColor: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.jost(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCell(String text, {Color? color, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.jost(
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black,
        ),
      ),
    );
  }
}
