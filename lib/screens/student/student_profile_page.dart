import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  TableRow buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.jost(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Removed the drawer
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.jost(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: const Color(0xFFF5F9FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('asset/profile_pic.png'), // Update path if needed
              ),
              const SizedBox(height: 20),
              Text(
                'Obada Mohammad Talafha',
                style: GoogleFonts.jost(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              Table(
                border: TableBorder.all(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(3),
                },
                children: [
                  buildTableRow('ID', '20202020001'),
                  buildTableRow('Email', 'obada@example.com'),
                  buildTableRow('Birth Date', '03/03/2003'),
                  buildTableRow('Major', 'Computer Science'),
                  buildTableRow('Academic Lvl', '4'),
                  buildTableRow('Status', 'Expected to graduate'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
