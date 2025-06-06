import pool from '../db/index.js';

// Updated 7/6/2025

const getStudentCourses = async (req, res) => {
  // Parse student_id to integer
  const student_id = parseInt(req.query.student_id, 10);

  // Validate parsed ID
  if (isNaN(student_id)) {
    return res.status(400).json({
      success: false,
      message: "Invalid student_id",
    });
  }

  try {
    // Step 1: Get enrolled courses and absence counts directly from attendance
const coursesResult = await pool.query(
  `SELECT
     c.course_name,
     c.session_number,
     c.days,
     c.session_time,
     c.session_location,
     c.credit_hours,
     COALESCE(a.absents, 0) AS absents
   FROM enrollment e
   JOIN course c
     ON e.course_name = c.course_name
     AND e.session_number = c.session_number
   LEFT JOIN (
     SELECT
       student_id,
       course_name,
       session_number::text AS session_number,
       COUNT(*) AS absents
     FROM attendance
     WHERE is_present = FALSE
     GROUP BY student_id, course_name, session_number
   ) a ON a.student_id = e.student_id
        AND a.course_name = e.course_name
        AND a.session_number = e.session_number
   WHERE e.student_id = $1`,
  [student_id]
);

    const courses = coursesResult.rows;

    if (courses.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'No courses found for this student',
      });
    }

    // Step 2: Fetch instructor for each course
    for (const course of courses) {
      const instructorResult = await pool.query(
        `SELECT
           ci.instructor_id,
           i.name AS instructor_name
         FROM courseinstructor ci
         JOIN instructor i ON ci.instructor_id = i.instructor_id
         WHERE ci.course_name = $1 AND ci.session_number = $2
         LIMIT 1`,
        [course.course_name, course.session_number]
      );

      const instructor = instructorResult.rows[0];

      course.instructor_id = instructor?.instructor_id ?? null;
      course.instructor_name = instructor?.instructor_name ?? null;
    }

    // Return final result
    return res.status(200).json({
      success: true,
      courses,
    });
  } catch (err) {
    console.error('Get Student Courses Error:', err.message);
    return res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

export { getStudentCourses };
