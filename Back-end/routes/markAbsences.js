import pool from '../db/index.js';

const markAbsent = async (req, res) => {
  const { student_id, course_name, session_number, session_date } = req.body;

  if (!student_id || !course_name || !session_number || !session_date) {
    return res.status(400).json({ success: false, message: "Missing required fields" });
  }

  try {
    const result = await pool.query(
      `INSERT INTO attendance (student_id, course_name, session_number, session_date, is_present)
       VALUES ($1, $2, $3, $4, false)
       ON CONFLICT (student_id, course_name, session_number, session_date) DO NOTHING`,
      [student_id, course_name, session_number, session_date]
    );

    if (result.rowCount === 0) {
      return res.status(200).json({
        success: false,
        message: 'Attendance record already exists, no changes made'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Student marked as absent'
    });
  } catch (err) {
    console.error('Error marking absent:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { markAbsent };
