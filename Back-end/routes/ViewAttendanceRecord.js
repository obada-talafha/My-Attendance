import express from 'express';
import pool from '../db/index.js';

const ViewAttendanceRecord = express.Router();

/**
 * GET students and their attendance info for a given course, session, and date
 */
ViewAttendanceRecord.get('/:courseName/:sessionNumber/:sessionDate', async (req, res) => {
  const { courseName, sessionNumber, sessionDate } = req.params;

  try {
    // Step 1: Check if any records exist for this session and date
    // This check is good as it is.
    const attendanceExists = await pool.query(
      `
      SELECT COUNT(*) AS count
      FROM attendance
      WHERE course_name = $1 AND session_number = $2::int AND session_date = $3
      `,
      [courseName, sessionNumber, sessionDate]
    );

    const count = parseInt(attendanceExists.rows[0].count, 10);
    if (count === 0) {
      // If no attendance records for this specific session and date,
      // return an empty array but with success.
      return res.status(200).json({ success: true, records: [] });
    }

    // Step 2: Return all enrolled students and their status for this day
    const studentsQuery = `
      SELECT
        s.student_id,
        s.name AS student_name,
        -- Calculate absence_count for the specific course,
        -- counting absences up to (but not including) the current session number.
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
          course_name = $1 AND -- Filter by the current course
          session_number < $2::int -- Count absences before the current session number
        GROUP BY student_id
      ) a_abs ON a_abs.student_id = s.student_id
      LEFT JOIN (
        SELECT student_id, is_present
        FROM attendance
        WHERE course_name = $1 AND session_number = $2::int AND session_date = $3
      ) a_session ON a_session.student_id = s.student_id
      WHERE e.course_name = $1 AND e.session_number::int = $2::int
    `;

    const { rows } = await pool.query(studentsQuery, [courseName, sessionNumber, sessionDate]);
    res.status(200).json({ success: true, records: rows });
  } catch (error) {
    console.error('Error fetching attendance records:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
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
      // It seems the intention here is to only *update* existing records, not create new ones.
      // If no records are found for this specific date/session, it makes sense to return a 404.
      return res.status(404).json({
        success: false,
        message: 'No attendance records found for this session on the selected date. Cannot update.'
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

    res.status(200).json({ success: true, message: 'Attendance records updated successfully.' });
  } catch (error) {
    console.error('Error updating attendance records:', error);
    res.status(500).json({ success: false, error: 'Internal server error' });
  }
});

export { ViewAttendanceRecord };