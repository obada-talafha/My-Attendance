import pool from '../db/index.js';
import bcrypt from 'bcryptjs'; // Import bcrypt

// Helper function to handle login logic for ddifferent user types
const handleLogin = async (req, res, tableName, idColumnName) => {
  console.log(`REQ BODY (${tableName}):`, req.body);

  const { email, password } = req.body;

  try {
    // 1. Retrieve user by email (don't query by password directly)
    // Select the 'password' column which now stores the hash
    const result = await pool.query(
      `SELECT *, password FROM "${tableName}" WHERE "email" = $1`,
      [email]
    );

    if (result.rows.length > 0) {
      const user = result.rows[0];
      const storedHashedPassword = user.password; // Get the stored hashed password from the 'password' column

      // 2. Compare the plain-text password with the stored hash
      const passwordMatches = await bcrypt.compare(password, storedHashedPassword);

      if (passwordMatches) {
        res.status(200).json({
          success: true,
          userType: tableName, // e.g., "student", "instructor"
          user: {
            id: user[idColumnName], // Dynamically get the ID (student_id or instructor_id)
            name: user.name,
            email: user.email,
          }
        });
      } else {
        // Passwords do not match
        res.status(401).json({ success: false, message: 'Invalid credentials' });
      }
    } else {
      // User not found
      res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
  } catch (err) {
    console.error(`${tableName} Login Error:`, err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

// LOGIN FOR STUDENT
const loginStudent = async (req, res) => {
  await handleLogin(req, res, 'student', 'student_id');
};

// LOGIN FOR INSTRUCTOR
const loginInstructor = async (req, res) => {
  await handleLogin(req, res, 'instructor', 'instructor_id');
};

// Removed loginAdmin function as per your request

export { loginStudent, loginInstructor };