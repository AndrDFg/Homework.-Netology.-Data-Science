from 
on 
join 
where 
group by 
having 
over --оконная функция
select 

функция(аргументы) over (partition by аргументы order by аргументы)

(partition by аргументы order by аргументы)
(partition by аргументы )
(order by аргументы)
()

агрегатные оконные функции
специализированные оконные функции оператор order by обязателен к исользованию
order by random()

cust_id	| amount
1			5
1			5
1			7
2			8
2			10
2			2

cust_id | sum(amount)
1			17
2			20
group by 1

cust_id	| amount | sum(amount) (partition by cust_id)
1			5		17
1			5		17
1			7		17
2			8		20
2			10		20
2			2		20


============= оконные функции =============

1. Вывести ФИО пользователя и название пятого фильма, который он брал в аренду.
* В подзапросе получите порядковые номера для каждого пользователя по дате аренды
* Задайте окно с использованием предложений over, partition by и order by
* Соедините с customer
* Соедините с inventory
* Соедините с film
* В условии укажите 3 фильм по порядку

explain analyze --1797.69 / 10
select c.last_name, c.first_name, f.title
from (
	select customer_id, array_agg(inventory_id order by rental_date)
	from rental
	group by 1) r 
join inventory i on i.inventory_id = r.array_agg[5]
join film f on f.film_id = i.film_id
join customer c on c.customer_id = r.customer_id

explain analyze --2148.15 / 11
select c.last_name, c.first_name, f.title
from (
	select *, row_number() over (partition by customer_id order by rental_date)
	from rental) r 
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join customer c on c.customer_id = r.customer_id
where row_number = 5

1.1. Выведите таблицу, содержащую имена покупателей, арендованные ими фильмы и средний платеж 
каждого покупателя
* используйте таблицу customer
* соедините с paymen
* соедините с rental
* соедините с inventory
* соедините с film
* avg - функция, вычисляющая среднее значение
* Задайте окно с использованием предложений over и partition by

explain analyze --2589.47 / 28
select c.last_name, c.first_name, f.title,
	avg(p.amount) over (partition by c.customer_id)
from customer c 
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on r.rental_id = p.rental_id

explain analyze --1088.48 / 18
select c.last_name, c.first_name, f.title,	p.avg
from customer c 
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join (
	select customer_id, avg(amount) 
	from payment
	group by 1) p on r.customer_id = p.customer_id

explain analyze --.689.8 / 7
select customer_id, sum(amount) * 100. / (select sum(amount) from payment) 
from payment 
group by 1

explain analyze --377.71 / 4.5
select customer_id, sum(amount) * 100. / sum(sum(amount)) over ()
from payment 
group by 1

-- формирование накопительного итога
НАКОПИТЕЛЬНЫЙ ИТОГ ФОРМИРУЕТСЯ ТОЛЬКО ЧЕРЕЗ ORDER by

select customer_id, payment_date, amount
from payment 
where customer_id < 4 and date_trunc('month', payment_date) < '01.08.2005'
order by random()

select customer_id, payment_date, amount,
	sum(amount) over (partition by customer_id order by payment_date)
from payment 

1	2005-05-28 10:35:23	0.99 	sum(0.99)
1	2005-06-18 13:33:59	0.99	sum(0.99+0.99)
1	2005-06-16 15:18:57	4.99	sum(0.99+0.99+4.99)
1	2005-07-09 13:24:07	4.99	sum(0.99+0.99+4.99+4.99)
1	2005-07-28 16:18:23	4.99	sum(0.99+0.99+4.99+4.99+4.99)

2	2005-07-30 13:47:43	10.99
2	2005-07-30 22:39:53	6.99
2	2005-07-29 12:56:59	2.99
2	2005-07-27 18:40:20	5.99
2	2005-07-30 16:21:13	6.99
2	2005-07-29 17:14:29	5.99

3	2005-07-07 10:23:25	4.99
3	2005-07-08 12:47:11	4.99
3	2005-07-31 03:27:58	2.99

select customer_id, payment_date::date, amount,
	sum(amount) over (partition by customer_id order by payment_date::date)
from payment 

2.99
2.99+0.99
2.99+0.99+5.99+0.99+9.99
2.99+0.99+5.99+0.99+9.99
2.99+0.99+5.99+0.99+9.99

select customer_id, payment_date::date, amount,
	avg(amount) over (partition by customer_id order by payment_date::date)
from payment

-- работа функций lag и lead
дата_убытия1 | дата_прибытия1
дата_убытия2 | дата_прибытия2

lag(значение, шаг, значение_по_умолчанию) over (...)

дата_убытия2 - lag(дата_прибытия1)

select customer_id, payment_date, 
	lag(amount) over (partition by customer_id order by payment_date), 
	amount,
	lead(amount) over (partition by customer_id order by payment_date)
from payment 

-- ложная работа с данными
select date_trunc('month', payment_date), sum(amount),
	lag(sum(amount)) over (order by date_trunc('month', payment_date)),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', payment_date))
from payment 
group by date_trunc('month', payment_date)

select date_trunc('month', created_at), sum(amount),
	lag(sum(amount), 12) over (order by date_trunc('month', created_at)),
	sum(amount) - lag(sum(amount), 12) over (order by date_trunc('month', created_at))
from projects 
group by date_trunc('month', created_at)

select customer_id, payment_date, 
	lag(amount, 0, 0) over (partition by customer_id order by payment_date), 
	amount,
	lead(amount, 0, 0) over (partition by customer_id order by payment_date)
from payment 

-- работа с рангами и порядковыми номерами
row_number()
dense_rank
rank
percent_rank

1	-	1:00
2,3	-	1:01
4	-	1:02

1	1
2	3
3	2
4	4

1	1
2	2,3
3	4

1	1
2	2,3
4	4

1	0
2	0.5
3	1

select customer_id, payment_date::date,
	row_number() over (partition by customer_id order by payment_date::date),
	dense_rank() over (partition by customer_id order by payment_date::date),
	rank() over (partition by customer_id order by payment_date::date),
	percent_rank() over (partition by customer_id order by payment_date::date)
from payment 

-- first_value / last_value / nth_value
--найти первую аренду по каждому пользователю

explain analyze --Unique  (cost=1431.09..1511.31 rows=599 width=36) (actual time=5.308..6 rows=599 loops=1)
select distinct on (customer_id) *
from rental 
order by customer_id, rental_date

explain analyze --Hash Join  (cost=405.64..800.31 rows=1 width=36) (actual time=3.263..5.603 rows=599 loops=1)
select *
from rental 
where (customer_id, rental_date) in (
	select customer_id, min(rental_date)
	from rental 
	group by 1)
	
explain analyze --Subquery Scan on unnamed_subquery  (cost=1431.09..1952.52 rows=80 width=44) (actual time=7.110..9.218 rows=599 loops=1)
select *
from (
	select *, row_number() over (partition by customer_id order by rental_date)
	from rental)
where row_number = 1

explain analyze --HashAggregate  (cost=2233.29..2393.73 rows=16044 width=44) (actual time=30.718..30.867 rows=599 loops=1)
select distinct customer_id,
	first_value(rental_id) over (partition by customer_id order by rental_date),
	first_value(rental_date) over (partition by customer_id order by rental_date),
	first_value(inventory_id) over (partition by customer_id order by rental_date),
	first_value(return_date) over (partition by customer_id order by rental_date),
	first_value(staff_id) over (partition by customer_id order by rental_date),
	first_value(last_update) over (partition by customer_id order by rental_date)
from rental

explain analyze --Subquery Scan on unnamed_subquery  (cost=1431.09..1952.52 rows=80 width=40) (actual time=6.825..14.749 rows=599 loops=1)
select *
from (
	select *,
		first_value(rental_id) over (partition by customer_id order by rental_date)
	from rental)
where first_value = rental_id

--ложный запрос
select *
from (
	select *,
		last_value(rental_id) over (partition by customer_id order by rental_date desc)
	from rental)
where last_value = rental_id

explain analyze --Subquery Scan on unnamed_subquery  (cost=1431.09..1912.41 rows=80 width=40) (actual time=5.305..15.607 rows=599 loops=1)
select *
from (
	select *,
		last_value(rental_id) over (partition by customer_id)
	from (
		select *
		from rental 
		order by customer_id, rental_date desc))
where last_value = rental_id

select *
from (
	select *,
		last_value(rental_id) over (partition by customer_id order by rental_date desc
			rows between unbounded preceding and unbounded following)
	from rental)
where last_value = rental_id

rows 
range
groups

select customer_id, payment_date::date, amount,
	sum(amount) over (order by payment_date::date rows between 2 preceding and 2 following),
	avg(amount) over (order by payment_date::date rows between 2 preceding and 2 following)
from payment 

select customer_id, payment_date::date, amount,
	sum(amount) over (order by payment_date::date range between '2 days 12 hours' preceding and '2 days' following),
	avg(amount) over (order by payment_date::date range between '2 days 12 hours' preceding and '2 days' following)
from payment 

select customer_id, payment_date::date, amount,
	sum(amount) over (order by payment_date::date groups between 2 preceding and 2  following),
	avg(amount) over (order by payment_date::date groups between 2 preceding and 2  following)
from payment 

select customer_id, payment_date::date, amount,
	sum(amount) over (order by payment_date::date groups between 2 preceding and current row),
	avg(amount) over (order by payment_date::date groups between 2 preceding and current row)
from payment 

--алиасы
select c.last_name, c.first_name, f.title,
	avg(p.amount) over w_1,
	sum(p.amount) over w_1,
	count(p.amount) over w_1,
	avg(p.amount) over w_2,
	sum(p.amount) over w_2,
	count(p.amount) over w_2
from customer c 
join rental r on r.customer_id = c.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
join payment p on r.rental_id = p.rental_id
window w_1 as (partition by c.customer_id), 
	w_2 as (partition by p.staff_id, date_trunc('month', p.payment_date))

--фильтрация
select customer_id, payment_date::date, amount,
	sum(amount) filter (where amount < 5) over (order by payment_date::date groups between 2 preceding and current row),
	avg(amount) filter (where amount >= 5)  over (order by payment_date::date groups between 2 preceding and current row)
from payment 

============= общие табличные выражения =============

до postgresql 12

--плохая практика
with cte1 as (логика1),
cte2 as (логика2),
cte3 as (логика3)
select *
from cte1
join cte2
join cte3

--хорошо 
select 
from (логика1)
join (логика2)
join (логика3)

--хорошо 
with cte1 as (логика1)
select *
from cte1
join cte1
join cte1

--плохо
select 
from (логика1)
join (логика1)
join (логика1)

c postgresql 12

--все равно
with cte1 as (логика1),
cte2 as (логика2),
cte3 as (логика3)
select *
from cte1
join cte2
join cte3

--равнозначно
select 
from (логика1)
join (логика2)
join (логика3)

--хорошо 
with cte1 as (логика1)
select *
from cte1
join cte1
join cte1

--плохо
select 
from (логика1)
join (логика1)
join (логика1)

2.  При помощи CTE выведите таблицу со следующим содержанием:
Название фильма продолжительностью более 3 часов и к какой категории относится фильм
* Создайте CTE:
 - Используйте таблицу film
 - отфильтруйте данные по длительности
 * напишите запрос к полученной CTE:
 - соедините с film_category
 - соедините с category

with cte1 as (
	select * 
	from film 
	where length > 180),
cte2 as (
	select *
	from cte1
	join film_category fc on fc.film_id = cte1.film_id),
cte3 as (
	select *
	from category c
	where lower(left(name, 1)) = 'c')
select *
from cte2
join cte3 on cte3.category_id = cte2.category_id

with cte as (
	select payment_date::date, sum(amount)
	from payment 
	group by payment_date::date)
select c1.payment_date, c1.sum, c2.payment_date, c2.sum, c3.payment_date, c3.sum
from cte c1 
join cte c2 on c1.payment_date = c2.payment_date + interval '1 day'
join cte c3 on c2.payment_date = c3.payment_date + interval '1 day'
	
2.1. Выведите фильмы, с категорией начинающейся с буквы "C"
* Создайте CTE:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините полученное табличное выражение с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"


============= общие табличные выражения (рекурсивные) =============
 
 3.Вычислите факториал
 + Создайте CTE
 * стартовая часть рекурсии (т.н. "anchor") должна позволять вычислять начальное значение
 *  рекурсивная часть опираться на данные с предыдущей итерации и иметь условие остановки
 + Напишите запрос к CTE

with cte as (
	with recursive r as (
		with cte as ())),

with recursive r as (
	--стартовая часть
	select 1 as x, 1 as factorial
	union
	--рекурсивная часть
	select x + 1 as x, factorial * (x + 1) as factorial
	from r 
	where x < 12)
select *
from r

департамент - отдел - группа

департамент - отдел - отдел - группа - группа - группа

with recursive r as (
	--стартовая часть
	select *, 0 as level
	from "structure" s
	where unit_id = 59
	union
	--рекурсивная часть
	select s.*, level + 1 as level
	from r 
	join "structure" s on r.parent_id = s.unit_id)
select *
from r

59	15	Отдел	Центр архектуры и разработки BSS	0

with recursive r as (
	--стартовая часть
	select *, 0 as level
	from "structure" s
	where unit_id = 59
	union
	--рекурсивная часть
	select s.*, level + 1 as level
	from r 
	join "structure" s on r.unit_id = s.parent_id)
select count(*)
from r
join position p on p.unit_id = r.unit_id
join employee e on e.pos_id = p.pos_id

with recursive r as (
	--стартовая часть
	select 1 as x
	union
	--рекурсивная часть
	select x + 3
	from r 
	where x < 100)
select *
from r

select x
from generate_series(1, 100, 3) x

with recursive r as (
	--стартовая часть
	select '01.01.2024'::date as x
	union
	--рекурсивная часть
	select x + 1
	from r 
	where x < '31.12.2024')
select *
from r

select x::date
from generate_series('01.01.2024'::date, '31.12.2024'::date, interval '1 day') x

select date_trunc('month', payment_date), sum(amount),
	lag(sum(amount)) over (order by date_trunc('month', payment_date)),
	sum(amount) - lag(sum(amount)) over (order by date_trunc('month', payment_date))
from payment 
group by date_trunc('month', payment_date)

explain analyze --5177.40 / 12
with recursive r as (
	--стартовая часть
	select min(date_trunc('month', payment_date)) x
	from payment 
	union
	--рекурсивная часть
	select x + interval '1 month'
	from r 
	where x < (select max(date_trunc('month', payment_date)) from payment))
select x::date, coalesce(p.sum, 0),
	lag(coalesce(p.sum, 0), 1, 0) over (order by x),
	coalesce(p.sum, 0) - lag(coalesce(p.sum, 0), 1, 0) over (order by x)
from r
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by date_trunc('month', payment_date)) p on p.date_trunc = x
order by 1

select coalesce(null, null, null, null, null, 6, null, null, null, null, 8)

explain analyze --16366.55 / 12
select x::date, coalesce(p.sum, 0),
	lag(coalesce(p.sum, 0), 1, 0) over (order by x),
	coalesce(p.sum, 0) - lag(coalesce(p.sum, 0), 1, 0) over (order by x)
from generate_series(
	(select min(date_trunc('month', payment_date)) from payment),
	(select max(date_trunc('month', payment_date)) from payment),
	interval '1 month') x
left join (
	select date_trunc('month', payment_date), sum(amount)
	from payment 
	group by date_trunc('month', payment_date)) p on p.date_trunc = x
order by 1