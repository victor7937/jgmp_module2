--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1
-- Dumped by pg_dump version 16.1

-- Started on 2023-12-02 23:07:20

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 4834 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 224 (class 1255 OID 16455)
-- Name: avarage_mark_by_student(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.avarage_mark_by_student(id integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$
declare
	avg_mark decimal(2,1);
begin
   select avg(er.mark) into avg_mark from students s
   join exam_results er on er.student = s.id
   where s.id = $1;
   return avg_mark;
end;
$_$;


ALTER FUNCTION public.avarage_mark_by_student(id integer) OWNER TO postgres;

--
-- TOC entry 225 (class 1255 OID 16454)
-- Name: avarage_mark_by_subject(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.avarage_mark_by_subject(subject_name text) RETURNS numeric
    LANGUAGE plpgsql
    AS $_$
declare
	avg_mark decimal(2,1);
begin
   select avg(er.mark) into avg_mark from subjects s
   join exam_results er on er.subject = s.id
   where s.name = $1;
   return avg_mark;
end;
$_$;


ALTER FUNCTION public.avarage_mark_by_subject(subject_name text) OWNER TO postgres;

--
-- TOC entry 227 (class 1255 OID 16460)
-- Name: get_red_zone(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_red_zone() RETURNS TABLE(student integer)
    LANGUAGE plpgsql
    AS $$
begin
  return query
  select student_id from 
  ( select s.id as student_id, count(er.mark) as mark_count from students s
	join exam_results er on er.student = s.id
	where er.mark < 4
	group by student_id
	having count(er.mark) > 1
  );
end
$$;


ALTER FUNCTION public.get_red_zone() OWNER TO postgres;

--
-- TOC entry 226 (class 1255 OID 16461)
-- Name: get_red_zone2(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_red_zone2() RETURNS integer[]
    LANGUAGE plpgsql
    AS $$
declare
	student_ids integer[];
begin
 student_ids := array(
  select student_id from 
  ( select s.id as student_id, count(er.mark) as mark_count from students s
	join exam_results er on er.student = s.id
	where er.mark < 4
	group by student_id
	having count(er.mark) > 1
  ));
  return student_ids;
end;
$$;


ALTER FUNCTION public.get_red_zone2() OWNER TO postgres;

--
-- TOC entry 223 (class 1255 OID 16431)
-- Name: updated_datetime_to_now(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updated_datetime_to_now() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_datetime = (now() at time zone 'utc'); 
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.updated_datetime_to_now() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16415)
-- Name: exam_results; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exam_results (
    id integer NOT NULL,
    student integer NOT NULL,
    subject integer NOT NULL,
    mark integer
);


ALTER TABLE public.exam_results OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16414)
-- Name: exam_results_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exam_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exam_results_id_seq OWNER TO postgres;

--
-- TOC entry 4835 (class 0 OID 0)
-- Dependencies: 219
-- Name: exam_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exam_results_id_seq OWNED BY public.exam_results.id;


--
-- TOC entry 222 (class 1259 OID 16445)
-- Name: marks_snapshot; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.marks_snapshot (
    student_name character varying(50),
    student_surname character varying(50),
    subject_name character varying(255),
    mark integer
);


ALTER TABLE public.marks_snapshot OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16400)
-- Name: students; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.students (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    surname character varying(50) NOT NULL,
    date_of_birth date,
    phone_number character varying(15),
    primary_skill character varying(100),
    created_datetime timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    updated_datetime timestamp without time zone DEFAULT (now() AT TIME ZONE 'utc'::text),
    CONSTRAINT students_name_check CHECK (((name)::text !~ '[@#$]+'::text))
);


ALTER TABLE public.students OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 16399)
-- Name: students_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.students_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.students_id_seq OWNER TO postgres;

--
-- TOC entry 4836 (class 0 OID 0)
-- Dependencies: 215
-- Name: students_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.students_id_seq OWNED BY public.students.id;


--
-- TOC entry 218 (class 1259 OID 16408)
-- Name: subjects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.subjects (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    tutor character varying(50) NOT NULL
);


ALTER TABLE public.subjects OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16441)
-- Name: students_view; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.students_view AS
 SELECT s.name AS student_name,
    s.surname AS student_surname,
    su.name AS subject_name,
    er.mark
   FROM ((public.students s
     JOIN public.exam_results er ON ((er.student = s.id)))
     JOIN public.subjects su ON ((su.id = er.subject)));


ALTER VIEW public.students_view OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16407)
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.subjects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.subjects_id_seq OWNER TO postgres;

--
-- TOC entry 4837 (class 0 OID 0)
-- Dependencies: 217
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.subjects_id_seq OWNED BY public.subjects.id;


--
-- TOC entry 4661 (class 2604 OID 16418)
-- Name: exam_results id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_results ALTER COLUMN id SET DEFAULT nextval('public.exam_results_id_seq'::regclass);


--
-- TOC entry 4657 (class 2604 OID 16403)
-- Name: students id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students ALTER COLUMN id SET DEFAULT nextval('public.students_id_seq'::regclass);


--
-- TOC entry 4660 (class 2604 OID 16411)
-- Name: subjects id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects ALTER COLUMN id SET DEFAULT nextval('public.subjects_id_seq'::regclass);


--
-- TOC entry 4827 (class 0 OID 16415)
-- Dependencies: 220
-- Data for Name: exam_results; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exam_results (id, student, subject, mark) FROM stdin;
1	2	1	9
2	3	1	9
3	2	2	8
4	2	3	7
5	5	2	10
10	4	2	5
11	4	1	10
12	6	4	6
13	1	1	2
14	1	2	3
16	5	3	1
15	5	1	4
17	1	3	2
18	5	5	2
\.


--
-- TOC entry 4828 (class 0 OID 16445)
-- Dependencies: 222
-- Data for Name: marks_snapshot; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.marks_snapshot (student_name, student_surname, subject_name, mark) FROM stdin;
Victor	Vyrostak	Probability Theory	7
Victor	Vyrostak	Math	8
Victor	Vyrostak	Java Programming	9
Bipin	Gosain	Java Programming	9
Adam	Buelding	Math	5
Adam	Buelding	Java Programming	10
Mihail	Karpov	Math	10
\.


--
-- TOC entry 4823 (class 0 OID 16400)
-- Dependencies: 216
-- Data for Name: students; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.students (id, name, surname, date_of_birth, phone_number, primary_skill, created_datetime, updated_datetime) FROM stdin;
2	Victor	Vyrostak	1998-10-05	+995551314589	Java	2023-11-30 22:42:24.103686	2023-12-01 14:59:11.442156
3	Bipin	Gosain	1991-11-07	+111111111111	JS	2023-11-30 22:43:53.203014	2023-12-01 14:59:30.464588
1	Andy	Smith	2003-10-03	+375291111112	Java	2023-11-30 22:41:56.809112	2023-12-01 15:00:23.365429
4	Adam	Buelding	1972-01-21	+995117771177	Python	2023-12-01 15:02:24.75389	2023-12-01 15:02:39.614703
5	Mihail	Karpov	2012-11-28	+375331151515	Math	2023-12-01 15:14:28.426926	2023-12-01 15:59:03.907292
6	Mahesh	Kumar	2001-01-01	+111111111111	DevOps	2023-12-01 16:30:27.597968	\N
\.


--
-- TOC entry 4825 (class 0 OID 16408)
-- Dependencies: 218
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.subjects (id, name, tutor) FROM stdin;
1	Java Programming	Sergey Foka
2	Math	Aleksey Peskun
3	Probability Theory	Maria Shelest 
4	Databases	Aleksey Skoptsov
5	English	Elena Prokopenko
\.


--
-- TOC entry 4838 (class 0 OID 0)
-- Dependencies: 219
-- Name: exam_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exam_results_id_seq', 18, true);


--
-- TOC entry 4839 (class 0 OID 0)
-- Dependencies: 215
-- Name: students_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.students_id_seq', 6, true);


--
-- TOC entry 4840 (class 0 OID 0)
-- Dependencies: 217
-- Name: subjects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.subjects_id_seq', 5, true);


--
-- TOC entry 4672 (class 2606 OID 16420)
-- Name: exam_results exam_results_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_results
    ADD CONSTRAINT exam_results_pkey PRIMARY KEY (id);


--
-- TOC entry 4674 (class 2606 OID 16439)
-- Name: exam_results only_one_mark_for_student_subject; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_results
    ADD CONSTRAINT only_one_mark_for_student_subject UNIQUE (student, subject);


--
-- TOC entry 4666 (class 2606 OID 16406)
-- Name: students students_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.students
    ADD CONSTRAINT students_pkey PRIMARY KEY (id);


--
-- TOC entry 4670 (class 2606 OID 16413)
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- TOC entry 4663 (class 1259 OID 16534)
-- Name: students_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX students_name_index ON public.students USING btree (name);


--
-- TOC entry 4664 (class 1259 OID 16532)
-- Name: students_phone_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX students_phone_index ON public.students USING btree (phone_number);


--
-- TOC entry 4667 (class 1259 OID 16533)
-- Name: students_surname_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX students_surname_index ON public.students USING btree (surname);


--
-- TOC entry 4668 (class 1259 OID 16535)
-- Name: subjects_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX subjects_name_index ON public.subjects USING btree (name);


--
-- TOC entry 4677 (class 2620 OID 16432)
-- Name: students trigger_students_datetime_update; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_students_datetime_update BEFORE UPDATE ON public.students FOR EACH ROW EXECUTE FUNCTION public.updated_datetime_to_now();


--
-- TOC entry 4675 (class 2606 OID 16421)
-- Name: exam_results exam_results_students_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_results
    ADD CONSTRAINT exam_results_students_fk FOREIGN KEY (student) REFERENCES public.students(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 4676 (class 2606 OID 16426)
-- Name: exam_results exam_results_subjects_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exam_results
    ADD CONSTRAINT exam_results_subjects_fk FOREIGN KEY (subject) REFERENCES public.subjects(id) MATCH FULL ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2023-12-02 23:07:20

--
-- PostgreSQL database dump complete
--

