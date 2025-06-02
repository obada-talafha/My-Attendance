import express from 'express';
import pool from '../db/index.js';

const router = express.Router();

router.post('/', async (req, res) => {
  const { student_id, qr_data } = req.body;

  // Validate request body
  if (
    !student_id ||
    !qr_data ||
    typeof qr_data !== 'object' ||
    !qr_data.session_id ||
    !qr_data.qr_token
  ) {
    return res.status(400).json({ error: 'Missing or invalid required data' });
  }

  const { session_id, qr_token } = qr_data;

  try {
    // 1. Fetch session info from qr_session
    const sessionQuery = `
      SELECT course_name, session_number, qr_token, session_date
      FROM qr_session
      WHERE session_id = $1
    `;
    const sessionResult = await pool.query(sessionQuery, [session_id]);

    if (sessionResult.rows.length === 0) {
      return res.status(404).json({ error: 'Session not found' });
    }

    const session = sessionResult.rows[0];

    // 2. Validate QR token
    if (session.qr_token !== qr_token) {
      return res.status(401).json({ error: 'Invalid QR token' });
    }

    const { course_name, session_number, session_date } = session;

    // Debug logs to check what we have before insertion
    console.log('--- Inserting Attendance ---');
    console.log('session_id:', session_id);
    console.log('student_id:', student_id);
    console.log('course_name:', course_name);
    console.log('session_number:', session_number);
    console.log('session_date:', session_date);
    console.log('session_date type:', typeof session_date);

    // 3. Confirm student enrollment
    const enrollQuery = `
      SELECT 1 FROM enrollment
      WHERE student_id = $1 AND course_name = $2 AND session_number = $3
    `;
    const enrollResult = await pool.query(enrollQuery, [student_id, course_name, session_number]);

    if (enrollResult.rows.length === 0) {
      return res.status(403).json({ error: 'Student not enrolled in this course/session' });
    }

    // 4. Check if attendance already marked for this session_date
    const checkAttendanceQuery = `
      SELECT 1 FROM attendance
      WHERE student_id = $1 AND course_name = $2 AND session_number = $3 AND session_date = $4
    `;
    const attendanceResult = await pool.query(checkAttendanceQuery, [
      student_id,
      course_name,
      session_number,
      session_date,
    ]);

    if (attendanceResult.rows.length > 0) {
      return res.status(409).json({ error: 'Attendance already marked for this session' });
    }

    // 5. Insert attendance record
    const insertQuery = `
      INSERT INTO attendance (
        session_id, student_id, is_present, verified_face, marked_at,
        session_date, course_name, session_number
      ) VALUES ($1, $2, TRUE, FALSE, NOW(), $3, $4, $5)
    `;
    await pool.query(insertQuery, [
      session_id,
      student_id,
      session_date,
      course_name,
      session_number,
    ]);

    return res.status(200).json({ message: 'Attendance marked successfully' });
  } catch (error) {
    console.error('❌ Error marking attendance:', error);
    return res.status(500).json({ error: 'Internal server error', detail: error.message });
  }
});

export default router;
