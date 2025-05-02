import cors from "cors";
import express from 'express';
import bodyParser from 'body-parser';
import { loginStudent, loginAdmin, loginInstructor } from './routes/auth.js';
import { getStudentProfile } from './routes/studentController.js';
import { getStudentCourses } from "./routes/studentHome.js";
import { getInstructorCourses } from "./routes/instructorHome.js";
import { getInstructorProfile } from "./routes/instructorProfile.js";

const app = express();
app.use(cors({
  origin: '*', // Allow all origins for now (for testing, you can specify the origin URL later)
}));

app.use(express.json()); // For handling JSON requests

// Routes for login
app.post('/loginStudent', loginStudent);
app.post('/loginAdmin', loginAdmin);
app.post('/loginInstructor', loginInstructor);
app.get('/studentHome',getStudentCourses);
app.get('/studentProfile', getStudentProfile);
app.get('/instructorHome', getInstructorCourses);
app.get('/instructorProfile',getInstructorProfile);

const PORT = 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});

