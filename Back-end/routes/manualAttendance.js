import express from 'express';
import pool from '../db/index.js';

const manualAttendanceRouter = express.Router();

/**
 * GET students and their attendance info for a given course and session
 * Route: /manual-attendance/:courseName/:sessionNumber
 * Returns:
 *  - student_id
 *  - student_name
 *  - absence_count (total absences in all sessions)
 *  - is_present (for the specified session)
 */
manualAttendanceRouter.get('/:courseName/:sessionNumber', async (req, res) => {
  const { courseName, sessionNumber } = req.params;

  try {
    const query = `
      SELECT
        s.student_id,
        s.name AS student_name,
        COALESCE(abs.absence_count, 0) AS absence_count,
        COALESCE(att.is_present, false) AS is_present
      FROM enrollment e
      JOIN student s ON s.student_id = e.student_id
      LEFT JOIN (
        SELECT student_id, COUNT(*) AS absence_count
        FROM attendance
        WHERE is_present = false
        GROUP BY student_id
      ) abs ON abs.student_id = s.student_id
      LEFT JOIN (
        SELECT student_id, is_present
        FROM attendance
        WHERE course_name = $1 AND session_number = $2::int
      ) att ON att.student_id = s.student_id
      WHERE e.course_name = $1 AND e.session_number::int = $2::int
    `;

    const { rows } = await pool.query(query, [courseName, sessionNumber]);
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error fetching manual attendance:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

/**
 * POST save manual attendance
 * Route: /manual-attendance/save
 * Body:
 *  - course_name
 *  - session_number
 *  - session_date (YYYY-MM-DD)
 *  - students: [{ student_id, is_present }]
 */
manualAttendanceRouter.post('/save', async (req, res) => {
  const { course_name, session_number, session_date, students } = req.body;

  if (!Array.isArray(students) || students.length === 0) {
    return res.status(400).json({ error: 'No student attendance data provided' });
  }

  try {
    for (const { student_id, is_present } of students) {
      const checkQuery = `
        SELECT attendance_id
        FROM attendance
        WHERE course_name = $1 AND session_number = $2::int AND student_id = $3 AND session_date = $4
      `;

      const checkResult = await pool.query(checkQuery, [
        course_name,
        session_number,
        student_id,
        session_date,
      ]);

      if (checkResult.rows.length > 0) {
        // Record exists → update it
        await pool.query(
          `
          UPDATE attendance
          SET is_present = $1, marked_at = NOW()
          WHERE attendance_id = $2
        `,
          [is_present, checkResult.rows[0].attendance_id]
        );
      } else {
        // Insert new record
        await pool.query(
          `
          INSERT INTO attendance (
            student_id, is_present, session_date,
            session_number, course_name, marked_at
          ) VALUES ($1, $2, $3, $4::int, $5, NOW())
        `,
          [student_id, is_present, session_date, session_number, course_name]
        );
      }
    }

    res.status(200).json({ message: 'Attendance saved successfully' });
  } catch (error) {
    console.error('Error saving manual attendance:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export { manualAttendanceRouter };
