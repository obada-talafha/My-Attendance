import pool from '../db/index.js';

const markAbsent = async (req, res) => {
  const { student_id, session_id } = req.body;

  if (!student_id || !session_id) {
    return res.status(400).json({ success: false, message: "Missing required fields" });
  }

  try {
    // Only insert if no record exists
    const result = await pool.query(
      `INSERT INTO attendance (student_id, session_id, is_present)
       SELECT $1, $2, false
       WHERE NOT EXISTS (
         SELECT 1 FROM attendance WHERE student_id = $1 AND session_id = $2
       )`,
      [student_id, session_id]
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
