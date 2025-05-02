import pool from '../db/index.js';

// LOGIN FOR STUDENT
const loginStudent = async (req, res) => {
  console.log("REQ BODY (student):", req.body);

  const { email, password } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM "student" WHERE "email" = $1 AND "password" = $2',
      [email, password]
    );

    if (result.rows.length > 0) {
      const student = result.rows[0];
      res.status(200).json({
        success: true,
        userType: "student",
        user: {
          id: student.student_id,
          name: student.name,
          email: student.email,
        }
      });
    } else {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
  } catch (err) {
    console.error('Student Login Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// LOGIN FOR ADMIN
const loginAdmin = async (req, res) => {
  console.log("REQ BODY (admin):", req.body);

  const { email, password } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM "admin" WHERE "email" = $1 AND "password" = $2',
      [email, password]
    );

    if (result.rows.length > 0) {
      const admin = result.rows[0];
      res.status(200).json({
        success: true,
        userType: "admin",
        user: {
          id: admin.admin_id,
          name: admin.name,
          email: admin.email,
        }
      });
    } else {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
  } catch (err) {
    console.error('Admin Login Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// LOGIN FOR INSTRUCTOR
const loginInstructor = async (req, res) => {
  console.log("REQ BODY (instructor):", req.body);

  const { email, password } = req.body;

  try {
    const result = await pool.query(
      'SELECT * FROM "instructor" WHERE "email" = $1 AND "password" = $2',
      [email, password]
    );

    if (result.rows.length > 0) {
      const instructor = result.rows[0];
      res.status(200).json({
        success: true,
        userType: "instructor",
        user: {
          id: instructor.instructor_id,
          name: instructor.name,
          email: instructor.email,
        }
      });
    } else {
      res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
  } catch (err) {
    console.error('Instructor Login Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { loginStudent, loginAdmin, loginInstructor };
