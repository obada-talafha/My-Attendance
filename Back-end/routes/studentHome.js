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
         e.student_id,
         c.instructor_id,
         i.name AS instructor_name,
         COALESCE(a.absents, 0) AS absents
       FROM "enrollment" e
       JOIN "course" c ON e.course_name = c.course_name AND e.session_number = c.session_number
       JOIN "instructor" i ON c.instructor_id = i.instructor_id
       LEFT JOIN (
           SELECT
             student_id,
             course_name,
             session_number,
             COUNT(*) AS absents
           FROM "attendance"
           WHERE status = 'absent'
           GROUP BY student_id, course_name, session_number
       ) a ON a.student_id = e.student_id
          AND a.course_name = e.course_name
          AND a.session_number = e.session_number
       WHERE e.student_id = $1`,
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
