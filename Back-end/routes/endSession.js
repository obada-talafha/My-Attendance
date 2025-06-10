import express from 'express';
import pool from '../db/index.js'; // Assuming your database connection pool is here

const router = express.Router();

router.post('/end-session', async (req, res) => {
  // Destructure all expected fields from the request body, including session_date
  const { course_name, session_number, session_date } = req.body;

  // Validate that all required fields are present
  if (!course_name || !session_number || !session_date) {
    return res.status(400).json({ message: 'Missing course_name, session_number, or session_date in request body.' });
  }

  let client; // Declare client outside try-catch for broader scope
  try {
    client = await pool.connect(); // Acquire a client from the connection pool

    // 1. Get the session_id using course_name, session_number, and the provided session_date.
    //    We explicitly cast both the `session_date` column and the incoming `$3` parameter to `DATE`
    //    to ensure comparisons are only based on the date part, regardless of the column's original type
    //    (e.g., DATE, TIMESTAMP, TIMESTAMPTZ). This prevents issues with time components.
    const sessionRes = await client.query(
      `SELECT session_id
       FROM qr_session
       WHERE course_name = $1
         AND session_number = $2
         AND session_date::date = $3::date`, // Cast to DATE for robust comparison
      [course_name, session_number, session_date] // Pass session_date as a parameter
    );

    // Check if a session matching the criteria was found
    if (sessionRes.rowCount === 0) {
      return res.status(404).json({ message: 'Session not found for the provided course, session number, and date.' });
    }

    // Extract the session_id from the query result
    const { session_id } = sessionRes.rows[0];

    // 2. Get all student IDs enrolled in this specific course and session number.
    //    This assumes 'enrollment' tracks students by course_name and session_number.
    const enrolledRes = await client.query(
      `SELECT student_id
       FROM enrollment
       WHERE course_name = $1 AND session_number = $2`,
      [course_name, session_number]
    );
    // Map the results to an array of student_ids
    const enrolledIds = enrolledRes.rows.map(row => row.student_id);

    // 3. Get all student IDs who have successfully marked their attendance for this session.
    const presentRes = await client.query(
      `SELECT student_id
       FROM attendance
       WHERE session_id = $1 AND is_present = true`,
      [session_id]
    );
    // Map the results to an array of student_ids who are present
    const presentIds = presentRes.rows.map(row => row.student_id);

    // 4. Determine which enrolled students did NOT attend (i.e., are absent).
    //    Filter 'enrolledIds' to find those not present in 'presentIds'.
    const absentees = enrolledIds.filter(id => !presentIds.includes(id));

    // 5. If there are absentees, insert them into the 'attendance' table.
    //    Using batch insert for efficiency.
    if (absentees.length > 0) {
      const values = []; // Array to hold the `($1, $2, ...)` placeholders for each row
      const params = [session_id]; // Start params array with session_id ($1)

      // Loop through each absentee to build the VALUES string and parameters
      absentees.forEach((student_id, index) => {
        // Calculate the base index for parameters for the current absentee.
        // session_id is $1, so other params start from $2
        const base = index * 4 + 2;
        values.push(`($1, $${base}, false, false, NOW(), $${base + 1}, $${base + 2}, $${base + 3})`);
        // Add the absentee's student_id, the received session_date, session_number, and course_name
        params.push(student_id, session_date, session_number, course_name);
      });

      const insertQuery = `
        INSERT INTO attendance (
          session_id, student_id, is_present, verified_face,
          marked_at, session_date, session_number, course_name
        ) VALUES ${values.join(', ')}
        ON CONFLICT (student_id, course_name, session_number, session_date) DO NOTHING
      `;
      // Execute the batch insert query
      await client.query(insertQuery, params);
    }

    // Send a success response
    res.status(200).json({
      message: 'Session ended and absentees marked successfully.',
      absenteesCount: absentees.length,
    });

  } catch (error) {
    // Log any errors that occur during thev process
    console.error('Error ending session:', error);
    // Send an internal server error response
    res.status(500).json({ message: 'Internal server error occurred while ending session.' });
  } finally {
    // Ensure the client is released back to the pool, even if an error occurs
    if (client) {
      client.release();
    }
  }
});

export default router;