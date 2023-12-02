--Add validation on DB level that will check username on special characters (reject student name with next characters '@', '#', '$')
alter table students add
check(name !~ '[@#$]+')