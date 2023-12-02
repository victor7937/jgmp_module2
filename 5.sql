--Add trigger that will update column updated_datetime to current date in case of updating any of student.
CREATE OR REPLACE FUNCTION updated_datetime_to_now()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_datetime = (now() at time zone 'utc'); 
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER trigger_students_datetime_update BEFORE UPDATE
ON students FOR EACH ROW EXECUTE PROCEDURE 
updated_datetime_to_now();