import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';

// Import routes
import { loginStudent, loginAdmin, loginInstructor } from './routes/auth.js';
import { getStudentProfile } from './routes/studentController.js';
import { getStudentCourses } from './routes/studentHome.js';
import { getInstructorHome } from './routes/instructorHome.js';
import { getInstructorProfile } from './routes/instructorProfile.js';

// New routes
import { getStudentAbsences } from './routes/getStudentAbsence.js';
import { markAbsent } from './routes/markAbsences.js';
import { deleteAttendance } from './routes/deleteAbsences.js';
import { getStudentsInCourse } from './routes/viewAllStudentInCourse.js';
import { createQRSession } from './routes/QR_session.js';
import { verifyFace } from './routes/verifyFace.js';
import studentQrAttendanceRouter from './routes/studentQrAttendance.js';
import endSessionRouter from './routes/endSession.js';
import manualAttendanceRouter from './routes/manualAttendance.js'; // ✅ NEW

const app = express();

// Middleware
app.use(cors({ origin: '*' }));
app.use(express.json());

// QR Attendance route
app.use('/mark-attendance', studentQrAttendanceRouter);

// Manual Attendance route ✅
app.use(manualAttendanceRouter);

// Auth routes
app.post('/loginStudent', loginStudent);
app.post('/loginAdmin', loginAdmin);
app.post('/loginInstructor', loginInstructor);

// Student routes
app.get('/studentHome', getStudentCourses);
app.get('/studentProfile', getStudentProfile);
app.get('/student-absences', getStudentAbsences);

// Instructor routes
app.get('/instructorHome', getInstructorHome);
app.get('/instructorProfile', getInstructorProfile);
app.get('/students-in-course', getStudentsInCourse);
app.post('/mark-absent', markAbsent);
app.delete('/delete-attendance', deleteAttendance);

// Session and Face verification
app.use(endSessionRouter);
app.post('/qr_code', createQRSession);
app.post('/verify-face', verifyFace);

// Start server
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
