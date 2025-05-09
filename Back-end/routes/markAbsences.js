import pool from '../db/index.js'; // Assuming you have the pool setup for database connection

// Mark student as absent (insert record)
const markAbsent = async (req, res) => {
  const { student_id, course_name, session_number, attendance_date } = req.body;

  // Check if required fields are provided
  if (!student_id || !course_name || !session_number) {
    return res.status(400).json({ success: false, message: "Missing required fields" });
  }

  try {
    // Insert attendance with default status 'absent'
    const result = await pool.query(
      `INSERT INTO attendance (student_id, course_name, session_number, attendance_date)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (student_id, course_name, session_number, attendance_date)
       DO UPDATE SET status = 'absent'`,
      [student_id, course_name, session_number, attendance_date || new Date()]
    );

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
