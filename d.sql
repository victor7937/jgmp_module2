--Find user with marks by user surname (partial match)
select distinct s.* from students s 
join exam_results er on s.id = er.student
where s.surname like '%Vyr%'