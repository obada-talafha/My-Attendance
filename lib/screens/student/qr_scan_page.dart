import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

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
  bool canScan = false; // Control scanning start after delay
  String scannedCode = ''; // To show scanned QR code value on screen

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );

    // Wait 2 seconds before enabling scanning
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
          scannedCode = rawCode; // Update UI with scanned QR code
          isProcessing = true;
        });

        // Stop scanning shortly after detection
        await Future.delayed(const Duration(milliseconds: 500));
        await controller.stop();

        print('==================== SCANNER OUTPUT ====================');
        print('📷 Scanned QR Code (Base64): $rawCode');
        print('========================================================');
        print('Student ID: ${widget.studentId}');

        try {
          // Decode Base64 and parse JSON
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

          print('Status code: ${response.statusCode}');
          print('Response body: ${response.body}');

          if (response.statusCode == 200) {
            final result = jsonDecode(response.body);
            _showMessage(result['message'] ?? 'Attendance marked!');
          } else {
            try {
              final errorResult = jsonDecode(response.body);
              _showMessage(errorResult['error'] ?? 'Failed to mark attendance');
            } catch (_) {
              _showMessage('Failed to mark attendance with unexpected error');
            }
          }
        } catch (e) {
          print('Error processing QR or server response: $e');
          _showMessage('Invalid QR code or server error');
        }

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context);
        });
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

          // Center overlay box for aiming
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

          // Show scanned code text on top center
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scannedCode.isEmpty
                      ? 'Waiting for scan...'
                      : 'Scanned (Base64): $scannedCode',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          // Zoom slider & label at bottom
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
