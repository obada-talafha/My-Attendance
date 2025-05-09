import pool from '../db/index.js'; // Assuming you have the pool setup for database connection

// Delete attendance record (remove absence)
const deleteAttendance = async (req, res) => {
  const { student_id, course_name, session_number, attendance_date } = req.body;

  // Check if required fields are provided
  if (!student_id || !course_name || !session_number || !attendance_date) {
    return res.status(400).json({ success: false, message: "Missing required fields" });
  }

  try {
    // Delete the attendance record
    const result = await pool.query(
      `DELETE FROM attendance
       WHERE student_id = $1
         AND course_name = $2
         AND session_number = $3
         AND attendance_date = $4`,
      [student_id, course_name, session_number, attendance_date]
    );

    if (result.rowCount > 0) {
      res.status(200).json({
        success: true,
        message: 'Attendance record removed'
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'Attendance record not found'
      });
    }
  } catch (err) {
    console.error('Error deleting attendance:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { deleteAttendance };
