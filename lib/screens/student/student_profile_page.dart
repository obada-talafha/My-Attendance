import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  Map<String, dynamic>? student;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentProfile();
  }

  Future<void> fetchStudentProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getString('userId');

    if (studentId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse(
      'https://my-attendance-1.onrender.com/studentProfile?student_id=$studentId',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['student'] != null) {
          setState(() {
            student = data['student'];
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  String formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('yyyy-MM-dd').format(dateTime);
    } catch (_) {
      return isoDate;
    }
  }

  TableRow buildTableRow(String label, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            value?.toString() ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : student == null
          ? const Center(child: Text('Student not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
          CircleAvatar(
          radius: 60,
            backgroundImage: student!['image'] != null
                ? MemoryImage(base64Decode(student!['image'].split(',').last))
                : null,
          child: student!['image'] == null
              ? const Icon(Icons.person, size: 60)
              : null,
        ),

            const SizedBox(height: 20),
            Text(
              student!['name'] ?? '',
              style: GoogleFonts.jost(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              defaultVerticalAlignment:
              TableCellVerticalAlignment.middle,
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: [
                buildTableRow('ID', student!['student_id']),
                buildTableRow('Email', student!['email']),
                buildTableRow(
                    'Birth Date', formatDate(student!['birthdate'])),
                buildTableRow('Major', student!['major']),
                buildTableRow('Academic Lvl',
                    student!['academiclvl']?.toString()),
                buildTableRow('Status', student!['status']),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
