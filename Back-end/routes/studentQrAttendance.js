// studentQrAttendance.js (UPDATED - Ensure this is the one on your Render.com)

import express from 'express';
import pool from '../db/index.js';
import axios from 'axios';

const router = express.Router();

// This will handle POST requests to /verify-qr when mounted in app.js at '/'
router.post('/verify-qr', async (req, res) => {
  const { student_id, qr_data } = req.body;

  if (
    !student_id ||
    !qr_data ||
    typeof qr_data !== 'object' ||
    !qr_data.session_id ||
    !qr_data.qr_token
  ) {
    return res.status(400).json({ error: 'Missing or invalid QR data' });
  }

  try {
    const { session_id, qr_token } = qr_data;

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

    const enrollResult = await pool.query(
      `SELECT 1
       FROM enrollment
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3`,
      [student_id, session.course_name, session.session_number]
    );

    if (enrollResult.rowCount === 0) {
      return res.status(403).json({ error: 'Student not enrolled in this course/session' });
    }

    const attendanceCheck = await pool.query(
      `SELECT is_present
       FROM attendance
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3 AND session_date = $4`,
      [student_id, session.course_name, session.session_number, session.session_date]
    );

    if (attendanceCheck.rowCount > 0) {
      return res.status(200).json({ message: 'You have already scanned the QR code' });
    }

    return res.status(200).json({
      message: 'QR verified, proceed to face scan',
      session_info: {
        session_id: session_id,
        course_name: session.course_name,
        session_number: session.session_number,
        session_date: session.session_date
      }
    });

  } catch (error) {
    console.error('❌ Error verifying QR:', error.message);
    return res.status(500).json({ error: 'Internal server error', detail: error.message });
  }
});

// This will handle POST requests to /mark-attendance when mounted in app.js at '/'
router.post('/mark-attendance', async (req, res) => {
  const { student_id, session_id, face_image } = req.body;

  if (!student_id || !session_id || !face_image) {
    return res.status(400).json({ error: 'Missing or invalid data for attendance marking' });
  }

  try {
    const sessionResult = await pool.query(
      `SELECT course_name, session_number, session_date, qr_token
       FROM qr_session
       WHERE session_id = $1`,
      [session_id]
    );

    if (sessionResult.rowCount === 0) {
      return res.status(404).json({ error: 'Session not found for attendance marking' });
    }
    const session = sessionResult.rows[0];

    const attendanceCheck = await pool.query(
      `SELECT is_present
       FROM attendance
       WHERE student_id = $1 AND course_name = $2 AND session_number = $3 AND session_date = $4`,
      [student_id, session.course_name, session.session_number, session.session_date]
    );

    if (attendanceCheck.rowCount > 0) {
      return res.status(200).json({ message: 'Attendance already marked' });
    }

    let verified_face = false;
    try {
      const faceResponse = await axios.post(
        'https://082b-2a01-9700-80d7-c200-adaa-992c-52b5-a020.ngrok-free.app',
        {
          image: face_image,
          student_id: student_id // <--- CRUCIAL FIX: Pass student_id to Flask server
        }
      );

      if (
        faceResponse.data.status === 'success' &&
        faceResponse.data.student_id === student_id
      ) {
        verified_face = true;
      } else {
        console.warn('Face verification returned unsuccessful status or mismatched student_id.');
        return res.status(400).json({ error: 'Face verification failed or student ID mismatch' });
      }
    } catch (faceErr) {
      console.error('Face verification failed:', faceErr.message);
      return res.status(500).json({ error: 'Face verification service unavailable or encountered an error' });
    }

    await pool.query(
      `INSERT INTO attendance (
         session_id, student_id, is_present, verified_face,
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