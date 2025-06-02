import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

class QrAttendancePage extends StatefulWidget {
  final String courseId;
  final String courseTitle;
  final DateTime selectedDate;
  final int sessionNumber;

  const QrAttendancePage({
    Key? key,
    required this.courseId,
    required this.courseTitle,
    required this.selectedDate,
    required this.sessionNumber,

  }) : super(key: key);

  @override
  _QrAttendancePageState createState() => _QrAttendancePageState();
}

class _QrAttendancePageState extends State<QrAttendancePage> {
  String? qrData;
  Timer? _timer;
  Timer? _countdownTimer;
  int countdown = 6; // Start from 5 seconds

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    _startQrTimer();
    _startCountdownTimer();
  }

  void _startQrTimer() {
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      print('Refreshing QR...');
      _generateQRCode();
      setState(() {
        countdown = 6;
      });
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateQRCode() async {
    final url = Uri.parse('https://my-attendance-1.onrender.com/qr_code');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course_name': widget.courseTitle,
          'session_number': widget.sessionNumber,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Raw Response: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data.containsKey('qr_token') && data.containsKey('session_id')) {
          final newQrData = jsonEncode({
            'session_id': data['session_id'],
            'qr_token': data['qr_token'],
          });

          if (newQrData != qrData) {
            setState(() {
              qrData = newQrData;
            });
          }
        } else {
          _showSnackBar('Missing QR code data from server');
        }
      } else {
        print('Failed to generate QR: ${response.body}');
        _showSnackBar('Failed to generate QR code');
      }
    } catch (e) {
      print('Error generating QR code: $e');
      _showSnackBar('Error generating QR code');
    }
  }

  Future<void> _endSession() async {
    final url = Uri.parse('https://my-attendance-1.onrender.com/api/end_session');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course_name': widget.courseTitle,
          'session_number': widget.sessionNumber,
        }),
      );

      print('End session response: ${response.body}');

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        print('Failed to end session');
        _showSnackBar('Failed to end session');
      }
    } catch (e) {
      print('Error ending session: $e');
      _showSnackBar('Error ending session');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'End Session',
            onPressed: _endSession,
          ),
        ],
      ),
        body: SafeArea(
          child: qrData == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
            builder: (context, constraints) {
              // Calculate max QR size based on available height:
              // Reserve 100 for countdown text + padding, etc.
              final maxQrSize = constraints.maxHeight - 100;
              // Also limit QR size to 85% of width
              final qrSize = maxQrSize < constraints.maxWidth * 0.85
                  ? maxQrSize
                  : constraints.maxWidth * 0.85;

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next QR refresh in: $countdown s',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    QrImageView(
                      key: ValueKey(qrData),
                      data: qrData!,
                      version: QrVersions.auto,
                      size: qrSize,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),


    );
  }
}
