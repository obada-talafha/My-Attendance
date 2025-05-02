import pool from '../db/index.js';

// Get instructor courses
const getInstructorCourses = async (req, res) => {
  const { instructor_id } = req.query;  // Extract instructor_id from query params

  if (!instructor_id) {
    return res.status(400).json({
      success: false,
      message: "Instructor ID is required"
    });
  }

  try {
    // Query the database to fetch instructor courses
    const result = await pool.query(
      `SELECT
         course_name,
         session_number,
         session_time,
         days
       FROM "course"
       WHERE instructor_id = $1`,  // parameterized query to avoid SQL injection
      [instructor_id]
    );

    if (result.rows.length > 0) {
      // If courses found, return them as JSON
      res.status(200).json({
        success: true,
        courses: result.rows,
      });
    } else {
      // If no courses found, return a 404 message
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
