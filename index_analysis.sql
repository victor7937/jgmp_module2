--------------------------- Query with join--------------------------------------
explain analyze
select 
s.id,
s.name as student_name, 
s.surname as student_surname, 
su.name as subject_name, 
er.mark as mark
from students s 
join exam_results er on er.student = s.id
join subjects su ON su.id = er.subject
where s.surname='Flita' and s.name='Judy';

--1. Query without index
-- Nested Loop  (cost=4.78..2747.36 rows=10 width=31) (actual time=0.154..5.715 rows=10 loops=1)
-- Execution Time: 5.764 ms
-- 2747 cost and executing 5.764 ms

--2. Create multi column btree index
create index students_name_surname_index on students(name, surname);
-- Execution Time: 0.106 ms
-- Nested Loop  (cost=5.20..54.80 rows=10 width=31) (actual time=0.065..0.083 rows=10 loops=1)
-- Cost reduces from 2747 to 54, time from 5.764 ms to 0.106 ms.  Performance improvement up to 50 times.
drop index students_name_surname_index;

--3. Create single column bree index
create index students_surname_index on students(surname);
create index students_name_index on students(name);
-- "Nested Loop  (cost=15.66..61.26 rows=10 width=31) (actual time=0.068..0.088 rows=10 loops=1)"
-- "Execution Time: 0.127 ms"
-- Results are pretty good, but multi column is better by cost and time.

--4. Adding id as included to multi column index 
create index students_name_surname_index on students(name, surname) include (id);
-- Nested Loop  (cost=5.20..50.80 rows=10 width=31) (actual time=0.091..0.120 rows=10 loops=1)
-- Execution Time: 0.161 ms
-- We can observe small cost reduction, but a bit longer execution time
-- So for this particular query included index is not neccessary
drop index students_name_surname_index;

--5. Hash index for name and surname
create index students_name_index on students using hash(name);
create index students_surname_index on students using hash(surname);
-- Nested Loop  (cost=15.08..60.68 rows=10 width=31) (actual time=0.075..0.099 rows=10 loops=1)
-- Execution Time: 0.134 ms
-- The result is pretty good, but btree implementation costs was lower and executed faster

-- Searching only by surname
-- Hash Join  (cost=38.97..5686.04 rows=1330 width=31) (actual time=0.211..5.463 rows=1100 loops=1)"
-- "Execution Time: 5.542 ms"
-- Lets compare with btree
drop index students_name_index;
drop index students_surname_index;
create index students_surname_index on students(surname);
create index students_name_index on students(name);
-- Hash Join  (cost=39.27..5686.33 rows=1330 width=31) (actual time=0.228..2.082 rows=1100 loops=1)
-- Execution Time: 2.184 ms
-- Cost the same, but time result is 2 times better, so here also btree wins. 
drop index students_name_index;
drop index students_surname_index;

--Conclusion
--Multi column btree index gives us the best result

--------------------------- Query without join--------------------------------------

explain analyze
select s.id, s.name as student_name, s.surname as student_surname
from students s 
where s.surname = 'Flita'

--1. No Index
-- Seq Scan on students s  (cost=0.00..2451.00 rows=133 width=18) (actual time=0.082..5.365 rows=110 loops=1)
-- Execution Time: 5.385 ms

--2. Btree index 
create index students_surname_index on students(surname);
-- "Bitmap Heap Scan on students s  (cost=5.32..391.09 rows=133 width=18) (actual time=0.036..0.124 rows=110 loops=1)"
-- "Execution Time: 0.147 ms"
drop index students_surname_index;

--3. Btree with include
create index students_surname_index on students(surname) include(id, name);
-- "Index Only Scan using students_surname_index on students s  (cost=0.42..6.75 rows=133 width=18) (actual time=0.076..0.090 rows=110 loops=1)"
-- "Execution Time: 0.108 ms"
drop index students_surname_index;

--4 Hash index
create index students_surname_index on students using hash(surname);
-- "Bitmap Heap Scan on students s  (cost=5.03..390.80 rows=133 width=18) (actual time=0.039..0.137 rows=110 loops=1)"
-- "Execution Time: 0.156 ms"
drop index students_surname_index;

-- Conclusion
-- For query without joins the best option will be Btree index with include statement


