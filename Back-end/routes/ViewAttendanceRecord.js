import express from 'express';
import pool from '../db/index.js';

const ViewAttendanceRecord = express.Router();

/**
 * GET students and their attendance info for a given course and session
 */
ViewAttendanceRecord.get('/:courseName/:sessionNumber', async (req, res) => {
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
 * Will only proceed if attendance records already exist for this date.
 */
ViewAttendanceRecord.post('/save', async (req, res) => {
  const { course_name, session_number, session_date, students } = req.body;

  try {
    console.log(`Received attendance for course: ${course_name}, session: ${session_number}, date: ${session_date}`);

    // Step 1: Check if any attendance records exist for the session on that date
    const existingRecordsCheck = await pool.query(
      `
        SELECT COUNT(*) AS count
        FROM attendance
        WHERE course_name = $1 AND session_number = $2::int AND session_date = $3
      `,
      [course_name, session_number, session_date]
    );

    const recordCount = parseInt(existingRecordsCheck.rows[0].count, 10);

    if (recordCount === 0) {
      return res.status(404).json({
        message: 'No attendance records found for this session on the selected date.'
      });
    }

    // Step 2: Update records (do NOT insert new ones)
    for (const student of students) {
      const { student_id, is_present } = student;

      await pool.query(
        `
          UPDATE attendance
          SET is_present = $1, marked_at = NOW()
          WHERE course_name = $2 AND session_number = $3::int AND student_id = $4 AND session_date = $5
        `,
        [is_present, course_name, session_number, student_id, session_date]
      );
    }

    res.status(200).json({ message: 'Attendance records updated successfully.' });
  } catch (error) {
    console.error('Error updating attendance records:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export { ViewAttendanceRecord };
