import express from 'express';
import pool from '../db/index.js';

const router = express.Router();

/**
 * GET /manual-attendance/:courseTitle/:sessionNumber
 * Returns all students enrolled in a course with their attendance status for the given session.
 */
router.get('/:courseTitle/:sessionNumber', async (req, res) => {
  const { courseTitle, sessionNumber } = req.params;

  try {
    const query = `
      SELECT
        s.student_id,
        s.student_name,
        COALESCE(att.is_present, false) AS is_present,
        COALESCE(abs.absence_count, 0) AS absence_count
      FROM students s
      JOIN enrollment e ON e.student_id = s.student_id AND e.course_name = $1
      LEFT JOIN qr_session qs ON qs.course_name = e.course_name AND qs.session_number = $2
      LEFT JOIN attendance att ON att.student_id = s.student_id AND att.session_id = qs.session_id
      LEFT JOIN (
        SELECT student_id, COUNT(*) AS absence_count
        FROM attendance
        WHERE is_present = false AND course_name = $1
        GROUP BY student_id
      ) abs ON abs.student_id = s.student_id
      WHERE e.course_name = $1
      ORDER BY s.student_name;
    `;

    const result = await pool.query(query, [courseTitle, sessionNumber]);
    res.json(result.rows);

  } catch (err) {
    console.error('Fetch students error:', err.message);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

/**
 * PUT /manual-attendance/update
 * Updates or inserts a student's attendance for a specific session.
 */
router.put('/update', async (req, res) => {
  const { student_id, course_title, session_number, is_present } = req.body;

  if (!student_id || !course_title || !session_number || typeof is_present !== 'boolean') {
    return res.status(400).json({ success: false, message: 'Missing or invalid data' });
  }

  try {
    // Get session_id from qr_session table
    const sessionRes = await pool.query(
      'SELECT session_id FROM qr_session WHERE course_name = $1 AND session_number = $2',
      [course_title, session_number]
    );

    if (sessionRes.rowCount === 0) {
      return res.status(404).json({ success: false, message: 'Session not found' });
    }

    const session_id = sessionRes.rows[0].session_id;

    // Check if attendance already exists
    const attendanceRes = await pool.query(
      'SELECT * FROM attendance WHERE student_id = $1 AND session_id = $2',
      [student_id, session_id]
    );

    if (attendanceRes.rowCount > 0) {
      // Update existing record
      await pool.query(
        'UPDATE attendance SET is_present = $1, marked_at = NOW() WHERE student_id = $2 AND session_id = $3',
        [is_present, student_id, session_id]
      );
    } else {
      // Insert new attendance record
      await pool.query(
        `INSERT INTO attendance (
          session_id, student_id, is_present, verified_face, marked_at,
          session_date, session_number, course_name
        ) VALUES (
          $1, $2, $3, false, NOW(), NOW()::date, $4, $5
        )`,
        [session_id, student_id, is_present, session_number, course_title]
      );
    }

    res.json({ success: true, message: 'Attendance updated successfully' });

  } catch (err) {
    console.error('Update attendance error:', err.message);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
});

export default router;
