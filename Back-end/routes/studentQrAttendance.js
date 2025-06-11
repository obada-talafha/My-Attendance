import express from 'express';
import pool from '../db/index.js';
import axios from 'axios';

const router = express.Router();

// New endpoint for initial QR scan validation (without face_image)
router.post('/verify-qr', async (req, res) => {
  const { student_id, qr_data } = req.body;

  // Initial validation: Ensure all required data is present and correctly formatted.
  if (
    !student_id ||
    !qr_data ||
    typeof qr_data !== 'object' ||
    !qr_data.session_id ||
    !qr_data.qr_token
  ) {
    // If any required data is missing or invalid, return a 400 Bad Request error.
    return res.status(400).json({ error: 'Missing or invalid QR data' });
  }

  try {
    const { session_id, qr_token } = qr_data;

    // Step 1: Verify QR session details from the database.
    const sessionResult = await pool.query(
      `SELECT course_name, session_number, session_date, qr_token
       FROM qr_session
       WHERE session_id = $1`,
      [session_id]
    );

    // If no session is found with the given session_id, return a 404 Not Found error.
    if (sessionResult.rowCount === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const session = sessionResult.rows[0];

    // Verify if the provided QR token matches the stored token for the session.
    if (session.qr_token !== qr_token) {
      return res.status(401).json({ error: 'Invalid QR token' });
    }

    // Step 2: Check student enrollment in the specific course and session.
    const enrollResult = await pool.query(
      `SELECT 1
       FROM enrollment
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3`,
      [student_id, session.course_name, session.session_number]
    );

    // If the student is not enrolled in this course/session, return a 403 Forbidden error.
    if (enrollResult.rowCount === 0) {
      return res.status(403).json({ error: 'Student not enrolled in this course/session' });
    }

    // Step 3: Check if attendance for this student in this session already exists.
    const attendanceCheck = await pool.query(
      `SELECT is_present
       FROM attendance
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3 AND session_date = $4`,
      [student_id, session.course_name, session.session_number, session.session_date]
    );

    // If attendance is already marked, return a 200 OK with a message (no re-marking).
    if (attendanceCheck.rowCount > 0) {
      return res.status(200).json({ message: 'You have already scanned the QR code' });
    }

    // If QR and enrollment are valid, proceed to face scan
    return res.status(200).json({
      message: 'QR verified, proceed to face scan',
      session_info: { // Pass necessary session info to the client for the next step
        session_id: session_id,
        course_name: session.course_name,
        session_number: session.session_number,
        session_date: session.session_date
      }
    });

  } catch (error) {
    // Catch any unexpected errors during the overall process and return a 500 Internal Server Error.
    console.error('❌ Error verifying QR:', error.message);
    return res.status(500).json({ error: 'Internal server error', detail: error.message });
  }
});

// Original endpoint, now specifically for completing attendance with face image
router.post('/mark-attendance', async (req, res) => {
  // Expect session_id directly and face_image for this step
  const { student_id, session_id, face_image } = req.body;

  // Add validation for these specific fields for this endpoint
  if (!student_id || !session_id || !face_image) {
    return res.status(400).json({ error: 'Missing or invalid data for attendance marking' });
  }

  try {
    // Re-fetch session details based on session_id to get course_name, session_number, session_date
    // This is important to ensure data consistency and avoid passing sensitive info unnecessarily
    const sessionResult = await pool.query(
      `SELECT course_name, session_number, session_date, qr_token
       FROM qr_session
       WHERE session_id = $1`,
      [session_id]
    );

    if (sessionResult.rowCount === 0) {
      return res.status(404).json({ error: 'Session not found for attendance marking' });
    }
    const session = sessionResult.rows[0]; // Get session details

    // Re-check if attendance for this student in this session already exists (robustness)
    const attendanceCheck = await pool.query(
      `SELECT is_present
       FROM attendance
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3 AND session_date = $4`,
      [student_id, session.course_name, session.session_number, session.session_date]
    );

    if (attendanceCheck.rowCount > 0) {
      return res.status(200).json({ message: 'Attendance already marked' });
    }

    // ✅ Step 4: Face verification (calls external Flask service).
    let verified_face = false; // Initialize face verification status.
    try {
      // Make a POST request to the Flask face verification service.
      const faceResponse = await axios.post('https://3482-213-139-63-110.ngrok-free.app/verify-face', { image: face_image });

      // Check if the Flask service returned a success status and the student_id matches.
      if (
        faceResponse.data.status === 'success' &&
        faceResponse.data.student_id === student_id
      ) {
        verified_face = true; // Set to true if verification is successful.
      } else {
        // If face verification was unsuccessful, return an error.
        console.warn('Face verification returned unsuccessful status or mismatched student_id.');
        return res.status(400).json({ error: 'Face verification failed or student ID mismatch' });
      }
    } catch (faceErr) {
      // If there's an error calling the Flask service, return a 500 error.
      console.error('Face verification failed:', faceErr.message);
      return res.status(500).json({ error: 'Face verification service unavailable or encountered an error' });
    }

    // ✅ Step 5: Insert attendance record into the database.
    // This step is only reached if QR verification (from previous step) and face verification are successful.
    await pool.query(
      `INSERT INTO attendance (
         session_id, student_id, is_present, verified_face,
         marked_at, session_date, session_number, course_name
       )
       VALUES ($1, $2, TRUE, $3, NOW(), $4, $5, $6)`, // All placeholders correctly mapped.
      [
        session_id,
        student_id,
        verified_face, // This will be TRUE at this point.
        session.session_date,
        session.session_number,
        session.course_name,
      ]
    );

    // Return a success response if attendance is marked.
    return res.status(200).json({
      message: 'Attendance marked successfully',
      verified_face, // This will be true.
    });

  } catch (error) {
    // Catch any unexpected errors during the overall process and return a 500 Internal Server Error.
    console.error('❌ Error marking attendance:', error.message);
    return res.status(500).json({ error: 'Internal server error', detail: error.message });
  }
});

export default router;