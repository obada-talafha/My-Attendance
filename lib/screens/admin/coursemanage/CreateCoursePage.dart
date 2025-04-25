import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateCoursePage extends StatefulWidget {
  const CreateCoursePage({super.key});

  @override
  State<CreateCoursePage> createState() => _CreateCoursePageState();
}

class _CreateCoursePageState extends State<CreateCoursePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _courseIdController = TextEditingController();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _secNumController = TextEditingController();
  final TextEditingController _lineNumController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  String? _selectedCollege;
  String? _selectedDepartment;
  String? _selectedCreditHours;
  String? _selectedDays;

  final List<String> colleges = ['Engineering', 'Business', 'Arts', 'Science'];
  final List<String> departments = ['CS', 'IT', 'Math', 'Physics'];
  final List<String> creditHours = ['1', '2', '3', '4', '5'];
  final List<String> daysOptions = ['Sun/Tue', 'Mon/Wed', 'Tue/Thu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Course', style: GoogleFonts.jost(fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(label: 'Course ID', controller: _courseIdController),
              _buildTextField(label: 'Course Name', controller: _courseNameController),
              _buildTextField(label: 'Section Number', controller: _secNumController, inputType: TextInputType.number),
              _buildTextField(label: 'Line Number', controller: _lineNumController, inputType: TextInputType.number),
              _buildDropdown(label: 'College', value: _selectedCollege, items: colleges, onChanged: (val) => setState(() => _selectedCollege = val)),
              _buildDropdown(label: 'Department', value: _selectedDepartment, items: departments, onChanged: (val) => setState(() => _selectedDepartment = val)),
              _buildDropdown(label: 'Credit Hours', value: _selectedCreditHours, items: creditHours, onChanged: (val) => setState(() => _selectedCreditHours = val)),
              _buildTextField(label: 'Instructor Name', controller: _instructorController),
              _buildDropdown(label: 'Days', value: _selectedDays, items: daysOptions, onChanged: (val) => setState(() => _selectedDays = val)),
              _buildTextField(label: 'Time', controller: _timeController, hint: 'e.g. 10:00 AM - 11:30 AM'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                ),
                child: Text(
                  'Create Course',
                  style: GoogleFonts.jost(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType inputType = TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) => value == null ? 'Required field' : null,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Simulate submission logic
      print('Course Created');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course created successfully!')),
      );
    }
  }
}
