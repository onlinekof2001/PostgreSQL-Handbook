Substring
https://www.postgresql.org/docs/9.1/functions-string.html

select substring('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' FROM (ceil(random()*62))::int FOR 2);