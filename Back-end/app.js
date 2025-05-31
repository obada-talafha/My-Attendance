import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';

// Import routes
import { loginStudent, loginAdmin, loginInstructor } from './routes/auth.js';
import { getStudentProfile } from './routes/studentController.js';
import { getStudentCourses } from './routes/studentHome.js'; //changed
import { getInstructorCourses } from './routes/instructorHome.js'; //changed
import { getInstructorProfile } from './routes/instructorProfile.js';

//new
import { getStudentAbsences } from './routes/getStudentAbsence.js';
import { markAbsent } from './routes/markAbsences.js';
import { deleteAttendance } from './routes/deleteAbsences.js';
import { getStudentsInCourse } from './routes/viewAllStudentInCourse.js';

import { createQRSession } from './routes/QR_session.js';
import { verifyFace } from './routes/verifyFace.js';



const app = express();

// Middleware to enable CORS (you can specify your front-end URL in the `origin` for production)
app.use(cors({
  origin: '*',  // Allow all origins for now (replace with your front-end URL in production)
}));

// Middleware to parse JSON requests
app.use(express.json());

// Routes
app.post('/loginStudent', loginStudent);
app.post('/loginAdmin', loginAdmin);
app.post('/loginInstructor', loginInstructor);

// Student routes
app.get('/studentHome', getStudentCourses);
app.get('/studentProfile', getStudentProfile);
app.get('/student-absences', getStudentAbsences);

// Instructor routes
app.get('/instructorHome', getInstructorCourses);  // Make sure this route is correct
app.get('/instructorProfile', getInstructorProfile);
app.get('/students-in-course', getStudentsInCourse);
app.post('/mark-absent', markAbsent);
app.delete('/delete-attendance', deleteAttendance);

app.post('/qr_code', createQRSession);
app.post('/verify-face', verifyFace);


// Start server
const PORT = 3000;  // Use 5000 to match the API's port
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
