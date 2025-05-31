import pool from '../db/index.js';

//changed 31/5/2025


const getStudentAbsences = async (req, res) => {
  const { student_id } = req.query;

  if (!student_id) {
    return res.status(400).json({
      success: false,
      message: 'Student ID is required',
    });
  }

  try {
    const result = await pool.query(
      `SELECT 
         q.course_name, 
         q.session_number, 
         q.session_date
       FROM attendance a
       JOIN QR q ON a.session_id = q.session_id
       WHERE a.student_id = $1 AND a.is_present = FALSE
       ORDER BY q.session_date ASC`,
      [student_id]
    );

    if (result.rows.length > 0) {
      res.status(200).json({
        success: true,
        absences: result.rows,
      });
    } else {
      res.status(200).json({
        success: true,
        message: 'No absences found for this student',
      });
    }
  } catch (err) {
    console.error('Get Student Absences Error:', err.message);
    res.status(500).json({
      success: false,
      message: 'Server error',
    });
  }
};

export { getStudentAbsences };
