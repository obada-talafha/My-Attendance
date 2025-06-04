// routes/manualAttendance.js
import express from 'express';
import pool from '../db/index.js';

const manualAttendanceRouter = express.Router();

/**
 * GET students and their attendance info for a given course and session
 */
manualAttendanceRouter.get('/:courseName/:sessionNumber', async (req, res) => {
  const { courseName, sessionNumber } = req.params;

  try {
    const studentsQuery = `
      SELECT
        s.student_id,
        s.name AS student_name,
        COALESCE(a_abs.absence_count, 0) AS absence_count,
        COALESCE(a_session.is_present, false) AS is_present
      FROM enrollment e
      JOIN student s ON e.student_id = s.student_id
      LEFT JOIN (
        SELECT student_id, COUNT(*) AS absence_count
        FROM attendance
        WHERE is_present = false
        GROUP BY student_id
      ) a_abs ON a_abs.student_id = s.student_id
      LEFT JOIN (
        SELECT student_id, is_present
        FROM attendance
        WHERE course_name = $1 AND session_number = $2::int
      ) a_session ON a_session.student_id = s.student_id
      WHERE e.course_name = $1 AND e.session_number = $2::text
    `;

    const { rows } = await pool.query(studentsQuery, [courseName, sessionNumber]);
    res.status(200).json(rows);
  } catch (error) {
    console.error('Error fetching students for manual attendance:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});


/**
 * POST save manual attendance for students
 */
manualAttendanceRouter.post('/save', async (req, res) => {
  const { course_name, session_number, session_date, students } = req.body;

  try {
    for (const student of students) {
      const { student_id, is_present } = student;

      // Check if attendance already exists for this student in this session
      const checkQuery = `
        SELECT attendance_id
        FROM attendance
        WHERE course_name = $1 AND session_number = $2::int AND student_id = $3
      `;
      const checkResult = await pool.query(checkQuery, [course_name, session_number, student_id]);

      if (checkResult.rows.length > 0) {
        // Update existing attendance record
        await pool.query(
          `
            UPDATE attendance
            SET is_present = $1, session_date = $2, marked_at = NOW()
            WHERE attendance_id = $3
          `,
          [is_present, session_date, checkResult.rows[0].attendance_id]
        );
      } else {
        // Insert new attendance record (session_id is set to NULL for manual entry)
        await pool.query(
          `
            INSERT INTO attendance (
              student_id, session_id, is_present, session_date,
              session_number, course_name, marked_at
            )
            VALUES ($1, NULL, $2, $3, $4::int, $5, NOW())
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
