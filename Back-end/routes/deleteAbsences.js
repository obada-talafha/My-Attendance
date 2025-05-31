import pool from '../db/index.js';

//changed 31/5/2025


// Delete attendance record (remove absence)
const deleteAttendance = async (req, res) => {
  const { student_id, course_name, session_number, session_date } = req.body;

  // Validate required fields
  if (!student_id || !course_name || !session_number || !session_date) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields: student_id, course_name, session_number, session_date',
    });
  }

  try {
    // Step 1: Find the session_id from qr_session using course_name, session_number, and session_date
    const sessionResult = await pool.query(
      `SELECT session_id
       FROM qr_session
       WHERE course_name = $1
         AND session_number = $2
         AND session_date = $3`,
      [course_name, session_number, session_date]
    );

    if (sessionResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Session not found for given course and date',
      });
    }

    const sessionId = sessionResult.rows[0].session_id;

    // Step 2: Delete the attendance record using session_id and student_id
    const deleteResult = await pool.query(
      `DELETE FROM attendance
       WHERE student_id = $1 AND session_id = $2`,
      [student_id, sessionId]
    );

    if (deleteResult.rowCount > 0) {
      return res.status(200).json({
        success: true,
        message: 'Attendance record deleted successfully',
      });
    } else {
      return res.status(404).json({
        success: false,
        message: 'Attendance record not found',
      });
    }
  } catch (err) {
    console.error('Error deleting attendance:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Server error while deleting attendance record',
    });
  }
};

export { deleteAttendance };
