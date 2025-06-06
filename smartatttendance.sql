PGDMP                         }            SmartAttendance    15.12    15.12 /    =           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            >           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            ?           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            @           1262    16398    SmartAttendance    DATABASE     �   CREATE DATABASE "SmartAttendance" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_United States.1252';
 !   DROP DATABASE "SmartAttendance";
                postgres    false            Q           1247    24814    attendance_method    TYPE     I   CREATE TYPE public.attendance_method AS ENUM (
    'qr',
    'manual'
);
 $   DROP TYPE public.attendance_method;
       public          postgres    false            N           1247    24808    attendance_status    TYPE     N   CREATE TYPE public.attendance_status AS ENUM (
    'present',
    'absent'
);
 $   DROP TYPE public.attendance_status;
       public          postgres    false            �            1259    24957    admin    TABLE       CREATE TABLE public.admin (
    admin_id integer NOT NULL,
    name character varying(100),
    birthdate date,
    email character varying(100),
    password character varying(100),
    lastlogin timestamp without time zone,
    phonenum character varying(20)
);
    DROP TABLE public.admin;
       public         heap    postgres    false            �            1259    24960    admin_admin_id_seq    SEQUENCE     �   CREATE SEQUENCE public.admin_admin_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.admin_admin_id_seq;
       public          postgres    false    214            A           0    0    admin_admin_id_seq    SEQUENCE OWNED BY     I   ALTER SEQUENCE public.admin_admin_id_seq OWNED BY public.admin.admin_id;
          public          postgres    false    215            �            1259    24961 
   attendance    TABLE     %  CREATE TABLE public.attendance (
    student_id integer NOT NULL,
    course_name character varying(50) NOT NULL,
    session_number character varying(50) NOT NULL,
    attendance_date date DEFAULT CURRENT_DATE NOT NULL,
    status character varying(20) DEFAULT 'absent'::character varying
);
    DROP TABLE public.attendance;
       public         heap    postgres    false            �            1259    24966    course    TABLE       CREATE TABLE public.course (
    course_name character varying NOT NULL,
    session_number character varying NOT NULL,
    days character varying,
    session_time character varying,
    session_location character varying,
    credit_hours integer,
    absents integer
);
    DROP TABLE public.course;
       public         heap    postgres    false            �            1259    24971    courseinstructor    TABLE     �   CREATE TABLE public.courseinstructor (
    instructor_id integer NOT NULL,
    course_name character varying(50) NOT NULL,
    session_number character varying(50) NOT NULL
);
 $   DROP TABLE public.courseinstructor;
       public         heap    postgres    false            �            1259    24974 
   enrollment    TABLE     �   CREATE TABLE public.enrollment (
    student_id integer NOT NULL,
    course_name character varying(50) NOT NULL,
    session_number character varying(50) NOT NULL
);
    DROP TABLE public.enrollment;
       public         heap    postgres    false            �            1259    24977 
   instructor    TABLE     B  CREATE TABLE public.instructor (
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
    DROP TABLE public.instructor;
       public         heap    postgres    false            �            1259    24982    instructor_instructor_id_seq    SEQUENCE     �   CREATE SEQUENCE public.instructor_instructor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.instructor_instructor_id_seq;
       public          postgres    false    220            B           0    0    instructor_instructor_id_seq    SEQUENCE OWNED BY     ]   ALTER SEQUENCE public.instructor_instructor_id_seq OWNED BY public.instructor.instructor_id;
          public          postgres    false    221            �            1259    24983    student    TABLE     v  CREATE TABLE public.student (
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
    DROP TABLE public.student;
       public         heap    postgres    false            �            1259    24988    student_student_id_seq    SEQUENCE     �   CREATE SEQUENCE public.student_student_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.student_student_id_seq;
       public          postgres    false    222            C           0    0    student_student_id_seq    SEQUENCE OWNED BY     Q   ALTER SEQUENCE public.student_student_id_seq OWNED BY public.student.student_id;
          public          postgres    false    223            �           2604    25054    admin admin_id    DEFAULT     p   ALTER TABLE ONLY public.admin ALTER COLUMN admin_id SET DEFAULT nextval('public.admin_admin_id_seq'::regclass);
 =   ALTER TABLE public.admin ALTER COLUMN admin_id DROP DEFAULT;
       public          postgres    false    215    214            �           2604    25055    instructor instructor_id    DEFAULT     �   ALTER TABLE ONLY public.instructor ALTER COLUMN instructor_id SET DEFAULT nextval('public.instructor_instructor_id_seq'::regclass);
 G   ALTER TABLE public.instructor ALTER COLUMN instructor_id DROP DEFAULT;
       public          postgres    false    221    220            �           2604    25056    student student_id    DEFAULT     x   ALTER TABLE ONLY public.student ALTER COLUMN student_id SET DEFAULT nextval('public.student_student_id_seq'::regclass);
 A   ALTER TABLE public.student ALTER COLUMN student_id DROP DEFAULT;
       public          postgres    false    223    222            1          0    24957    admin 
   TABLE DATA           `   COPY public.admin (admin_id, name, birthdate, email, password, lastlogin, phonenum) FROM stdin;
    public          postgres    false    214   �<       3          0    24961 
   attendance 
   TABLE DATA           f   COPY public.attendance (student_id, course_name, session_number, attendance_date, status) FROM stdin;
    public          postgres    false    216   =       4          0    24966    course 
   TABLE DATA           z   COPY public.course (course_name, session_number, days, session_time, session_location, credit_hours, absents) FROM stdin;
    public          postgres    false    217   \=       5          0    24971    courseinstructor 
   TABLE DATA           V   COPY public.courseinstructor (instructor_id, course_name, session_number) FROM stdin;
    public          postgres    false    218   �=       6          0    24974 
   enrollment 
   TABLE DATA           M   COPY public.enrollment (student_id, course_name, session_number) FROM stdin;
    public          postgres    false    219   �=       7          0    24977 
   instructor 
   TABLE DATA           {   COPY public.instructor (instructor_id, name, email, password, department, college, birthdate, phonenum, image) FROM stdin;
    public          postgres    false    220   >       9          0    24983    student 
   TABLE DATA           �   COPY public.student (student_id, name, email, password, academiclvl, major, gender, image, birthdate, phonenum, status) FROM stdin;
    public          postgres    false    222   \>       D           0    0    admin_admin_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.admin_admin_id_seq', 1, false);
          public          postgres    false    215            E           0    0    instructor_instructor_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.instructor_instructor_id_seq', 1, false);
          public          postgres    false    221            F           0    0    student_student_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.student_student_id_seq', 1, false);
          public          postgres    false    223            �           2606    25004    admin admin_email_key 
   CONSTRAINT     Q   ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_email_key UNIQUE (email);
 ?   ALTER TABLE ONLY public.admin DROP CONSTRAINT admin_email_key;
       public            postgres    false    214            �           2606    25006    admin admin_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (admin_id);
 :   ALTER TABLE ONLY public.admin DROP CONSTRAINT admin_pkey;
       public            postgres    false    214            �           2606    25008    attendance attendance_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (student_id, course_name, session_number, attendance_date);
 D   ALTER TABLE ONLY public.attendance DROP CONSTRAINT attendance_pkey;
       public            postgres    false    216    216    216    216            �           2606    25010    course course_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (course_name, session_number);
 <   ALTER TABLE ONLY public.course DROP CONSTRAINT course_pkey;
       public            postgres    false    217    217            �           2606    25018 &   courseinstructor courseinstructor_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.courseinstructor
    ADD CONSTRAINT courseinstructor_pkey PRIMARY KEY (instructor_id, course_name, session_number);
 P   ALTER TABLE ONLY public.courseinstructor DROP CONSTRAINT courseinstructor_pkey;
       public            postgres    false    218    218    218            �           2606    25020    enrollment enrollment_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_pkey PRIMARY KEY (student_id, course_name, session_number);
 D   ALTER TABLE ONLY public.enrollment DROP CONSTRAINT enrollment_pkey;
       public            postgres    false    219    219    219            �           2606    25022    instructor instructor_email_key 
   CONSTRAINT     [   ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_email_key UNIQUE (email);
 I   ALTER TABLE ONLY public.instructor DROP CONSTRAINT instructor_email_key;
       public            postgres    false    220            �           2606    25024    instructor instructor_pkey 
   CONSTRAINT     c   ALTER TABLE ONLY public.instructor
    ADD CONSTRAINT instructor_pkey PRIMARY KEY (instructor_id);
 D   ALTER TABLE ONLY public.instructor DROP CONSTRAINT instructor_pkey;
       public            postgres    false    220            �           2606    25026    student student_email_key 
   CONSTRAINT     U   ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_email_key UNIQUE (email);
 C   ALTER TABLE ONLY public.student DROP CONSTRAINT student_email_key;
       public            postgres    false    222            �           2606    25028    student student_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.student
    ADD CONSTRAINT student_pkey PRIMARY KEY (student_id);
 >   ALTER TABLE ONLY public.student DROP CONSTRAINT student_pkey;
       public            postgres    false    222            �           2606    25029 @   attendance attendance_student_id_course_name_session_number_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.attendance
    ADD CONSTRAINT attendance_student_id_course_name_session_number_fkey FOREIGN KEY (student_id, course_name, session_number) REFERENCES public.enrollment(student_id, course_name, session_number) ON DELETE CASCADE;
 j   ALTER TABLE ONLY public.attendance DROP CONSTRAINT attendance_student_id_course_name_session_number_fkey;
       public          postgres    false    216    216    216    219    219    219    3221            �           2606    25034 A   courseinstructor courseinstructor_course_name_session_number_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.courseinstructor
    ADD CONSTRAINT courseinstructor_course_name_session_number_fkey FOREIGN KEY (course_name, session_number) REFERENCES public.course(course_name, session_number) ON DELETE CASCADE;
 k   ALTER TABLE ONLY public.courseinstructor DROP CONSTRAINT courseinstructor_course_name_session_number_fkey;
       public          postgres    false    3217    217    218    217    218            �           2606    25039 4   courseinstructor courseinstructor_instructor_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.courseinstructor
    ADD CONSTRAINT courseinstructor_instructor_id_fkey FOREIGN KEY (instructor_id) REFERENCES public.instructor(instructor_id) ON DELETE CASCADE;
 ^   ALTER TABLE ONLY public.courseinstructor DROP CONSTRAINT courseinstructor_instructor_id_fkey;
       public          postgres    false    3225    220    218            �           2606    25044 5   enrollment enrollment_course_name_session_number_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_course_name_session_number_fkey FOREIGN KEY (course_name, session_number) REFERENCES public.course(course_name, session_number) ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.enrollment DROP CONSTRAINT enrollment_course_name_session_number_fkey;
       public          postgres    false    217    217    219    219    3217            �           2606    25049 %   enrollment enrollment_student_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.enrollment
    ADD CONSTRAINT enrollment_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.student(student_id) ON DELETE CASCADE;
 O   ALTER TABLE ONLY public.enrollment DROP CONSTRAINT enrollment_student_id_fkey;
       public          postgres    false    3229    219    222            1   3   x�322��/-NM�4��4�54�5��L�?NC#cS3sK�=... ��	�      3   6   x�34556��t644�4�4202�50�52�,(J-N�+�2�&�������� �{      4   U   x�s644�4�,.������44�����9�9����FyC]C#Nw�|Pob^%���1gF&X(�(dC�JLL���qqq *��      5      x�344�t6��\1z\\\ c�      6      x�34556��t644�4�2��b���� T�      7   6   x�344��/-NM����b2��4�54�5��4426153��������� ?H&      9   t   x�}�A�0����)zL���9 [O�f��DnƝ&���?�9��e�M/����p���?#���&0
S��{?u�:�:��K�Y���9��>��?8���c91��[�xpέ�(r     