import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import 'FaceScanPage.dart'; // Make sure this file exists

class QRScanPage extends StatefulWidget {
  final String studentId;

  const QRScanPage({Key? key, required this.studentId}) : super(key: key);

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  late MobileScannerController controller;
  double zoomLevel = 0.0;
  bool isProcessing = false;
  bool canScan = false;
  String scannedCode = '';

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          canScan = true;
        });
      }
    });
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!canScan || isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? rawCode = barcodes.first.rawValue;

      if (rawCode != null) {
        setState(() {
          scannedCode = rawCode;
          isProcessing = true;
        });

        await Future.delayed(const Duration(milliseconds: 500));
        await controller.stop();



        try {
          final decoded = utf8.decode(base64Decode(rawCode));
          final Map<String, dynamic> qrData = jsonDecode(decoded);

          if (!qrData.containsKey('session_id') || !qrData.containsKey('qr_token')) {
            throw FormatException('Invalid QR data format');
          }

          final response = await http.post(
            Uri.parse('https://my-attendance-1.onrender.com/mark-attendance'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'student_id': widget.studentId,
              'qr_data': qrData,
            }),
          );


          if (response.statusCode == 200) {
            final result = jsonDecode(response.body);

            // Navigate to FaceScanPage after success
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaceScanPage(
                    studentId: widget.studentId,
                    qrData: qrData,
                  ),
                ),
              );
            }
          } else {
            try {
              final errorResult = jsonDecode(response.body);
              _showMessage(errorResult['error'] ?? 'Failed to mark attendance');
            } catch (_) {
              _showMessage('Failed to mark attendance with unexpected error');
            }
          }
        } catch (e) {
          _showMessage('Invalid QR code or server error');
        }
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white70, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.1),
              ),
            ),
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
