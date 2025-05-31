import pool from '../db/index.js'; // Assuming you have the pool setup for database connection

// Mark student as absent (insert record)
const markAbsent = async (req, res) => {
  const { student_id, session_id } = req.body;

  // Check if required fields are provided
  if (!student_id || !session_id) {
    return res.status(400).json({ success: false, message: "Missing required fields" });
  }

  try {
    // Insert attendance with default is_present = false (absent)
    const result = await pool.query(
      `INSERT INTO attendance (student_id, session_id, is_present)
       VALUES ($1, $2, false)
       ON CONFLICT (student_id, session_id)
       DO UPDATE SET is_present = false, verified_face = false`,
      [student_id, session_id]
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
