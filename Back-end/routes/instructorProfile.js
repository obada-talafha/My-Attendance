import pool from '../db/index.js';

const getInstructorProfile = async (req, res) => {
  const { instructor_id } = req.query;

  try {
    const result = await pool.query(
      `SELECT
         name,
         department,
         college,
         birthdate,
         phonenum,
         image
       FROM "instructor"
       WHERE instructor_id = $1`,
      [instructor_id]
    );

    if (result.rows.length > 0) {
      const instructor = result.rows[0];
      res.status(200).json({
        success: true,
        instructor: instructor,
      });
    } else {
      res.status(404).json({ success: false, message: 'Instructor not found' });
    }
  } catch (err) {
    console.error('Get Instructor Profile Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { getInstructorProfile };
