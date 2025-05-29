import pool from '../db/index.js';

const getInstructorHome = async (req, res) => {
  const { instructor_id } = req.query;

  if (!instructor_id) {
    return res.status(400).json({
      success: false,
      message: "Instructor ID is required",
    });
  }

  try {
    const result = await pool.query(
      `SELECT
         c.course_name,
         c.session_number,
         c.session_time,
         c.days
       FROM "course" c
       JOIN courseinstructor ci ON c.course_name = ci.course_name AND c.session_number = ci.session_number
       WHERE ci.instructor_id = $1`,
      [instructor_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No courses found for this instructor',
      });
    }

    res.status(200).json({
      success: true,
      courses: result.rows,
    });
  } catch (err) {
    console.error('Get Instructor Home Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { getInstructorHome as getInstructorCourses };
