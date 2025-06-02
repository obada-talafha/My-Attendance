import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({Key? key}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  late MobileScannerController controller;
  double zoomLevel = 0.0;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return; // Prevent multiple scans
    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? rawCode = barcodes.first.rawValue;
      if (rawCode != null) {
        setState(() => isProcessing = true);
        controller.stop();

        try {
          final qrData = jsonDecode(rawCode); // Must be JSON string

          final prefs = await SharedPreferences.getInstance();
          final studentId = prefs.getString('student_id');

          if (studentId == null) {
            _showMessage('Student ID not found.');
            Navigator.pop(context);
            return;
          }

          final response = await http.post(
            Uri.parse('https://my-attendance-1.onrender.com/mark-attendance'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'student_id': studentId,
              'qr_data': qrData,
            }),
          );

          final result = jsonDecode(response.body);

          if (response.statusCode == 200) {
            _showMessage(result['message'] ?? 'Attendance marked!');
          } else {
            _showMessage(result['error'] ?? 'Failed to mark attendance');
          }
        } catch (e) {
          _showMessage('Invalid QR or server error');
        }

        Navigator.pop(context);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Column(
              children: [
                const Text(
                  "Pinch or slide to zoom",
                  style: TextStyle(color: Colors.white70),
                ),
                Slider(
                  value: zoomLevel,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    setState(() {
                      zoomLevel = value;
                    });
                    controller.setZoomScale(value);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
