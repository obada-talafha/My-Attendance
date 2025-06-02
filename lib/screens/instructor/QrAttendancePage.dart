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
  int countdown = 6;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
    _startQrTimer();
    _startCountdownTimer();
  }

  void _startQrTimer() {
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
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

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data.containsKey('session') &&
            data['session'].containsKey('qr_token') &&
            data['session'].containsKey('session_id')) {
          final encodedQr = base64Encode(utf8.encode(jsonEncode({
            'session_id': data['session']['session_id'],
            'qr_token': data['session']['qr_token'],
          })));

          if (encodedQr != qrData) {
            setState(() {
              qrData = encodedQr;
            });
          }
        } else {
          _showSnackBar('Missing QR code data from server');
        }
      } else {
        _showSnackBar('Failed to generate QR code');
      }
    } catch (e) {
      _showSnackBar('Error generating QR code');
    }
  }

  Future<void> _endSession() async {
    final url = Uri.parse('https://my-attendance-1.onrender.com/end-session');

    print('Ending session for course: ${widget.courseTitle}, session: ${widget.sessionNumber}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course_name': widget.courseTitle,
          'session_number': widget.sessionNumber,
        }),
      );

      if (response.statusCode == 200) {
        print('Session ended successfully');
        Navigator.pop(context);
      } else {
        print('End session failed: ${response.statusCode}');
        print('Response body: ${response.body}');
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

  void _confirmEndSession() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _endSession();
            },
            child: const Text('End'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'End Session',
            onPressed: _confirmEndSession,
          ),
        ],
      ),
      body: SafeArea(
        child: qrData == null
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
          builder: (context, constraints) {
            final maxQrSize = constraints.maxHeight - 100;
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
