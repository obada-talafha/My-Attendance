import pool from '../db/index.js';

const getInstructorCourses = async (req, res) => {
  const { instructor_id } = req.query;

  try {
    const result = await pool.query(
      `SELECT
         course_name,
         session_number,
         days,
         session_time
       FROM "course"
       WHERE instructor_id = $1`,
      [instructor_id]
    );

    if (result.rows.length > 0) {
      res.status(200).json({
        success: true,
        courses: result.rows,
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'No courses found for this instructor',
      });
    }
  } catch (err) {
    console.error('Get Instructor Courses Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { getInstructorCourses };
