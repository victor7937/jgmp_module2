--Create function that will return average mark for input user
create or replace function avarage_mark_by_student (id integer)
returns decimal(2,1) as $avg_mark$
declare
	avg_mark decimal(2,1);
begin
   select avg(er.mark) into avg_mark from students s
   join exam_results er on er.student = s.id
   where s.id = $1;
   return avg_mark;
end;
$avg_mark$ language plpgsql;

-- call
select avarage_mark_by_student(2)
