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
        -- Calculate absence_count for the specific course,
        -- counting absences up to (but not including) the current session.
        COALESCE(a_abs.absence_count, 0) AS absence_count,
        COALESCE(a_session.is_present, false) AS is_present
      FROM enrollment e
      JOIN student s ON e.student_id = s.student_id
      LEFT JOIN (
        SELECT
          student_id,
          COUNT(*) AS absence_count
        FROM attendance
        WHERE
          is_present = false AND
          course_name = $1 AND -- Filter by course_name
          session_number < $2::int -- Only count absences BEFORE the current session
        GROUP BY student_id
      ) a_abs ON a_abs.student_id = s.student_id
      LEFT JOIN (
        SELECT student_id, is_present
        FROM attendance
        WHERE course_name = $1 AND session_number = $2::int
      ) a_session ON a_session.student_id = s.student_id
      WHERE e.course_name = $1 AND e.session_number::int = $2::int
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
    console.log(`Received attendance for course: ${course_name}, session: ${session_number}`);

    // Loop over students and insert/update attendance directly in attendance table
    for (const student of students) {
      const { student_id, is_present } = student;

      // Check if attendance record exists for this student, course, session, and date
      const checkResult = await pool.query(
        `
          SELECT attendance_id
          FROM attendance
          WHERE course_name = $1 AND session_number = $2::int AND student_id = $3 AND session_date = $4
        `,
        [course_name, session_number, student_id, session_date]
      );

      if (checkResult.rows.length > 0) {
        // Update attendance record
        await pool.query(
          `
            UPDATE attendance
            SET is_present = $1, marked_at = NOW()
            WHERE attendance_id = $2
          `,
          [is_present, checkResult.rows[0].attendance_id]
        );
      } else {
        // Insert new attendance record
        await pool.query(
          `
            INSERT INTO attendance (
              student_id, is_present, session_date,
              session_number, course_name, marked_at
            )
            VALUES ($1, $2, $3, $4::int, $5, NOW())
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