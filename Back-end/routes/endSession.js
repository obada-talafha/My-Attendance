import express from 'express';
import pool from '../db/index.js';

const router = express.Router();

router.post('/end-session', async (req, res) => {
  const { course_name, session_number } = req.body;

  if (!course_name || !session_number) {
    return res.status(400).json({ message: 'Missing course_name or session_number' });
  }

  try {
    const client = await pool.connect();

    // Get the latest session for the course and session number
    const sessionRes = await client.query(
      `SELECT session_id, session_date
       FROM qr_session
       WHERE course_name = $1 AND session_number = $2
       ORDER BY created_at DESC
       LIMIT 1`,
      [course_name, session_number]
    );

    if (sessionRes.rowCount === 0) {
      client.release();
      return res.status(404).json({ message: 'Session not found' });
    }

    const { session_id, session_date } = sessionRes.rows[0];

    // Get all students enrolled in this course/session
    const enrolledRes = await client.query(
      `SELECT student_id
       FROM enrollment
       WHERE course_name = $1 AND session_number = $2`,
      [course_name, session_number]
    );
    const enrolledIds = enrolledRes.rows.map(row => row.student_id);

    // Get all students who attended this session
    const presentRes = await client.query(
      `SELECT student_id
       FROM attendance
       WHERE session_id = $1 AND is_present = true`,
      [session_id]
    );
    const presentIds = presentRes.rows.map(row => row.student_id);

    // Find students who didn't attend
    const absentees = enrolledIds.filter(id => !presentIds.includes(id));

    // Optimized batch insert for absentees
    if (absentees.length > 0) {
      const values = [];
      const params = [session_id]; // session_id will be $1

      absentees.forEach((student_id, index) => {
        const base = index * 4 + 2; // param index starts after session_id
        values.push(`($1, $${base}, false, false, NOW(), $${base + 1}, $${base + 2}, $${base + 3})`);
        params.push(student_id, session_date, session_number, course_name);
      });

      const insertQuery = `
        INSERT INTO attendance (
          session_id, student_id, is_present, verified_face,
          marked_at, session_date, session_number, course_name
        ) VALUES ${values.join(', ')}
        ON CONFLICT (student_id, course_name, session_number, session_date) DO NOTHING
      `;

      await client.query(insertQuery, params);
    }

    client.release();

    res.status(200).json({
      message: 'Session ended and absentees marked.',
      absenteesCount: absentees.length,
    });

  } catch (error) {
    console.error('Error ending session:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
});

export default router;
