import express from 'express';
import pool from '../db/index.js'; // Your pool export

const router = express.Router();

router.post('/absents', async (req, res) => {
  const { student_id, course_name, session_number } = req.body;

  if (!student_id || !course_name || !session_number) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const query = `
      SELECT session_date
      FROM attendance
      WHERE student_id = $1
        AND course_name = $2
        AND session_number = $3
        AND is_present = false
      ORDER BY session_date DESC;
    `;

    const result = await pool.query(query, [student_id, course_name, session_number]);

    const absentDates = result.rows.map(row => {
      const date = new Date(row.session_date);
      const options = { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric' };
      return {
        date: row.session_date.toISOString().split('T')[0],
        day: date.toLocaleDateString('en-US', options).split(',')[0],
      };
    });

    res.json({
      count: absentDates.length, // Total number of absences
      absents: absentDates
    });
  } catch (err) {
    console.error('Error fetching absents:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
