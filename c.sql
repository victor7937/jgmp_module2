--Find user by phone number (partial match)
select * from students s where s.phone_number like '%1314589%'