import express from 'express';
import pool from '../db/index.js';

const router = express.Router();

router.post('/', async (req, res) => {
  const { student_id, qr_data } = req.body;

  if (
    !student_id ||
    !qr_data ||
    typeof qr_data !== 'object' ||
    !qr_data.session_id ||
    !qr_data.qr_token
  ) {
    return res.status(400).json({ error: 'Missing or invalid required data' });
  }

  try {
    const { session_id, qr_token } = qr_data;

    // Step 1: Verify QR session
    const sessionResult = await pool.query(
      `SELECT course_name, session_number, qr_token FROM qr_session WHERE session_id = $1`,
      [session_id]
    );

    if (sessionResult.rows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const session = sessionResult.rows[0];

    if (session.qr_token !== qr_token) {
      return res.status(401).json({ error: 'Invalid QR token' });
    }

    // Step 2: Check student enrollment
    const enrollResult = await pool.query(
      `SELECT 1 FROM enrollment WHERE student_id = $1 AND course_name = $2 AND session_number = $3`,
      [student_id, session.course_name, session.session_number]
    );

    if (enrollResult.rows.length === 0) {
      return res.status(403).json({ error: 'Student not enrolled in this course/session' });
    }

    // Step 3: Check if student has already marked attendance today
    const alreadyMarkedResult = await pool.query(
      `SELECT 1 FROM attendance
       WHERE session_id = $1
         AND student_id = $2
         AND DATE(marked_at) = CURRENT_DATE`,
      [session_id, student_id]
    );

    if (alreadyMarkedResult.rows.length > 0) {
      return res.status(409).json({ error: 'Attendance already marked for today' });
    }

    // Step 4: Mark attendance
    await pool.query(
      `INSERT INTO attendance (session_id, student_id, is_present, verified_face, marked_at)
       VALUES ($1, $2, TRUE, FALSE, NOW())
       ON CONFLICT (session_id, student_id)
       DO UPDATE SET is_present = TRUE, verified_face = FALSE, marked_at = NOW()`,
      [session_id, student_id]
    );

    return res.status(200).json({ message: 'Attendance marked successfully' });
  } catch (error) {
    console.error('❌ Error marking attendance:', error.message);
    return res.status(500).json({ error: 'Internal server error', detail: error.message });
  }
});

export default router;
