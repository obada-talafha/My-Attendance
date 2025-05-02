import pool from '../db/index.js';

const getStudentCourses = async (req, res) => {
  const { student_id } = req.query;

  try {
    const result = await pool.query(
      `SELECT
         c.course_name,
         c.session_number,
         c.days,
         c.session_time,
         c.session_location,
         c.credit_hours,
         c.absents,
         c.student_id,
         c.instructor_id,
         i.name AS instructor_name
       FROM "course" c
       JOIN "instructor" i ON c.instructor_id = i.instructor_id
       WHERE c.student_id = $1`,
      [student_id]
    );

    if (result.rows.length > 0) {
      res.status(200).json({
        success: true,
        courses: result.rows,
      });
    } else {
      res.status(404).json({
        success: false,
        message: 'No courses found for this student',
      });
    }
  } catch (err) {
    console.error('Get Student Courses Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { getStudentCourses };
