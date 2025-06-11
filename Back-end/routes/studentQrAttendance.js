import express from 'express';
import pool from '../db/index.js';
import axios from 'axios';

const router = express.Router();

router.post('/', async (req, res) => {
  const { student_id, qr_data, face_image } = req.body;

  if (
    !student_id ||
    !qr_data ||
    typeof qr_data !== 'object' ||
    !qr_data.session_id ||
    !qr_data.qr_token ||
    !face_image
  ) {
    return res.status(400).json({ error: 'Missing or invalid required data' });
  }

  try {
    const { session_id, qr_token } = qr_data;

    // Step 1: Verify QR session
    const sessionResult = await pool.query(
      `SELECT course_name, session_number, session_date, qr_token
       FROM qr_session
       WHERE session_id = $1`,
      [session_id]
    );

    if (sessionResult.rowCount === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const session = sessionResult.rows[0];

    if (session.qr_token !== qr_token) {
      return res.status(401).json({ error: 'Invalid QR token' });
    }

    // Step 2: Check student enrollmen
    const enrollResult = await pool.query(
      `SELECT 1
       FROM enrollment
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3`,
      [student_id, session.course_name, session.session_number]
    );

    if (enrollResult.rowCount === 0) {
      return res.status(403).json({ error: 'Student not enrolled in this course/session' });
    }

    // Step 3: Check if attendance already exists
    const attendanceCheck = await pool.query(
      `SELECT is_present
       FROM attendance
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3 AND session_date = $4`,
      [student_id, session.course_name, session.session_number, session.session_date]
    );

    if (attendanceCheck.rowCount > 0) {
      return res.status(200).json({ message: 'You have already scanned the QR code' });
    }

    // ✅ Step 4: Face verification (calls Flask)
    let verified_face = false;
    try {
      const faceResponse = await axios.post('http://localhost:5000/verify-face', { image: face_image });

      if (
        faceResponse.data.status === 'success' &&
        faceResponse.data.student_id === student_id
      ) {
        verified_face = true;
      }
    } catch (faceErr) {
      console.error('Face verification failed:', faceErr.message);
      // Optional: return error or just log failure
    }

    // ✅ Step 5: Insert attendance
    await pool.query(
      `INSERT INTO attendance (
         session_id, student_id, is_present,
         marked_at, session_date, session_number, course_name
       )
       VALUES ($1, $2, TRUE, $3, NOW(), $4, $5, $6)`,
      [
        session_id,
        student_id,
        verified_face,
        session.session_date,
        session.session_number,
        session.course_name,
      ]
    );

    return res.status(200).json({
      message: 'Attendance marked successfully',
      verified_face,
    });

  } catch (error) {
    console.error('❌ Error marking attendance:', error.message);
    return res.status(500).json({ error: 'Internal server error', detail: error.message });
  }
});

export default router;
