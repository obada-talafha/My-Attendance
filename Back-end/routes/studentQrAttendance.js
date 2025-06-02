import express from 'express';
import pool from '../db/index.js'; // Assuming you use a pool from your db/index.js

const router = express.Router();

router.post('/', async (req, res) => {
  const { student_id, qr_data } = req.body;

  if (!student_id || !qr_data || !qr_data.session_id || !qr_data.qr_token) {
    return res.status(400).json({ error: 'Missing required data' });
  }

  try {
    const { session_id, qr_token } = qr_data;

    // 1. Verify session and QR token
    const [sessionRows] = await pool.query(
      'SELECT course_name, session_number, qr_token FROM qr_session WHERE session_id = ?',
      [session_id]
    );

    if (sessionRows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const session = sessionRows[0];

    if (session.qr_token !== qr_token) {
      return res.status(401).json({ error: 'Invalid QR token' });
    }

    // 2. Verify enrollment
    const [enrollRows] = await pool.query(
      'SELECT * FROM enrollment WHERE student_id = ? AND course_name = ? AND session_number = ?',
      [student_id, session.course_name, session.session_number]
    );

    if (enrollRows.length === 0) {
      return res.status(403).json({ error: 'Student not enrolled in this course/session' });
    }

    // 3. Mark attendance (insert or update)
    await pool.query(
      `INSERT INTO attendance (session_id, student_id, is_present, verified_face, marked_at)
       VALUES (?, ?, true, false, NOW())
       ON DUPLICATE KEY UPDATE is_present = true, marked_at = NOW()`,
      [session_id, student_id]
    );

    return res.json({ message: 'Attendance marked successfully' });

  } catch (error) {
    console.error('Error marking attendance:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
