-- Create function that will return student at "red zone" (red zone means at least 2 marks <=3). 
-- Query like fuction. Just returns result of a query.
-- function declare
create or replace function get_red_zone()
returns table (student int) as $student_ids$
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
$student_ids$ language plpgsql;

-- call
select get_red_zone();