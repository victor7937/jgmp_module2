--Create function that will return avarage mark for input subject name
create or replace function avarage_mark_by_subject(subject_name text)
returns decimal(2,1) as $avg_mark$
declare
	avg_mark decimal(2,1);
begin
   select avg(er.mark) into avg_mark from subjects s
   join exam_results er on er.subject = s.id
   where s.name = $1;
   return avg_mark;
end;
$avg_mark$ language plpgsql;

-- call
select avarage_mark_by_subject('Java Programming')