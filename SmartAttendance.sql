--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin (
    admin_id integer NOT NULL,
    name character varying(100),
    birthdate date,
    email character varying(100),
    password character varying(100),
    lastlogin timestamp without time zone,
    phonenum character varying(20)
);


ALTER TABLE public.admin OWNER TO postgres;

--
-- Name: admin_admin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admin_admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_admin_id_seq OWNER TO postgres;

--
-- Name: admin_admin_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admin_admin_id_seq OWNED BY public.admin.admin_id;


--
-- Name: attendance; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.attendance (
    student_id integer NOT NULL,
    course_name character varying(50) NOT NULL,
    session_number character varying(50) NOT NULL,
    attendance_date date DEFAULT CURRENT_DATE NOT NULL,
    status character varying(20) DEFAULT 'absent'::character varying
);


ALTER TABLE public.attendance OWNER TO postgres;

--
-- Name: course; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.course (
    course_name character varying NOT NULL,
    session_number character varying NOT NULL,
    days character varying,
    session_time character varying,
    session_location character varying,
    credit_hours integer,
    absents integer
);


ALTER TABLE public.course OWNER TO postgres;

--
-- Name: courseinstructor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.courseinstructor (
    instructor_id integer NOT NULL,
    course_name character varying(50) NOT NULL,
    session_number character varying(50) NOT NULL
);


ALTER TABLE public.courseinstructor OWNER TO postgres;

--
-- Name: enrollment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrollment (
    student_id integer NOT NULL,
    course_name character varying(50) NOT NULL,
    session_number character varying(50) NOT NULL
);


ALTER TABLE public.enrollment OWNER TO postgres;

--
-- Name: instructor; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.instructor (
    instructor_id integer NOT NULL,
    name character varying(100),
    email character varying(100),
    password character varying(100),
    department character varying(100),
    college character varying(100),
    birthdate date,
    phonenum character varying(20),
    image text
);


ALTER TABLE public.instructor OWNER TO postgres;

--
-- Name: instructor_instructor_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.instructor_instructor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.instructor_instructor_id_seq OWNER TO postgres;

--
-- Name: instructor_instructor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.instructor_instructor_id_seq OWNED BY public.instructor.instructor_id;


--
-- Name: student; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.student (
    student_id integer NOT NULL,
    name character varying(100),
    email character varying(100),
    password character varying(100),
    academiclvl character varying(50),
    major character varying(100),
    gender character varying(10),
    image text,
    birthdate date,
    phonenum character varying(20),
    status character(50)
);


ALTER TABLE public.student OWNER TO postgres;

--
-- Name: student_student_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.student_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.student_student_id_seq OWNER TO postgres;

--
-- Name: student_student_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.student_student_id_seq OWNED BY public.student.student_id;


--
-- Name: admin admin_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin ALTER COLUMN admin_id SET DEFAULT nextval('public.admin_admin_id_seq'::regclass);


--
-- Name: instructor instructor_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor ALTER COLUMN instructor_id SET DEFAULT nextval('public.instructor_instructor_id_seq'::regclass);


--
-- Name: student student_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student ALTER COLUMN student_id SET DEFAULT nextval('public.student_student_id_seq'::regclass);


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin (admin_id, name, birthdate, email, password, lastlogin, phonenum) FROM stdin;
222	yousef	1990-11-09	hh@gmail.com	1111	\N	0123456789
\.


--
-- Data for Name: attendance; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.attendance (student_id, course_name, session_number, attendance_date, status) FROM stdin;
\.


--
-- Data for Name: course; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.course (course_name, session_number, days, session_time, session_location, credit_hours, absents) FROM stdin;
CS111	1	sun-mon	10-11	A2123	3	0
CS111	2	sun-mon	11-12	G2123	3	0
h	1	any	2-3	hi	3	0
cs	1	hi	10-11	aaa	3	0
\.


--
-- Data for Name: courseinstructor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.courseinstructor (instructor_id, course_name, session_number) FROM stdin;
\.


--
-- Data for Name: enrollment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrollment (student_id, course_name, session_number) FROM stdin;
\.


--
-- Data for Name: instructor; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.instructor (instructor_id, name, email, password, department, college, birthdate, phonenum, image) FROM stdin;
111	yousef	h@gmail.com	122	cs	cs	1990-11-09	123456789	\N
\.


--
-- Data for Name: student; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.student (student_id, name, email, password, academiclvl, major, gender, image, birthdate, phonenum, status) FROM stdin;
155349	yousef	hi@gmail.com	123	3	cs	male	null	2003-11-09	791051279	Expected to graduate                              
1	aa	a	a	3	cs	m	\N	2003-11-09	123456789	any                                               
\.


--
-- Name: admin_admin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_admin_id_seq', 1, false);


--
-- Name: instructor_instructor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.instructor_instructor_id_seq', 1, false);


--
-- Name: student_student_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.student_student_id_seq', 1, false);


--
-- Name: admin admin_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_email_key UNIQUE (email);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (admin_id);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (student_id, course_name, session_number, attendance_date);


--
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (course_name, session_number);


--
-- Name: courseinstructor courseinstructor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courseinstructor
    ADD CONSTRAINT courseinstructor_pkey PRIMARY KEY (instructor_id, course_name, session_number);


--
-- Name: enrollment enrollment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_pkey PRIMARY KEY (student_id, course_name, session_number);


--
-- Name: instructor instructor_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_email_key UNIQUE (email);


--
-- Name: instructor instructor_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_pkey PRIMARY KEY (instructor_id);


--
-- Name: student student_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_email_key UNIQUE (email);


--
-- Name: student student_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (student_id);


--
-- Name: attendance attendance_student_id_course_name_session_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_course_name_session_number_fkey FOREIGN KEY (student_id, course_name, session_number) REFERENCES public.enrollment(student_id, course_name, session_number) ON DELETE CASCADE;


--
-- Name: courseinstructor courseinstructor_course_name_session_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courseinstructor
    ADD CONSTRAINT courseinstructor_course_name_session_number_fkey FOREIGN KEY (course_name, session_number) REFERENCES public.course(course_name, session_number) ON DELETE CASCADE;


--
-- Name: courseinstructor courseinstructor_instructor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.courseinstructor
    ADD CONSTRAINT courseinstructor_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES public.instructor(instructor_id) ON DELETE CASCADE;


--
-- Name: enrollment enrollment_course_name_session_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_course_name_session_number_fkey FOREIGN KEY (course_name, session_number) REFERENCES public.course(course_name, session_number) ON DELETE CASCADE;


--
-- Name: enrollment enrollment_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(student_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

