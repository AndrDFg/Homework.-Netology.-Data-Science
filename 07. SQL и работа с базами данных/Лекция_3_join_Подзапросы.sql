============= теория =============

create table table_a (
	a_id serial,
	a_val varchar(50) not null);

create table table_b (
	b_id serial,
	b_val varchar(50) not null,
	a_id int);

insert into table_a (a_val)
values ('one'), ('two'), ('three'), ('four'), ('five');

insert into table_b (b_val, a_id)
values ('six', 1), ('seven', 2), ('eight', 3), ('nine', null), ('ten', null);

select * from table_a;

select * from table_b;

	table_a				table_b
a_id | a_val	b_id | b_val |a_id

									x
table_a.a_id | table_a.a_val | table_b.b_id | table_b.b_val | table_b.a_id

inner / left / right / full / cross

select * 
from table_a
inner join table_b on table_a.a_id = table_b.a_id

select * 
from table_a a
join table_b b on a.a_id = b.a_id

select * 
from table_a a 
left join table_b b on a.a_id = b.a_id
			
--нужно получить пользователей только с адресами 

select * --599 / 594
from customer c
join address a on c.address_id = a.address_id

--нужно получить всех пользователей и их адреса 

select * --599
from customer c
left join address a on c.address_id = a.address_id

--нужно найти пользователей без адресов

select * --599
from customer c
left join address a on c.address_id = a.address_id
where a.address_id is null

--нужно получить все адреса и добавить данные по пользователям 

select * --603
from address a
left join customer c on c.address_id = a.address_id

select * 
from table_a a 
right join table_b b on a.a_id = b.a_id

select * 
from table_a a 
full join table_b b on a.a_id = b.a_id

select * 
from table_a a 
full join table_b b on a.a_id = b.a_id
where a.a_id is null or b.a_id is null

select *  --25
from table_a a 
cross join table_b b 

select c1.first_name, c2.first_name --358 801
from customer c1, customer c2

SQL Error [42712]: ОШИБКА: имя таблицы "customer" указано больше одного раза

SQL Error [42702]: ОШИБКА: неоднозначная ссылка на столбец "first_name"

select c1.first_name, c2.first_name --358 186
from customer c1, customer c2
where c1.first_name != c2.first_name

--AARON	ADAM
ADAM	AARON

a - 1
я - 33
А - 34
Я - 66

select c1.first_name, c2.first_name --179 093
from customer c1, customer c2
where c1.first_name > c2.first_name

select es.emp_id, es.salary, gs.grade
from employee_salary es
join grade_salary gs on es.salary between gs.min_salary and gs.max_salary

select *
from grade_salary 

delete from table_a;
delete from table_b;

insert into table_a (a_id, a_val)
select *
from unnest (array[1, 1, 2], array['a', 'a', 'c'])

insert into table_b (a_id, b_val)
select *
from unnest (array[1, 1, 3], array['b', 'b', 'd'])

select * from table_a;
select * from table_b;

1	1
1	1
2	3

1	1
1	1
1	1
1	1

select * 
from table_a a
join table_b b on a.a_id = b.a_id

select * 
from table_a a 
left join table_b b on a.a_id = b.a_id

select * 
from table_a a 
right join table_b b on a.a_id = b.a_id

select * 
from table_a a 
full join table_b b on a.a_id = b.a_id

select * 
from table_a a 
full join table_b b on a.a_id = b.a_id
where a.a_id is null or b.a_id is null

select *  
from table_a a, table_b b 

select count(*) --599
from customer c

select count(*) --16049
from payment p

select count(*) --16044
from rental r

--ЛОЖНЫЙ ЗАПРОС
select count(*) --445483
from customer c
join payment p on c.customer_id = p.customer_id
join rental r on c.customer_id = r.customer_id

--ВЕРНЫЙ ЗАПРОС
select count(*) --16049
from customer c
join payment p on c.customer_id = p.customer_id
join rental r on r.rental_id = p.rental_id

--ЛОЖНЫЙ ЗАПРОС
select tc.table_schema, tc.table_name, tc.constraint_name, kcu.column_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
where tc.table_schema = 'public' and tc.constraint_type = 'PRIMARY KEY'
				
table_constraints			key_column_usage
hr.city.city_pkey			hr.city.city_pkey
public.city.city_pkey		public.city.city_pkey

--ВЕРНЫЙ ЗАПРОС
select tc.table_schema, tc.table_name, tc.constraint_name, kcu.column_name
from information_schema.table_constraints tc
join information_schema.key_column_usage kcu on tc.constraint_name = kcu.constraint_name
	and tc.table_name = kcu.table_name
	and tc.table_schema = kcu.table_schema
where tc.table_schema = 'public' and tc.constraint_type = 'PRIMARY KEY'

--union / except / intersect

select lower(first_name) --599
from customer 
union --distinct
select lower(first_name) --2
from staff 
--591

select lower(first_name) --599
from customer 
union all
select lower(first_name) --2
from staff 
--601

select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as a, 1 as b
	union all
	select 1 as c, 1 as d
	union all
	select 1 as r, 2 as t)
except --distinct
select 1 as x, 1 as y
		
SQL Error [42601]: ОШИБКА: подзапрос во FROM должен иметь псевдоним
  Подсказка: Например, FROM (SELECT ...) [AS] foo.

select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as a, 1 as b
	union all
	select 1 as c, 1 as d
	union all
	select 1 as r, 2 as t)
except all
select 1 as x, 1 as y

select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as a, 1 as b
	union all
	select 1 as c, 1 as d
	union all
	select 1 as r, 2 as t)
intersect --distinct
select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as a, 1 as b)
	
select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as a, 1 as b
	union all
	select 1 as c, 1 as d
	union all
	select 1 as r, 2 as t)
intersect all
select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as a, 1 as b)
	
select address_id
from address 
except
select address_id
from customer 
	
============= соединения =============

1. Выведите список названий всех фильмов и их языков
* Используйте таблицу film
* Соедините с language
* Выведите информацию о фильмах:
title, language."name"

select f.title, l."name"
from film f
join "language" l on f.language_id = l.language_id

1. Выведите все фильмы и их категории:
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Соедините используя оператор using

select f.title, c."name"
from film f
left join film_category fc on fc.film_id = f.film_id
left join category c on c.category_id = fc.category_id

select f.title, c."name"
from film f
left join film_category fc using (film_id) 
left join category c using (category_id)

select *
from store s
join staff s2 using (store_id)
join customer c using (store_id)
join address a on a.address_id = c.address_id

select *
from film_category fc
natural join category c

select *
from film_category fc
join category c using (category_id, last_update)

select *
from category

2. Выведите уникальный список фильмов, которые брали в аренду '24-05-2005'. 
* Используйте таблицу film
* Соедините с inventory
* Соедините с rental
* Отфильтруйте, используя where 

select *
from film f
join inventory i on f.film_id = i.film_id
join rental r on r.inventory_id = i.inventory_id and r.rental_date::date = '24-05-2005'

select *
from film f
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id 
where r.rental_date::date = '24-05-2005'

2.1 Выведите все магазины из города Woodridge (city_id = 576)
* Используйте таблицу store
* Соедините таблицу с address 
* Соедините таблицу с city 
* Соедините таблицу с country 
* отфильтруйте по "city_id"
* Выведите полный адрес искомых магазинов и их id:
store_id, postal_code, country, city, district, address, address2, phone

--ЛОЖНЫЙ ЗАПРОС
select store_id, postal_code, country, city, district, address, address2, phone
from store s
join address a on a.address_id = s.address_id
join city c on c.city_id = a.address_id
join country c2 on c2.country_id = c2.country_id

--ЛОЖНЫЙ ЗАПРОС
select store_id, postal_code, country, city, district, address, address2, phone
from store s
join address a on a.address_id = s.address_id
join city c on c.city_id = a.city_id
join country c2 on c2.country_id = c2.country_id

--ВЕРНЫЙ ЗАПРОС
select store_id, postal_code, country, city, district, address, address2, phone
from store s
join address a on a.address_id = s.address_id
join city c on c.city_id = a.city_id
join country c2 on c2.country_id = c.country_id

============= агрегатные функции =============

count
sum
avg 
min 
max 
string_agg
array_agg

3. Подсчитайте количество актеров в фильме Grosse Wonderful (id - 384)
* Используйте таблицу film
* Соедините с film_actor
* Отфильтруйте, используя where и "film_id" 
* Для подсчета используйте функцию count, используйте actor_id в качестве выражения внутри функции
* Примените функцильные зависимости

select *
from film_actor fa
where fa.film_id = 384

select count(*), count(1)
from film_actor fa
where fa.film_id = 384

select count(*), count(address_id)
from customer c 

select count(*), count(customer_id), count(distinct customer_id)
from payment p

titanik - 40 raz

--ЛОЖНЫЙ ЗАПРОС
select f.title, count(*)
from film_actor fa
join film f on fa.film_id = f.film_id
group by f.title

SQL Error [42803]: ОШИБКА: столбец "f.title" должен фигурировать в предложении GROUP BY или использоваться в агрегатной функции

cust_id	amount
1		5
1		7
1		8
2		2
2		6
2		10

cust_id		sum(amount)
1			20
2			18
group by cust_id

--ВЕРНЫЙ ЗАПРОС
select f.title, count(*), f.release_year, f.rental_duration, f.rental_rate
from film_actor fa
join film f on fa.film_id = f.film_id
group by f.film_id

select f.title, count(*), f.release_year, f.rental_duration, f.rental_rate
from film_actor fa
join film f on fa.film_id = f.film_id
group by f.film_id

select f.rental_duration, f.rental_rate, count(*)
from film_actor fa
join film f on fa.film_id = f.film_id
group by f.rental_duration, f.rental_rate

3.1 Посчитайте среднюю стоимость аренды за день по всем фильмам
* Используйте таблицу film
* Стоимость аренды за день rental_rate/rental_duration
* avg - функция, вычисляющая среднее значение
--4 агрегации

select avg(rental_rate / rental_duration), 
	sum(rental_rate / rental_duration), 
	count(rental_rate / rental_duration), 
	min(rental_rate / rental_duration), 
	max(rental_rate / rental_duration) 
from film 

select r.customer_id, string_agg(distinct f.title, ', ')
from rental r
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
group by r.customer_id

3.2 нужно получить данные по 5 платежу каждому пользователя.

select p.*
from (
	select customer_id, array_agg(payment_id order by payment_date)
	from payment
	group by customer_id) t 
join payment p on p.payment_id = t.array_agg[5]

============= группировки =============

4. Выведите месяцы, в которые было сдано в аренду более чем на 10 000 у.е.
* Используйте таблицу payment
* Сгруппируйте данные по месяцу используя date_trunc
* Для каждой группы посчитайте сумму платежей
* Воспользуйтесь фильтрацией групп, для выбора месяцев с суммой продаж более чем на 10 000 у.е.

select date_trunc('month', payment_date), sum(amount)
from payment p
group by date_trunc('month', payment_date)
having sum(amount) > 10000

explain
select date_trunc('month', payment_date), sum(amount)
from payment p
group by date_trunc('month', payment_date)
having sum(amount) > 10000 and 

select date_trunc('month', payment_date), sum(amount)
from payment p
where date_trunc('month', payment_date) < '01.08.2005'
group by date_trunc('month', payment_date)
having sum(amount) > 10000 

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment p
where customer_id < 3
group by customer_id, staff_id, date_trunc('month', payment_date)

select customer_id a, staff_id b, date_trunc('month', payment_date) c, sum(amount)
from payment p
where customer_id < 3
group by a, b, c

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment p
where customer_id < 3
group by 1, 2, 3
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment p
where customer_id < 3
group by grouping sets (1, 2, 3)
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment p
where customer_id < 3
group by grouping sets (1, 2, 3), grouping sets (3)
order by 1, 2, 3

1+3
2+3
3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment p
where customer_id < 3
group by cube (1, 2, 3)
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment p
group by cube (1, 2, 3)
order by 1, 2, 3

~5 минут

create temporary table some_pay as (
	select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
	from payment p
	group by cube (1, 2, 3)
	order by 1, 2, 3)
	
select *
from some_pay
where customer_id is null and staff_id is not null and date_trunc is not null

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment p
group by rollup (1, 2, 3)
order by 1, 2, 3

1
1+2
1+2+3
1+2+3+4

страны
фо
областей
городов
улиц
	
4.0.1 найти сумму платежей пользователей, где размер платежа меньше 5 у.е и сумму платежей пользователей, 
	где размер платежа больше или равен 5 у.е

select customer_id, 
	sum(amount) filter (where amount < 5),
	sum(amount) filter (where amount >= 5)
from payment 
group by customer_id

4.1 Выведите список категорий фильмов, средняя продолжительность аренды которых более 5 дней
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней

select c."name"
from category c
join film_category fc on c.category_id = fc.category_id
join film f on f.film_id = fc.film_id
group by c.category_id
having avg(f.rental_duration) > 5

============= подзапросы =============

select (select )

--плохо
select 
from (select col from tab)
join (select col from tab)
join (select col from tab)
join (select col from tab)

--хорошо
select 
from (select aggregate from tab)
join (select aggregate from tab)
join (select over from tab)
join (select over from tab)

5. Выведите количество фильмов, со стоимостью аренды за день больше, 
чем среднее значение по всем фильмам
* Напишите подзапрос, который будет вычислять среднее значение стоимости 
аренды за день (задание 3.1)
* Используйте таблицу film
* Отфильтруйте строки в результирующей таблице, используя опретаор > (подзапрос)
* count - агрегатная функция подсчета значений

скаляр - не имеет алиаса и используется в select, условии и в cross join
одномерный массив - не имеет алиаса используется в условиях
таблицу - обязательно алиас используется во from и join 

select count(*), avg(rental_duration)
from film 
where rental_duration > (select avg(rental_duration) from film)

explain --689.84
select customer_id, sum(amount) * 100. / (select sum(amount) from payment)
from payment 
group by 1

explain --890.45
select customer_id, sum(amount) * 100. / t.sum
from payment, (select sum(amount) from payment) t 
group by 1, t.sum

select *
from payment 
where (customer_id, payment_date) in (
	select customer_id, max(payment_date)
	from payment 
	group by customer_id)

6. Выведите фильмы, с категорией начинающейся с буквы "C"
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"
* Используйте подзапрос во from, join, where

select category_id, "name"
from category 
where "name" like 'C%'

explain analyse --53.54
select f.title, c.some_alies
from (
	select category_id, name some_alies
	from category c
	where "name" like 'C%') c
join film_category fc on fc.category_id = c.category_id
join film f on f.film_id = fc.film_id   

explain analyse --53.54
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
left join film_category fc on fc.category_id = t.category_id
left join film f on f.film_id = fc.film_id   

explain analyse --53.54
select f.title, t.name
from film f
join film_category fc on fc.film_id = f.film_id
join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id 
	
explain analyze --53.54
select f.title, t.name
from film f
right join film_category fc on fc.film_id = f.film_id
right join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id 
	
explain analyse --47.36
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id and  
	fc.category_id in 
		(select category_id
		from category 
		where "name" like 'C%')
join category c on c.category_id = fc.category_id 

explain analyse --47.21
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in
	(select category_id
	from category 
	where "name" like 'C%')
	
	
explain analyze --53.54
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c."name" like 'C%'  

Медленно 16 + 1000
Быстро 1000

Медленно 16 + 16
Быстро 1000 + 1000

--ТАК НЕ НАДО
explain analyze --47.21
select f.title, c.name
from (
	select *
	from film) f
join (
	select film_id, category_id 
	from film_category) fc on fc.film_id = f.film_id 
join (
	select category_id, name
	from category) c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%')



-- ГРУБАЯ ОШИБКА, СОЗДАЕТ ИЗБЫТОЧНОСТЬ И ВЕШАЕТ БАЗУ
explain analyze --710187.83
select distinct customer_id, 
	(select sum(amount) 
	from payment p1
	where p1.customer_id = p.customer_id),
	(select count(amount) 
	from payment p1
	where p1.customer_id = p.customer_id),
	(select min(amount) 
	from payment p1
	where p1.customer_id = p.customer_id),
	(select max(amount) 
	from payment p1
	where p1.customer_id = p.customer_id),
	(select avg(amount) 
	from payment p1
	where p1.customer_id = p.customer_id)
from payment p
order by 1

explain analyze  --518.22
select customer_id, sum(amount), count(amount), min(amount), max(amount), avg(amount)
from payment p
group by customer_id
order by 1

select 710187.83 / 518.22 --1370.4369379800084906

select *
from rental r
where exists (select 1 from payment p where r.rental_date = p.payment_date)

select r.*
from rental r
join payment p on r.rental_date = p.payment_date

select *
from (
	select *
	from rental r
	where r.customer_id < 5) r
join lateral (
	select p.customer_id, sum(amount)
	from payment p
	where r.rental_date::date = p.payment_date::date
	group by 1) p on true
	
-- case
< 5 - малый платеж
5 - 10 средний платеж
> 10 большой платеж

select amount,
	case
		when amount < 5 then 'малый платеж'
		when amount between 5 and 10 then 'средний платеж'
		else 'большой платеж'
	end
from payment 

select alias_for_case, count(*)
from (
	select amount,
		case
			when amount < 5 then 'малый платеж'
			when amount between 5 and 10 then 'средний платеж'
			else 'большой платеж'
		end alias_for_case
	from payment) 
group by alias_for_case