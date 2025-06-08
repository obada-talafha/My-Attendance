import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewAttendancePage extends StatefulWidget {
  final DateTime selectedDate;
  final String courseTitle;
  final int sessionNumber;

  const ViewAttendancePage({
    Key? key,
    required this.selectedDate,
    required this.courseTitle,
    required this.sessionNumber,
  }) : super(key: key);

  @override
  _ViewAttendanceRecordState createState() => _ViewAttendanceRecordState();
}

class _ViewAttendanceRecordState extends State<ViewAttendancePage> {
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool isLoading = true;
  bool hasChanges = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    final url = Uri.parse(
      'https://my-attendance-1.onrender.com/ViewAttendanceRecord/${widget.courseTitle}/${widget.sessionNumber}',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final Set<String> addedIds = {};
        final List<Map<String, dynamic>> uniqueStudents = [];

        for (var student in data) {
          final id = student["student_id"].toString();
          if (!addedIds.contains(id)) {
            addedIds.add(id);
            uniqueStudents.add({
              "no": (uniqueStudents.length + 1).toString().padLeft(2, '0'),
              "name": student["student_name"],
              "stNo": id,
              "absNo": student["absence_count"] ?? 0,
              "isPresent": student["is_present"],
            });
          }
        }

        setState(() {
          students = uniqueStudents;
          filteredStudents = List.from(uniqueStudents);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load students (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('❌ Error: $e');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error loading students: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void filterStudents(String query) {
    setState(() {
      searchQuery = query;
      filteredStudents = students.where((student) {
        final name = student["name"].toString().toLowerCase();
        final stNo = student["stNo"].toString().toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || stNo.contains(q);
      }).toList();
    });
  }

  Future<void> updateAllAttendance() async {
    final url = Uri.parse('https://my-attendance-1.onrender.com/ViewAttendanceRecord/save');
    final body = {
      "course_name": widget.courseTitle,
      "session_number": widget.sessionNumber,
      "session_date": DateFormat('yyyy-MM-dd').format(widget.selectedDate),
      "students": students.map((s) => {
        "student_id": s["stNo"],
        "is_present": s["isPresent"],
      }).toList(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        if (jsonBody["success"] == true || jsonBody["message"] == "Attendance saved successfully!") {
          setState(() => hasChanges = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Attendance saved successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(" ${jsonBody['message'] ?? 'Unknown error'}"),
              backgroundColor: Colors.green,
            ),
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Server error (Status: ${response.statusCode})"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("❌ Error saving attendance: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Network error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void markAll(bool present) {
    setState(() {
      for (var s in students) {
        final wasPresent = s["isPresent"];
        if (wasPresent != present) {
          int abs = int.tryParse(s["absNo"].toString()) ?? 0;
          s["absNo"] = present ? (abs > 0 ? abs - 1 : 0) : abs + 1;
          s["isPresent"] = present;
        }
      }

      filteredStudents = students.where((student) {
        final name = student["name"].toString().toLowerCase();
        final stNo = student["stNo"].toString().toLowerCase();
        final q = searchQuery.toLowerCase();
        return name.contains(q) || stNo.contains(q);
      }).toList();

      hasChanges = true;
    });
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
          style: GoogleFonts.jost(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            tooltip: "Mark All Present",
            onPressed: () => markAll(true),
          ),
          IconButton(
            icon: const Icon(Icons.cancel, color: Colors.redAccent),
            tooltip: "Mark All Absent",
            onPressed: () => markAll(false),
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.blue),
            tooltip: 'Save All',
            onPressed: updateAllAttendance,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${widget.courseTitle} | $dateStr",
              style: GoogleFonts.jost(fontSize: 14, color: Colors.black54),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: filterStudents,
            ),
          ),
          const SizedBox(height: 10),
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
                    for (var student in filteredStudents) _buildTableRow(student),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableHeader() => TableRow(
    decoration: const BoxDecoration(color: Color(0xFFE8F1FF)),
    children: [
      _buildHeaderCell("#NO"),
      _buildHeaderCell("Student Name"),
      _buildHeaderCell("#St.No"),
      _buildHeaderCell("#Abs.No"),
      _buildHeaderCell("Status"),
    ],
  );

  TableRow _buildTableRow(Map<String, dynamic> s) {
    final abs = int.tryParse(s["absNo"].toString()) ?? 0;
    Color? bgColor;

    if (abs >= 10) {
      bgColor = Colors.redAccent.withOpacity(0.3);
    } else if (abs >= 9) {
      bgColor = Colors.yellowAccent.withOpacity(0.3);
    }

    return TableRow(
      decoration: bgColor != null ? BoxDecoration(color: bgColor) : null,
      children: [
        _buildCell(s["no"], bold: true),
        _buildCell(s["name"], color: Colors.blueAccent, bold: true),
        _buildCell(s["stNo"]),
        _buildCell(s["absNo"].toString()),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Switch(
            value: s["isPresent"],
            onChanged: (bool newValue) {
              setState(() {
                s['isPresent'] = newValue;
                hasChanges = true;
              });
            },

            activeColor: Colors.green,
            inactiveTrackColor: Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) => Padding(
    padding: const EdgeInsets.all(8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.jost(fontSize: 12, fontWeight: FontWeight.bold),
    ),
  );

  Widget _buildCell(String text, {Color? color, bool bold = false}) => Padding(
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
