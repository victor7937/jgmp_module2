--Create snapshot that will contain next data: student name, student surname, subject name, mark 
--(snapshot means that in case of changing some data in source table – your snapshot should not change)

-- create view students_view as - referencing snapshot
create table marks_snapshot as -- not referencing snapshot
select 
s.name as student_name, 
s.surname as student_surname, 
su.name as subject_name, 
er.mark as mark
from students s 
join exam_results er on er.student = s.id
join subjects su ON su.id = er.subject;