// app.js (UPDATED - Ensure this is the one on your Render.com)

import express from 'express';
import cors from 'cors';

// Import routes (auth)
import { loginStudent, loginInstructor } from './routes/auth.js';

// Student routes
import { getStudentProfile } from './routes/studentController.js';
import { getStudentImage } from './routes/studentController.js';
import { getStudentCourses } from './routes/studentHome.js';
import studentAbsencesRoute from './routes/getStudentAbsences.js';

// Instructor routes
import { getInstructorHome } from './routes/instructorHome.js';
import { getInstructorProfile } from './routes/instructorProfile.js';
import { getStudentsInCourse } from './routes/viewAllStudentInCourse.js';
import { markAbsent } from './routes/markAbsences.js';
import { deleteAttendance } from './routes/deleteAbsences.js';

// QR/Face session routes
import { createQRSession } from './routes/QR_session.js';
import { verifyFace } from './routes/verifyFace.js';
import studentQrAttendanceRouter from './routes/studentQrAttendance.js'; // This router now contains /verify-qr and /mark-attendance
import endSessionRouter from './routes/endSession.js';

// Manual attendance
import { manualAttendanceRouter } from './routes/manualAttendance.js';
import { ViewAttendanceRecord } from './routes/ViewAttendanceRecord.js';

const app = express();

// === MIDDLEWARE ===
app.use(cors({ origin: '*' }));
app.use(express.json());

// === ROUTES ===

// 🔐 Auth
app.post('/loginStudent', loginStudent);
app.post('/loginInstructor', loginInstructor);

// 🎓 Student
app.get('/studentHome', getStudentCourses);
app.get('/studentProfile', getStudentProfile);
app.get('/studentImage', getStudentImage);
app.use('/student-absences', studentAbsencesRoute);

// 👨‍🏫 Instructor
app.get('/instructorHome', getInstructorHome);
app.get('/instructorProfile', getInstructorProfile);
app.get('/students-in-course', getStudentsInCourse);
app.post('/mark-absent', markAbsent);
app.delete('/delete-attendance', deleteAttendance);

// 📷 QR/Face
app.post('/qr_code', createQRSession);
app.post('/verify-face', verifyFace);
// Mount the studentQrAttendanceRouter to the root path '/'
// This will make its internal routes available directly:
// - POST /verify-qr
// - POST /mark-attendance
app.use('/', studentQrAttendanceRouter); // <--- CHANGED: Mount at root '/' to access its internal routes directly
app.use(endSessionRouter); // Ensure endSessionRouter doesn't conflict with /verify-qr or /mark-attendance

// ✍️ Manual Attendance
app.use('/manual-attendance', manualAttendanceRouter);
app.use('/ViewAttendanceRecord', ViewAttendanceRecord);

// === SERVER START ===
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});