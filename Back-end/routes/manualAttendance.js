import express from 'express';
import pool from '../db/index.js';

const manualAttendanceRouter = express.Router();

/**
 * GET students and their attendance info for a given course and session
 */
manualAttendanceRouter.post('/save', async (req, res) => {
  const { course_name, session_number, session_date, students } = req.body;

  try {
    console.log(`Received attendance for course: ${course_name}, session: ${session_number}`);

    for (const student of students) {
      const { student_id, is_present } = student;

      const checkResult = await pool.query(
        `
          SELECT attendance_id
          FROM attendance
          WHERE course_name = $1 AND session_number = $2::int AND student_id = $3 AND session_date = $4
        `,
        [course_name, session_number, student_id, session_date]
      );

      if (checkResult.rows.length > 0) {
        await pool.query(
          `
            UPDATE attendance
            SET is_present = $1, marked_at = NOW()
            WHERE attendance_id = $2
          `,
          [is_present, checkResult.rows[0].attendance_id]
        );
      } else {
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

    // ✅ FIXED response
    res.status(200).json({
      success: true,
      message: 'Attendance saved successfully'
    });

  } catch (error) {
    console.error('Error saving manual attendance:', error);
    res.status(500).json({
      success: false,
      error: 'Internal server error'
    });
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
