-- select for task 10
select student_id from 
(select s.id as student_id, count(er.mark) as mark_count from students s
join exam_results er on er.student = s.id
where er.mark < 4
group by student_id
having count(er.mark) > 1);