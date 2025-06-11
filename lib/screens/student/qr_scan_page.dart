import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;

import 'FaceScanPage.dart'; // Make sure this file exists and is updated to handle new props

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
    // Prevent multiple scans or processing if already busy
    if (!canScan || isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;

    if (barcodes.isNotEmpty) {
      final String? rawCode = barcodes.first.rawValue;

      if (rawCode != null) {
        setState(() {
          scannedCode = rawCode;
          isProcessing = true; // Set processing to true
          canScan = false; // Disable scanning while processing
        });

        await Future.delayed(const Duration(milliseconds: 500)); // Small delay for UI
        await controller.stop(); // Stop the scanner to prevent further detection

        try {
          final decoded = utf8.decode(base64Decode(rawCode));
          final Map<String, dynamic> qrData = jsonDecode(decoded);

          // Basic validation for QR data format
          if (!qrData.containsKey('session_id') || !qrData.containsKey('qr_token')) {
            throw FormatException('Invalid QR data format');
          }

          // Make the initial POST request to the new /verify-qr endpoint
          final response = await http.post(
            Uri.parse('https://my-attendance-1.onrender.com/verify-qr'), // Changed endpoint
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'student_id': widget.studentId,
              'qr_data': qrData,
            }),
          );


          if (response.statusCode == 200) {
            final result = jsonDecode(response.body);

            // Extract session_info from the response to pass to FaceScanPage
            final Map<String, dynamic> sessionInfo = result['session_info'];

            // Navigate to FaceScanPage after successful QR verification
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FaceScanPage(
                    studentId: widget.studentId,
                    // Pass only the session_id as it's what the /mark-attendance endpoint expects
                    // or other relevant parts of qrData if needed by FaceScanPage for display.
                    // For the backend, it only needs session_id and face_image.
                    qrData: qrData, // Keeping this for consistency or if FaceScanPage uses its sub-fields
                    sessionInfo: sessionInfo, // Pass the session info from the backend
                  ),
                ),
              ).then((_) {
                // This 'then' block executes when FaceScanPage is popped (returned from)
                if (mounted) {
                  setState(() {
                    isProcessing = false;
                    canScan = true;
                  });
                  controller.start(); // Restart scanner
                }
              });
            }
          } else {
            // Handle errors from the /verify-qr endpoint
            try {
              final errorResult = jsonDecode(response.body);
              _showMessage(errorResult['error'] ?? 'Failed to verify QR code');
            } catch (_) {
              _showMessage('Failed to verify QR code with unexpected error');
            }
            // If QR verification fails, re-enable scanning
            if (mounted) {
              setState(() {
                isProcessing = false;
                canScan = true;
              });
              controller.start(); // Restart scanner on error
            }
          }
        } catch (e) {
          // Handle parsing errors or network issues
          _showMessage('Invalid QR code or server error: ${e.toString()}');
          if (mounted) {
            setState(() {
              isProcessing = false;
              canScan = true;
            });
            controller.start(); // Restart scanner on error
          }
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
          if (isProcessing) // Show a loading indicator when processing
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }
}