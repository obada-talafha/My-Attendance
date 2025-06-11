import express from 'express';
import cors from 'cors';

// Import routes (auth)
import { loginStudent, loginInstructor } from './routes/auth.js';

// Student routes
import { getStudentProfile } from './routes/studentController.js'; // ✅ renamed for clarity
import { getStudentImage } from './routes/studentController.js';   // ✅ image route added
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
import studentQrAttendanceRouter from './routes/studentQrAttendance.js';
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
app.get('/studentImage', getStudentImage); // ✅ NEW ROUTE ADDED
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
app.use('/mark-attendance', studentQrAttendanceRouter);
app.use(endSessionRouter);

// ✍️ Manual Attendance
app.use('/manual-attendance', manualAttendanceRouter);
app.use('/ViewAttendanceRecord', ViewAttendanceRecord);

// === SERVER START ===
const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});
