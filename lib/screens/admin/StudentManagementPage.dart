import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentManagementPage extends StatelessWidget {
  const StudentManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {'label': 'View', 'icon': Icons.visibility},
      {'label': 'Edit', 'icon': Icons.edit},
      {'label': 'Add', 'icon': Icons.person_add},
      {'label': 'Delete', 'icon': Icons.delete},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Students',
          style: GoogleFonts.jost(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              // Web/tablet: use Wrap to show all buttons in a grid-like layout
              return Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: actions
                      .map((action) => SizedBox(
                    width: 240,
                    height: 140,
                    child: _buildActionTile(action),
                  ))
                      .toList(),
                ),
              );
            } else {
              // Phone: vertical list
              return ListView.separated(
                itemCount: actions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildActionTile(actions[index]),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildActionTile(Map<String, dynamic> action) {
    return GestureDetector(
      onTap: () {
        // Add action logic here
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(action['icon'], size: 32, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              action['label'],
              style: GoogleFonts.jost(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
