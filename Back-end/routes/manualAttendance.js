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

    // 1. Get session_id for the course and session_number
    const sessionResult = await pool.query(
      `
        SELECT session_id
        FROM session
        WHERE course_name = $1 AND session_number = $2::int
      `,
      [course_name, session_number]
    );

    if (sessionResult.rows.length === 0) {
      // Return error immediately — session must exist before saving attendance
      return res.status(400).json({
        error: `Session not found for course "${course_name}" and session number ${session_number}. Please create the session first.`,
      });
    }

    const session_id = sessionResult.rows[0].session_id;

    // 2. Loop over students and insert/update attendance
    for (const student of students) {
      const { student_id, is_present } = student;

      // Check if attendance record exists
      const checkResult = await pool.query(
        `
          SELECT attendance_id
          FROM attendance
          WHERE course_name = $1 AND session_number = $2::int AND student_id = $3
        `,
        [course_name, session_number, student_id]
      );

      if (checkResult.rows.length > 0) {
        // Update attendance record
        await pool.query(
          `
            UPDATE attendance
            SET is_present = $1, session_date = $2, marked_at = NOW()
            WHERE attendance_id = $3
          `,
          [is_present, session_date, checkResult.rows[0].attendance_id]
        );
      } else {
        // Insert new attendance record
        await pool.query(
          `
            INSERT INTO attendance (
              student_id, session_id, is_present, session_date,
              session_number, course_name, marked_at
            )
            VALUES ($1, $2, $3, $4, $5::int, $6, NOW())
          `,
          [student_id, session_id, is_present, session_date, session_number, course_name]
        );
      }
    }

    // 3. Respond success
    res.status(200).json({ message: 'Attendance saved successfully' });
  } catch (error) {
    console.error('Error saving manual attendance:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export { manualAttendanceRouter };
