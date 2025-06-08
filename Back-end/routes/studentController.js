import pool from '../db/index.js';

const getStudentProfile = async (req, res) => {
  const { student_id } = req.query;

  try {
    const result = await pool.query(
      'SELECT name, student_id, email, birthdate, major, academiclvl, status FROM "student" WHERE "student_id" = $1',
      [student_id]
    );

    if (result.rows.length > 0) {
      res.status(200).json({
        success: true,
        student: result.rows[0],
      });
    } else {
      res.status(404).json({ success: false, message: 'Student not found' });
    }
  } catch (err) {
    console.error('Get Student Profile Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

const getStudentImage = async (req, res) => {
  const { student_id } = req.query;

  try {
    const result = await pool.query(
      'SELECT image FROM "student" WHERE "student_id" = $1',
      [student_id]
    );

    if (result.rows.length > 0) {
      const { image } = result.rows[0];
      if (image) {
        res.status(200).json({ success: true, image });
      } else {
        res.status(404).json({ success: false, message: 'Image not found' });
      }
    } else {
      res.status(404).json({ success: false, message: 'Student not found' });
    }
  } catch (err) {
    console.error('Get Student Image Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { getStudentProfile, getStudentImage };
