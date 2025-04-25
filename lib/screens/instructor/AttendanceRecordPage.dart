import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(AttendanceRecordPage());
}

class AttendanceRecordPage extends StatefulWidget {
  @override
  _AttendanceRecordPageState createState() => _AttendanceRecordPageState();
}

class _AttendanceRecordPageState extends State<AttendanceRecordPage> {
  List<Map<String, dynamic>> students = [
    {"no": "01", "name": "Mohammad Ali", "stNo": "155666", "absNo": 8, "isPresent": true},
    {"no": "02", "name": "Omar Omari", "stNo": "131945", "absNo": 0, "isPresent": true},
    {"no": "03", "name": "Yosef Qudah", "stNo": "125567", "absNo": 1, "isPresent": false},
    {"no": "04", "name": "Mawada Basheer", "stNo": "124734", "absNo": 9, "isPresent": true},
    {"no": "05", "name": "Yazan Refai", "stNo": "160789", "absNo": 2, "isPresent": true},
  ];

  List<Map<String, dynamic>> filteredStudents = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredStudents = students;
  }

  void filterSearch(String query) {
    setState(() {
      filteredStudents = students.where((student) {
        return student["name"].toLowerCase().contains(query.toLowerCase()) ||
            student["stNo"].contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Color(0xFFF6FAFF),
        appBar: AppBar(
          backgroundColor: Color(0xFFF6FAFF),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {},
          ),
          title: Text(
            "View Attendance Record",
            style: GoogleFonts.jost(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by Name or Student Number",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: filterSearch,
              ),
              SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Table(
                    border: TableBorder.all(color: Color(0xFFE8F1FF)),
                    columnWidths: {
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
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(color: Color(0xFFE8F1FF)),
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
    return TableRow(
      decoration: BoxDecoration(color: Colors.white),
      children: [
        _buildCell(student["no"], bold: true),
        _buildCell(student["name"], color: Colors.blueAccent, bold: true),
        _buildCell(student["stNo"]),
        _buildCell(student["absNo"].toString()),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Switch(
            value: student["isPresent"],
            onChanged: (bool value) {
              setState(() {
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
      padding: EdgeInsets.all(8),
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
      padding: EdgeInsets.all(8),
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
