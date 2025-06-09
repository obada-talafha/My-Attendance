import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Import your StudentHomePage here (adjust the path as needed)
import 'student_home.dart';

class FaceScanPage extends StatefulWidget {
  final String studentId;
  final Map<String, dynamic> qrData;

  const FaceScanPage({Key? key, required this.studentId, required this.qrData}) : super(key: key);

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  CameraController? _cameraController;
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();

      if (mounted) setState(() {});
    } catch (e) {
      _showMessage('Failed to initialize camera');
    }
  }

  Future<void> _captureAndSendFace() async {
    if (_cameraController == null || isSending) return;

    try {
      setState(() {
        isSending = true;
      });

      final XFile imageFile = await _cameraController!.takePicture();
      final bytes = await File(imageFile.path).readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://my-attendance-1.onrender.com/verify-face'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'student_id': widget.studentId,
          'session_id': widget.qrData['session_id'],
          'qr_token': widget.qrData['qr_token'],
          'image_base64': base64Image,
        }),
      );

      final result = jsonDecode(response.body);
      final message = result['message'] ?? 'Face verification completed';

      _showMessage(message);
    } catch (e) {
      _showMessage('Failed to verify face.');
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });

        // Auto navigate to StudentHomePage after delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentHomePage()),
            );
          }
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Face Recognition'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Stack(
          children: [
            CameraPreview(_cameraController!),

            // Move scan box higher
            Positioned(
              top: 100,
              left: MediaQuery.of(context).size.width / 2 - 125,
              child: Container(
                width: 250,
                height: 320,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70, width: 2),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // Scan button aligned at bottom center
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ElevatedButton.icon(
                  onPressed: isSending ? null : _captureAndSendFace,
                  icon: const Icon(Icons.face),
                  label: const Text('Scan Face'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
