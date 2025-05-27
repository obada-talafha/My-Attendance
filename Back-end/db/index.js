import dotenv from 'dotenv';
import pkg from 'pg';

const { Pool } = pkg;

// Load environment variables from .env file
dotenv.config();

// ✅ Debug print for DB_HOST
console.log("✅ Loaded DB config:");
console.log("DB_HOST:", process.env.DB_HOST);
console.log("DB_USER:", process.env.DB_USER);
console.log("DB_DATABASE:", process.env.DB_DATABASE);
console.log("DB_PORT:", process.env.DB_PORT);

// ✅ Setup PostgreSQL connection pool with SSL
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.DB_PORT, 10), // ensure it's a number
  ssl: {
    rejectUnauthorized: false,  // important for Render managed PostgreSQL SSL
  },
});

// ✅ Optional: test connection immediately
pool.connect()
  .then(client => {
    console.log('✅ Connected to PostgreSQL database');
    client.release(); // release back to pool
  })
  .catch(err => {
    console.error('❌ Failed to connect to PostgreSQL:', err.message);
  });

export default pool;
