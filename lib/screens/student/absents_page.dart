import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AbsentsPage extends StatefulWidget {
  final String courseTitle;
  final int sessionNum;
  final String studentId;

  const AbsentsPage({
    super.key,
    required this.courseTitle,
    required this.sessionNum,
    required this.studentId,
  });

  @override
  State<AbsentsPage> createState() => _AbsentsPageState();
}

class _AbsentsPageState extends State<AbsentsPage> {
  List<Map<String, String>> sortedAbsents = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchAbsents();
  }

  Future<List<Map<String, String>>> fetchStudentAbsences({
    required String studentId,
    required String courseName,
    required int sessionNumber,
  }) async {
    final url = Uri.parse('https://my-attendance-1.onrender.com/student-absences/absents');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'student_id': studentId,
        'course_name': courseName,
        'session_number': sessionNumber,
      }),
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List absents = data['absents'] ?? [];

      return absents.map<Map<String, String>>((item) {
        return {
          'date': item['date'] ?? '',
          'day': item['day'] ?? '',
        };
      }).toList();
    } else {
      throw Exception('Failed to load absences');
    }
  }

  Future<void> _fetchAbsents() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final absents = await fetchStudentAbsences(
        studentId: widget.studentId,
        courseName: widget.courseTitle,
        sessionNumber: widget.sessionNum,
      );

      setState(() {
        sortedAbsents = absents;
        sortedAbsents.sort((a, b) {
          final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime(1900);
          final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _fetchAbsents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.courseTitle} - Session ${widget.sessionNum}",
          style: GoogleFonts.jost(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
            ? ListView(
          children: [
            const SizedBox(height: 200),
            Center(
              child: Text(
                'Error: $error',
                style: GoogleFonts.jost(fontSize: 18, color: Colors.red),
              ),
            ),
          ],
        )
            : sortedAbsents.isEmpty
            ? ListView(
          children: [
            const SizedBox(height: 200),
            Center(
              child: Text(
                'No absence records found.',
                style: GoogleFonts.jost(fontSize: 18, color: Colors.grey),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sortedAbsents.length,
          itemBuilder: (context, index) {
            final absent = sortedAbsents[index];
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.event_busy, color: Colors.redAccent),
                title: Text(
                  absent["day"] ?? "Unknown Day",
                  style: GoogleFonts.jost(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  absent["date"] ?? "Unknown Date",
                  style: GoogleFonts.jost(fontSize: 16),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
