const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const users = {
  'a': { password: 'a', role: 'admin' },
  'instructor@example.com': { password: 'instructor123', role: 'instructor' },
  'student@example.com': { password: 'student123', role: 'student' },
};

app.post('/login', (req, res) => {
  const { email, password } = req.body;
  const user = users[email];

  if (user && user.password === password) {
    return res.json({
      token: 'mock-jwt-token',
      role: user.role,
    });
  }

  return res.status(401).json({ message: 'Invalid credentials' });
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
