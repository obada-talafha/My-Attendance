import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class QrAttendancePage extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final DateTime selectedDate;

  const QrAttendancePage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<QrAttendancePage> createState() => _QrAttendancePageState();
}

class _QrAttendancePageState extends State<QrAttendancePage> {
  late Timer _timer;
  String _qrData = '';
  int totalStudents = 0;
  int attendedCount = 0;
  List<Map<String, dynamic>> pendingStudents = [];

  @override
  void initState() {
    super.initState();
    _generateNewQr();
    _fetchAttendanceStats();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _generateNewQr();
      _fetchAttendanceStats();
    });
  }

  void _generateNewQr() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final token = '${widget.courseId}_${widget.selectedDate.toIso8601String()}_$timestamp';

    setState(() {
      _qrData = token;
    });

    print("Generated QR Token: $token");
  }

  Future<void> _fetchAttendanceStats() async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDate);
    final url = Uri.parse('http://your-api-domain.com/api/attendance/stats/${widget.courseId}/$formattedDate');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          totalStudents = data['total'];
          attendedCount = data['attended'];
          pendingStudents = List<Map<String, dynamic>>.from(data['pending']);
        });
      }
    } catch (e) {
      print('Failed to fetch stats: $e');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'QR Code for ${widget.courseTitle}',
          style: GoogleFonts.jost(
            fontSize: isSmallScreen ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: _qrData.isEmpty
                    ? const CircularProgressIndicator()
                    : QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: isSmallScreen ? 300 : 400,
                  gapless: true,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attendance Summary',
                        style: GoogleFonts.jost(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Students: $totalStudents'),
                      Text('Attended: $attendedCount'),
                      const SizedBox(height: 10),
                      ExpansionTile(
                        title: Text('Pending Students (${pendingStudents.length})'),
                        children: pendingStudents
                            .map((s) => ListTile(title: Text(s['name'] ?? 'Unnamed')))
                            .toList(),
                      ),
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
}
