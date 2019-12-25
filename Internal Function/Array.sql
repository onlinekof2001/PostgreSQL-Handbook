Array Function
https://www.postgresql.org/docs/9.1/functions-array.html

Arrays Operator 
https://www.postgresql.org/docs/9.1/arrays.html

/* string in array {} */
select array(select substring('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' FROM (ceil(random()*62))::int FOR 1) FROM generate_series(1,10));