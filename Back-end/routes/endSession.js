import express from 'express';
import pool from '../db/index.js';

const router = express.Router();

router.post('/end-session', async (req, res) => {
  // 1. Destructure session_date from req.body
  const { course_name, session_number, session_date } = req.body;

  // 2. Add validation for session_date
  if (!course_name || !session_number || !session_date) {
    return res.status(400).json({ message: 'Missing course_name, session_number, or session_date' });
  }

  try {
    const client = await pool.connect();

    // 3. Get the session_id using course_name, session_number, and the provided session_date
    //    We no longer fetch session_date from qr_session, but use it to find the correct session_id.
    const sessionRes = await client.query(
      `SELECT session_id
       FROM qr_session
       WHERE course_name = $1 AND session_number = $2 AND session_date = $3`, // Filter by the provided date
      [course_name, session_number, session_date] // Pass session_date as a parameter
    );

    if (sessionRes.rowCount === 0) {
      client.release();
      return res.status(404).json({ message: 'Session not found for the given criteria.' });
    }

    // 4. Only destructure session_id, as session_date is now from req.body
    const { session_id } = sessionRes.rows[0];

    // Get all students enrolled in this course/session
    // NOTE: If enrollment is tied to specific session_date, you might need to adjust this query too.
    // For now, assuming enrollment is course_name/session_number specific.
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
        const base = index * 4 + 2; // param index starts after session_id (which is $1)
        values.push(`($1, $${base}, false, false, NOW(), $${base + 1}, $${base + 2}, $${base + 3})`);
        // 5. Use the session_date from req.body here
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