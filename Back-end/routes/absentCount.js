import express from 'express';
import pool from '../db/index.js';

const router = express.Router();

router.post('/absents/count', async (req, res) => {
  const { student_id, course_name, session_number } = req.body;

  if (!student_id || !course_name || !session_number) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const query = `
      SELECT COUNT(*) AS count
      FROM attendance
      WHERE student_id = $1
        AND course_name = $2
        AND session_number = $3
        AND is_present = false;
    `;

    const result = await pool.query(query, [student_id, course_name, session_number]);
    const count = parseInt(result.rows[0].count, 10);

    res.json({ count });
  } catch (err) {
    console.error('Error fetching absent count:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
