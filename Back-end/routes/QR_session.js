import pool from '../db/index.js';
import crypto from 'crypto';

const createQRSession = async (req, res) => {
  // Destructure course_name, session_number, AND session_date from the request body
  const { course_name, session_number, session_date } = req.body; // ADDED session_date

  // Add validation for session_date
  if (!course_name || !session_number || !session_date) { // MODIFIED validation
    return res.status(400).json({ success: false, message: 'Missing course_name, session_number, or session_date in request' });
  }

  try {
    // 1. Generate a new QR token
    const qr_token = crypto.randomBytes(16).toString('hex');

    // 2. Use the session_date received from the client for the insertion.
    //    PostgreSQL's DATE type will automatically extract the date part from the ISO string.
    //    If your database column is TIMESTAMP or TIMESTAMPTZ, it will store the full timestamp.
    //    The key is that the date *part* will now be consistent with what Flutter sends.
    const result = await pool.query(
      `INSERT INTO qr_session (course_name, session_number, session_date, qr_token)
       VALUES ($1, $2, $3, $4)
       RETURNING *`, // RETURNING * allows us to see the actual stored date
      [course_name, session_number, session_date, qr_token] // MODIFIED: Use passed session_date
    );

    const session = result.rows[0];

    res.status(201).json({
      success: true,
      session, // The returned 'session' object will now show the correct date
    });
  } catch (err) {
    console.error('Create QR Session Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { createQRSession };