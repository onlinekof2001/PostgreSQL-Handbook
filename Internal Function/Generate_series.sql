Generate_series
https://www.postgresql.org/docs/9.1/functions-srf.html

/* 升序步长, 步长默认1 */
SELECT * FROM generate_series(2,4);

/* 降序, 步长-2 */
SELECT * FROM generate_series(5,1,-2);

/* 时间间隔0,14天, 步长7天 */
SELECT current_date + s.a AS dates FROM generate_series(0,14,7) AS s(a);

SELECT * FROM generate_series('2008-03-01 00:00'::timestamp,
                              '2008-03-04 12:00', '10 hours');