import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ViewAttendancePage extends StatefulWidget {
  final DateTime selectedDate;
  final String courseTitle;
  final String courseId;

  const ViewAttendancePage({
    Key? key,
    required this.selectedDate,
    required this.courseTitle,
    required this.courseId,
  }) : super(key: key);

  @override
  _ViewAttendancePageState createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  List<Map<String, dynamic>> students = [
    {"no": "01", "name": "Mohammad Ali", "stNo": "155666", "absNo": 1, "isPresent": false},
    {"no": "02", "name": "Omar Omari", "stNo": "131945", "absNo": 0, "isPresent": true},
    {"no": "03", "name": "Yosef Qudah", "stNo": "125567", "absNo": 1, "isPresent": false},
    {"no": "04", "name": "Mawada Basheer", "stNo": "124734", "absNo": 0, "isPresent": true},
    {"no": "05", "name": "Yazan Refai", "stNo": "160789", "absNo": 2, "isPresent": true},
    {"no": "06", "name": "Ahmad Tariq", "stNo": "153457", "absNo": 8, "isPresent": true},
    {"no": "07", "name": "Islah Zakaria", "stNo": "154245", "absNo": 8, "isPresent": false},
    {"no": "08", "name": "Sara Ahmad", "stNo": "157358", "absNo": 9, "isPresent": true},
  ];

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
          "Attendance Record",
          style: GoogleFonts.jost(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${widget.courseTitle} | $dateStr",
              style: GoogleFonts.jost(fontSize: 14, color: Colors.black54),
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
                } else if (value && !student["isPresent"] && student["absNo"] > 0) {
                  student["absNo"] -= 1;
                }
                student["isPresent"] = value;
              });
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
