-- Create function that will return student at "red zone" (red zone means at least 2 marks <=3). 
-- Array returning function.
-- function declare
create or replace function get_red_zone2()
returns integer[] as $student_ids$
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
$student_ids$ language plpgsql;

select get_red_zone2()