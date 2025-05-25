https://www.sqlstyle.guide/ru/

Комментарии

--волиаптфшваипжлофваипж
/*
 * ыапрыапраыпр
 * ывапрыапрапр
 */

select 2 + /* sdfgadfgdfgd */ 2

Отличие ' ' от " "  --` `

' ' - значения

where first_name = 'Николай'

where date = '01/01/2024'

" " - названия сущностей

some_new_table

"dvd-rental"

Зарезервированные слова
https://postgrespro.ru/docs/postgresql/16/sql-keywords-appendix#KEYWORDS-table

select "select"
from "from"

select name
from language

dml 
select 
insert 
update
delete 

ddl
create 
alter 
drop 

dcl / tcl

синтаксический порядок инструкции select;

select - столбцы, вычисления, функции
from - основную таблицу
join - остальные таблицы
on - условие по которому присоединятся
where - фильтрация результата
group by - группировка данных
having - фильтрация агрегации
order by - сортировка результата
offset / limit

логический порядок инструкции select;

from
on
join
where
group by
having
select --алиасы
order by
offset / limit

pg_typeof(), приведение типов

01.2024

select pg_typeof(100) --integer

select pg_typeof(100.) --numeric

select pg_typeof('100.') --unknown

numeric | text
100.	 '100.'

select '100' + 100

select ~ '100'

SQL Error [42725]: ОШИБКА: оператор не уникален: ~ unknown
  Подсказка: Не удалось выбрать лучшую кандидатуру оператора. Возможно, вам следует добавить явные приведения типов.
  
select ~ '100'::int

select 'a' ~ '[a-z]'::text

select ~ B'1001'

select pg_typeof(cast('100.' as text))

select pg_typeof('100.'::text)

cast(значени as тип_данных)

1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select *
from film 

select film_id as "FilmFilm_id", title as "FilmTitle", description as "FilmDescription", release_year as Год_выпуска_фильма, power(2, 3) as X, 2 + 2 as Y
from film 

select film_id "FilmFilm_id" 
	--,title "FilmTitle" 
	--,description "FilmDescription" 
	,release_year "Год выпуска фильма" 
	,power(2, 3) x
	,2 + 2 y
from film 

select 1 as "ну очень длинное название для псведонима просто так от нечего делать"

"ну очень длинное название для псве"

< 64 байт

select *
from (
	select c.first_name c_name, s.first_name s_name, 2 + 2 x, 2 * 2 y
	from customer c, staff s)
where s_name = 'Mike'

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

integer 
numeric numeric(6, 2) 9999.99			--decimal

select 9999.99::numeric(6, 2)

select 99999000::numeric(6, -2)

float 2.5 + 2.5 = 2.4999999999999999999 + 2.5000000000000001 real / double precision 

select title, rental_rate / rental_duration as cost_per_day,
	rental_rate * rental_duration,
	rental_rate - rental_duration,
	rental_rate + rental_duration,
	power(rental_rate, rental_duration),
	rental_rate ^ rental_duration,
	mod(rental_rate, rental_duration),
	rental_rate % rental_duration,
	sin(rental_rate),
	sind(rental_duration),
	sqrt(rental_rate),
	abs(rental_duration)
from film 

select pg_typeof(100::int / 33::int)

--округление

select title, rental_rate / rental_duration as cost_per_day
from film 

round(numeric, int)
round(float)

select round(100.345::numeric, 2)

select x,
	round(x::numeric) x_num,
	round(x::float) x_fl
from generate_series(0.5, 5.5, 1) x

select ceil(0.1)

select floor(0.9)

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by round(rental_rate / rental_duration, 2) --asc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day --asc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 --asc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc, 2 

3.1* Отсортируйте таблицу платежей по возрастанию размера платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select *
from payment 
order by amount

select * 
from payment p
order by payment_date desc
nulls last

select * 
from payment p
order by payment_date
nulls first

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
-- используйте limit

1 - 1000
2,3,4 - 990
5-20 - 980

топ-3? Условие задачи не корректно, ответа нет.

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
limit 10

501	KISSING DOLLS	1.66
908	TRAP GUYS	1.66
904	TRAIN BUNCH	1.66
350	GARDEN ISLAND	1.66
444	HUSTLER PARTY	1.66
260	DUDE BLINDNESS	1.66
771	SCORPION APOLLO	1.66
768	SCARFACE BANG	1.66
21	AMERICAN CIRCUS	1.66
764	SATURDAY LAMBS	1.66

124	CASPER DRAGONFLY	1.66
71	BILKO ANONYMOUS	1.66
48	BACKLASH UNDEFEATED	1.66
120	CARIBBEAN LIBERTY	1.66
60	BEAST HUNCHBACK	1.66
65	BEHAVIOR RUNAWAY	1.66
2	ACE GOLDFINGER	1.66
21	AMERICAN CIRCUS	1.66
46	AUTUMN CROW	1.66
126	CASUALTIES ENCINO	1.66

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 10 rows only

3.2.1 Вывести топ-1 самых дорогих фильмов по стоимости за день аренды, то есть вывести все 62 фильма
--начиная с 13 версии

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 1 rows with ties

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
offset 57
limit 10

t1 - 100млн
t2 - 50млн

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и offset

select *
from payment 
order by amount
offset 13999
limit 15

4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

explain 
select distinct release_year
from film 

explain
select release_year
from film 
group by release_year

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select distinct first_name --591
from customer 

explain --25.47
select distinct first_name, last_name, customer_id --599
from customer 

explain --14.99
select first_name, last_name, customer_id --599
from customer 

4.1 нужно получить последний платеж каждого пользователя

select distinct on (customer_id) *
from payment 
order by customer_id, payment_date desc

5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

text до 1gb
varchar(N) varchar(50)
char(N) char(10) 'xxxxx' -> 'xxxxx     '

select title || ' - ' || release_year, rating
from film 
where rating = 'PG-13'

select concat(title, ' - ', release_year), rating
from film 
where rating = 'PG-13'

select concat_ws(' ', last_name, first_name, middle_name)
from person 

серия | номер
1234	null

select '1234' || null 

имя 	| отчество
Николай	 null

select concat('Николай', null)

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
- lower
- upper
- length


LENGTH() возвращает длину строки, измеряемую в байтах.
CHAR_LENGTH() возвращает длину строки, измеряемую в символах.

like 
ilike
%
_

select title, pg_typeof(rating)
from film 
where rating like 'PG%'

SQL Error [42883]: ОШИБКА: оператор не существует: mpaa_rating ~~ unknown

select title, rating
from film 
where rating::text like 'PG%'

select title, rating
from film 
where rating::text like 'PG%3'

select title, rating
from film 
where rating::text like '%-%'

select title, rating
from film 
where not rating::text like '%-%'

select title, rating
from film 
where rating::text not like '%-%'

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where last_name ilike 'к_з%в'

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where last_name ilike 'а__к______в'

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where last_name ilike 'а__к%в' and char_length(last_name) = 11

select concat_ws(' ', last_name, first_name, middle_name)
from person 
where lower(last_name) like 'а__к%в' and char_length(last_name) = 11

select *
from film
where title like '%\%%'
order by 1

select *
from film
where title like '%=%%' escape '='
order by 1

select ''''
 
5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания),
в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
- strpos
- character_length
- overlay
- substring
- split_part



select *
from customer 
where first_name ilike '%jam%'

select substring('привет мир', 3, 6)

select substring('привет мир', 3)

select strpos('привет мир', 'мир')

select title, rating
from film 
where strpos(rating::text, '-') = 0

select left('привет мир', 3)

select left('привет мир', -2)

select right('привет мир', 3)

select right('привет мир', -2)

select initcap(lower(upper('привет мир')))

select character_length('привет мир'), char_length('привет мир'), length('привет мир'), octet_length('привет мир')

select split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 1),
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 2),
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 3)
from person 

Литвинова	1
Амелия		2
Егоровна	3

select concat_ws(' ', last_name, first_name, middle_name), replace(concat_ws(' ', last_name, first_name, middle_name), 'Николай', 'Nikolay')
from person 
where first_name = 'Николай'

select concat_ws(' ', last_name, first_name, middle_name), 
	overlay(
		concat_ws(' ', last_name, first_name, middle_name)
		placing 'Nikolay'
		from strpos(concat_ws(' ', last_name, first_name, middle_name), 'Николай')
		for char_length('Николай'))
from person 
where first_name = 'Николай'

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 включительно по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval

timestamptz
timetz
timestamp
time
date
interval

select '13.01.2024'::date

show lc_time --Russian_Russia.1251

yyyy.mm.dd
dd.mm.yyyy

yyyy-mm-dd hh:mm:ss.ms+tz

select '2024-08-01 21:19:47.8442-10'::timestamptz
		2024-08-02 10:19:47.8442+03

set time zone 'utc-10'

select '2024-08-01 21:19:47.8442+10'::timestamptz
		2024-08-01 21:19:47.8442+10
		
set time zone 'utc-3'

--ложный запрос
select customer_id, payment_date
from payment 
where payment_date >= '27-05-2005' and payment_date <= '28-05-2005'
order by payment_date desc 
nulls last

--ложный запрос 
select customer_id, payment_date
from payment 
where payment_date between '27-05-2005' and '28-05-2005 00:00:00'
order by payment_date desc 
nulls last

--как вариант
select customer_id, payment_date
from payment 
where payment_date between '27-05-2005' and '28-05-2005 24:00:00'
order by payment_date desc 

select customer_id, payment_date
from payment 
where payment_date between '27-05-2005' and '29-05-2005'
order by payment_date desc 

select customer_id, payment_date
from payment 
where payment_date between '27-05-2005' and '28-05-2005'::date + interval '1 day' -- '24 hours'
order by payment_date desc 

--КАК НУЖНО!!!!
select customer_id, payment_date
from payment 
where payment_date::date between '27-05-2005' and '28-05-2005'
order by payment_date desc

6* Вывести платежи поступившие после 2005-07-08
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select customer_id, payment_date
from payment 
where payment_date::date > '08-07-2005'

select version() --PostgreSQL 12.12, compiled by Visual C++ build 1914, 64-bit

--Получение из даты отдельно год, месяц или день. Извлечение отдельно год, месяц или день

--До 14 версии
date_part --double precision / float
extract --double precision / float

select pg_typeof(date_part('year', now()))

select date_part('year', now())

select pg_typeof(extract(year from now()))

select extract(year from now())

select version() --PostgreSQL 16.0, compiled by Visual C++ build 1935, 64-bit

--После 14 версии
date_part --double precision / float
extract --numeric

select pg_typeof(date_part('year', now()))

select date_part('year', now())

select pg_typeof(extract(year from now()))

select extract(year from now())

select date_part('year', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('month', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('day', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('hours', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('minutes', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('seconds', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('week', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('quarter', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('isodow', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('millennium', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_part('epoch', '2024-08-01 21:19:47.8442+10'::timestamptz)
	
select extract(year from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(month from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(day from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(hours from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(minutes from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(seconds from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(week from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(quarter from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(isodow from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(millennium from '2024-08-01 21:19:47.8442+10'::timestamptz),
	extract(epoch from '2024-08-01 21:19:47.8442+10'::timestamptz)
	
date_part('year', ..), date_part('month', ..)

--усечение!
select date_trunc('year', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_trunc('month', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_trunc('day', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_trunc('hours', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_trunc('minutes', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_trunc('seconds', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_trunc('week', '2024-08-01 21:19:47.8442+10'::timestamptz),
	date_trunc('millennium', '2024-08-01 21:19:47.8442+10'::timestamptz)
	
age(дата1, дата2)
age(дата)

timestamp - timestamp = interval
date - date = integer

select current_timestamp

select current_time 

select current_date 

select current_user 

select current_schema

7. Получить количество дней с '17-04-2007' по сегодняшний день.
Получить количество месяцев с '17-04-2007' по сегодняшний день.
Получить количество лет с '17-04-2007' по сегодняшний день.

--дни:
select current_date - '17-04-2007'::date --6316

--Месяцы:
select date_part('year', age('17-04-2007'::date)) * 12 + date_part('month', age('17-04-2007'::date)) --207

--Года:
select date_part('year', age('17-04-2007'::date)) --17 years 3 mons 14 days

select (date_trunc('month', '2024-08-15'::date) + interval '+1 month -1 day')::date

8. Булев тип

true 1 'yes' 'on' 't'
false 0 'no' 'off' 'f'

select *
from customer 

update customer 
set activebool = null 
where customer_id < 10

select * --582
from customer 
where activebool is true

select * --8
from customer 
where activebool is false

null

select * --8
from customer 
where activebool is null

select * --582
from customer 
where activebool

select * --8
from customer 
where not activebool

9 Логические операторы and и or
оператор and имеет приоритет работы перерд оператором or

нужно вывести платежи по пользователям с id 1 и 2 и их платежами размерами 0.99 и 2.99

select customer_id, amount
from payment 
where customer_id = 1 or customer_id = 2 and amount = 0.99 or amount = 2.99

			a + b * c + d

and = *
or = +

select customer_id, amount
from payment 
where (customer_id = 1 or customer_id = 2) and (amount = 0.99 or amount = 2.99)

			(a + b) * (c + d)
			
select customer_id, amount
from payment 
where customer_id in (1, 2) and amount in (0.99, 2.99)

select *
from customer c
where left(last_name, 1) = 'A' and left(first_name, 1) = 'A' or left(last_name, 1) = 'B' and left(first_name, 1) = 'B'

SET search_path TO public;

SELECT *
FROM country
