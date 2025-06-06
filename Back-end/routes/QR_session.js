import pool from '../db/index.js';
import crypto from 'crypto';

const createQRSession = async (req, res) => {
  const { course_name, session_number } = req.body;

  if (!course_name || !session_number) {
    return res.status(400).json({ success: false, message: 'Missing course_name or session_number' });
  }

  try {
    const session_date = new Date();
    const qr_token = crypto.randomBytes(16).toString('hex');

    const result = await pool.query(
      `INSERT INTO qr_session (course_name, session_number, session_date, qr_token)
       VALUES ($1, $2, $3, $4)
       RETURNING *`,
      [course_name, session_number, session_date, qr_token]
    );

    const session = result.rows[0];

    res.status(201).json({
      success: true,
      session,
    });
  } catch (err) {
    console.error('Create QR Session Error:', err.message);
    res.status(500).json({ success: false, message: 'Server error' });
  }
};

export { createQRSession };
