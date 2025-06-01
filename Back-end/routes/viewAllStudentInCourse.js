import pool from '../db/index.js';

//Updated 1/6/2025

// Get all students in a specific course session with absence count
const getStudentsInCourse = async (req, res) => {
  const { course_name, session_number } = req.query;

  if (!course_name || !session_number) {
    return res.status(400).json({
      success: false,
      message: "course_name and session_number are required"
    });
  }

  try {
    const result = await pool.query(
      `SELECT
         s.student_id,
         s.name AS student_name,
         s.email,
         COALESCE(a.absents, 0) AS absents
       FROM enrollment e
       JOIN student s ON e.student_id = s.student_id
       LEFT JOIN (
         SELECT
           a.student_id,
           COUNT(*) AS absents
         FROM attendance a
         JOIN qr_session qs ON a.session_id = qs.session_id
         WHERE a.is_present = FALSE
           AND qs.course_name = $1
           AND qs.session_number = $2
         GROUP BY a.student_id
       ) a ON a.student_id = s.student_id
       WHERE e.course_name = $1 AND e.session_number = $2`,
      [course_name, session_number]
    );

    if (result.rows.length > 0) {
      res.status(200).json({
        success: true,
        students: result.rows,
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'No students found for this course',
      });
    }
  } catch (err) {
    console.error('Get Students in Course Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { getStudentsInCourse };
