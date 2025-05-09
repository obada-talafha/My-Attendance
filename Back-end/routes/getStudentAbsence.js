import pool from '../db/index.js'; // Assuming you have the pool setup for database connection

// Get student absences
const getStudentAbsences = async (req, res) => {
  const { student_id } = req.query;

  // Check if student_id is provided
  if (!student_id) {
    return res.status(400).json({ success: false, message: 'Student ID is required' });
  }

  try {
    // Fetch absences for the student (only where status is 'absent')
    const result = await pool.query(
      `SELECT course_name, session_number, attendance_date
       FROM attendance
       WHERE student_id = $1 AND status = 'absent'
       ORDER BY attendance_date DESC`,
      [student_id]
    );

    if (result.rows.length > 0) {
      // If absences found, return them
      res.status(200).json({
        success: true,
        absences: result.rows,
      });
    } else {
      // If no absences found, return a success message
      res.status(200).json({
        success: true,
        message: 'No absences found for this student',
      });
    }
  } catch (err) {
    console.error('Get Student Absences Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { getStudentAbsences };
