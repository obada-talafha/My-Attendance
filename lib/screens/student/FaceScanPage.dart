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
  final Map<String, dynamic> sessionInfo; // <--- ADDED: Define sessionInfo here

  const FaceScanPage({
    Key? key,
    required this.studentId,
    required this.qrData,
    required this.sessionInfo, // <--- ADDED: Add it to the constructor
  }) : super(key: key);

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  CameraController? _cameraController;
  bool isSending = false; // Flag to prevent multiple sends

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initializes the front camera for face scanning.
  Future<void> _initializeCamera() async {
    try {
      // Get all available cameras on the device.
      final cameras = await availableCameras();
      // Find the front-facing camera. If not found, default to the first available camera.
      final frontCamera = cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // Initialize the camera controller with the selected camera and medium resolution.
      _cameraController = CameraController(frontCamera, ResolutionPreset.medium);
      await _cameraController!.initialize();

      // Update the UI once the camera is initialized.
      if (mounted) setState(() {});
    } catch (e) {
      // Show an error message if camera initialization fails.
      _showMessage('Failed to initialize camera. Please check camera permissions.');
      print('Camera initialization error: $e'); // For debugging
    }
  }

  // Captures a face image and sends it to the backend for attendance marking.
  Future<void> _captureAndSendFace() async {
    // Prevent multiple sends or if camera controller is not ready.
    if (_cameraController == null || !_cameraController!.value.isInitialized || isSending) {
      if (isSending) {
        _showMessage('Processing previous request...');
      } else {
        _showMessage('Camera not ready. Please wait.');
      }
      return;
    }

    try {
      // Set sending flag to true to disable the button and show loading.
      setState(() {
        isSending = true;
      });

      // Take a picture using the camera controller.
      final XFile imageFile = await _cameraController!.takePicture();
      // Read the image file as bytes.
      final bytes = await File(imageFile.path).readAsBytes();
      // Encode the image bytes to a Base64 string for sending via JSON.
      final base64Image = base64Encode(bytes);

      // Define the API endpoint for marking attendance.
      // This should be the main endpoint that handles both QR and face verification.
      final Uri apiUrl = Uri.parse('https://my-attendance-1.onrender.com/mark-attendance');

      // Extract session_id from the sessionInfo received from QRScanPage
      final String sessionId = widget.sessionInfo['session_id'];

      // Prepare the request body.
      // Now sending 'session_id' directly as expected by the updated backend's /mark-attendance endpoint.
      final Map<String, dynamic> requestBody = {
        'student_id': widget.studentId,
        'session_id': sessionId, // <--- CHANGED: Send session_id directly
        'face_image': base64Image, // Use 'face_image' as expected by the backend
      };

      print('Sending request to /mark-attendance with:'); // For debugging
      print('student_id: ${widget.studentId}');
      print('session_id: $sessionId');
      print('face_image: ${base64Image.substring(0, 30)}...'); // Print a snippet

      // Make the POST request to the backend.
      final response = await http.post(
        apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Decode the response from the backend.
      final result = jsonDecode(response.body);

      // Check the HTTP status code for success or failure.
      if (response.statusCode == 200) {
        // Attendance successfully marked.
        final message = result['message'] ?? 'Attendance marked successfully!';
        _showMessage(message);

        // Navigate to the StudentHomePage after a short delay for the message to be seen.
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentHomePage()),
            );
          }
        });
      } else {
        // Handle backend errors based on status code.
        final errorMessage = result['error'] ?? 'Failed to mark attendance with an unknown error.';
        _showMessage(errorMessage);
        print('Backend error response: ${response.statusCode} - $errorMessage'); // For debugging
      }
    } catch (e) {
      // Catch any network or other unexpected errors.
      _showMessage('An error occurred during face scan or attendance marking: ${e.toString()}');
      print('Client-side error during _captureAndSendFace: $e'); // For debugging
    } finally {
      // Ensure the sending flag is reset after the operation, regardless of success or failure.
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // Shows a SnackBar message at the bottom of the screen.
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    // Dispose of the camera controller when the widget is removed from the tree
    // to prevent memory leaks and ensure the camera resource is released.
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
          ? const Center(child: CircularProgressIndicator(color: Colors.white)) // Show loading while camera initializes
          : SafeArea(
        child: Stack(
          children: [
            // Display the camera preview.
            // Using a FittedBox to ensure the camera preview covers the available space
            // while maintaining its aspect ratio.
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _cameraController!.value.previewSize!.height,
                  height: _cameraController!.value.previewSize!.width,
                  child: CameraPreview(_cameraController!),
                ),
              ),
            ),

            // Visual overlay for the face scanning area.
            Center( // Using Center to position the overlay more reliably
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

            // Scan button aligned at bottom center.
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: ElevatedButton.icon(
                  // Disable button while sending request.
                  onPressed: isSending ? null : _captureAndSendFace,
                  icon: isSending
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.face),
                  label: Text(isSending ? 'Processing...' : 'Scan Face'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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