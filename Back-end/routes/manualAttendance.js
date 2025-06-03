import express from 'express';
import pool from '../db/index.js';

const router = express.Router();

// Updated 3/6/2025
// Save manual attendance records
router.post('/api/manual-attendance/save', async (req, res) => {
  const { course_name, session_number, session_date, students } = req.body;

  if (!course_name || !session_number || !Array.isArray(students)) {
    return res.status(400).json({
      success: false,
      message: "Missing or invalid course_name, session_number, or students list"
    });
  }

  try {
    // 1. Get session_id from qr_session
    const sessionQuery = await pool.query(
      `SELECT session_id FROM qr_session WHERE course_name = $1 AND session_number = $2`,
      [course_name, session_number]
    );

    if (sessionQuery.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    const session_id = sessionQuery.rows[0].session_id;

    // 2. Process each student
    for (const student of students) {
      const { student_id, is_present } = student;

      // 2.1 Check if enrolled
      const enrollmentQuery = await pool.query(
        `SELECT 1 FROM enrollment WHERE student_id = $1 AND course_name = $2 AND session_number = $3`,
        [student_id, course_name, session_number]
      );
      if (enrollmentQuery.rowCount === 0) continue;

      // 2.2 Check if attendance already exists
      const attendanceExists = await pool.query(
        `SELECT 1 FROM attendance WHERE student_id = $1 AND session_id = $2`,
        [student_id, session_id]
      );
      if (attendanceExists.rowCount > 0) continue;

      // 2.3 Insert attendance
      await pool.query(
        `INSERT INTO attendance (
           session_id, student_id, is_present, verified_face, marked_at, session_date, session_number, course_name
         ) VALUES ($1, $2, $3, false, NOW(), $4, $5, $6)`,
        [session_id, student_id, is_present, session_date, session_number, course_name]
      );
    }

    res.status(200).json({ success: true, message: 'Manual attendance saved successfully' });

  } catch (err) {
    console.error('Manual Attendance Error:', err.message);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
