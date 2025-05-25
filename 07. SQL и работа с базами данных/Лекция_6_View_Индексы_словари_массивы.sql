============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

create view task_1 as 
	explain analyze --2148.15 / 10
	select c.last_name, c.first_name, c.email, f.title
	from (
		select rental_id, inventory_id, customer_id, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1

create view task_2 as 
	select c.customer_id, f.film_id, c.last_name, c.first_name, c.email, f.title
	from (
		select rental_id, inventory_id, customer_id, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
explain analyze --2148.15 / 10
select * 
from task_1 t

select t.last_name, t.first_name, t.title, sum(amount)
from task_2 t
join payment p on p.customer_id = t.customer_id
group by p.customer_id, t.last_name, t.first_name, t.title

4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create view task_3 as 
	select a.last_name, a.first_name, f.title, count(*) over (partition by a.actor_id)
	from film f
	join film_actor fa on f.film_id = fa.film_id
	join actor a on a.actor_id = fa.actor_id
	
select * from task_3
	
============= материализованные представления =============

5. Создайте материализованное представление с колонками клиент (ФИО; email) и title фильма, 
который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные 

create materialized view task_4 as 
	--explain analyze --2148.15 / 10
	select c.last_name, c.first_name, c.email, f.title
	from (
		select rental_id, inventory_id, customer_id, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
--with data
	
explain analyze --10.90 / 0.05
select * 
from task_4

select * from customer c

commit

refresh materialized view concurrently task_4 

SQL Error [55000]: ОШИБКА: обновить материализованное представление "public.task_4" параллельно нельзя
  Подсказка: Создайте уникальный индекс без предложения WHERE для одного или нескольких столбцов материализованного 
  
create unique index task_4_idx on task_4 (email)

5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные

create materialized view task_5 as 
	select c.name
	from category c
	join film_category fc on c.category_id = fc.category_id
	join film f on f.film_id = fc.film_id
	group by c.category_id
	having avg(f.rental_duration) > 5
with no data

refresh materialized view task_5

select * from task_5
	
--запрос на проверку времени обновления мат представлений

WITH pgdata AS (
    SELECT setting AS path
    FROM pg_settings
    WHERE name = 'data_directory'
),
path AS (
    SELECT
    	CASE
            WHEN pgdata.separator = '/' THEN '/'    -- UNIX
            ELSE '\'                                -- WINDOWS
        END AS separator
    FROM 
        (SELECT SUBSTR(path, 1, 1) AS separator FROM pgdata) AS pgdata
)
SELECT
        ns.nspname||'.'||c.relname AS mview,
        (pg_stat_file(pgdata.path||path.separator||pg_relation_filepath(ns.nspname||'.'||c.relname))).modification AS refresh
FROM pgdata, path, pg_class c
JOIN pg_namespace ns ON c.relnamespace=ns.oid
WHERE c.relkind='m';

названием_схемы | название_мат_вью | кто_обновлял | дата+время_начала_обновления | дата+время_окончания_обновления | статус | err_msg | добавьте свое по желанию

============ Индексы ===========

https://edu.postgrespro.ru/postgresql_internals-16.pdf ~ 500

страница  = 8кб

btree < <= = >= > between null
hash =
gin 
gist

select *
from payment
where payment_id = 78

alter table payment drop constraint payment_pkey

0 idx = 1.2mb

explain analyze --Seq Scan on payment  (cost=0.00..319.61 rows=1 width=26) (actual time=0.018..1.095 rows=1 loops=1)
select *
from payment
where payment_id = 78

alter table payment add constraint payment_pkey primary key (payment_id)

explain analyze --Index Scan using payment_pkey on payment  (cost=0.29..8.30 rows=1 width=26) (actual time=0.023..0.024 rows=1 loops=1)
select *
from payment
where payment_id = 78

https://postgrespro.ru/docs/postgresql/16/pageinspect

create extension pageinspect

select *
from bt_metap('payment_pkey')

select *
from bt_page_stats('payment_pkey', 2)

select *
from bt_page_items('payment_pkey', 2)

create index pay_strange_1_idx on payment (payment_date)

drop index pay_strange_1_idx

select * from payment p

2 idx = 1.9mb

составной уникальный

create unique index pay_strange_2_idx on payment (payment_id, customer_id, staff_id, payment_date)

select *
from payment p
where customer_id = 107 and staff_id = 1 and payment_date = '2006-02-14 15:16:03'

функциональный

select *
from task_4 t

create index first_letter_idx on task_4 (lower(left(last_name, 1)))

explain analyze
select *
from task_4 t
where lower(left(last_name, 1)) = 'a'

условные индексы

explain analyze
select *
from payment p
where payment_date::date = '01.08.2005'

create index pay_strange_3_idx on payment (cast(payment_date as date)) where date_trunc('month', payment_date) = '01.08.2005'

explain analyze
select * --5 687
from payment p
where date_trunc('month', payment_date) = '01.08.2005'

explain analyze
select *
from payment
where payment_id < 8525

4 idx = 2.5mb

explain analyze
select *
from payment
order by payment_date

insert into 
1 таблицу
4 индекса

таблица 100млн строк id - bigserial
insert into 100млн

таблица 100млн строк id - uuid
insert into 100млн

create index название  - блокировка таблицы

create index concurrently

hash

create index pay_hash_idx on payment using hash (payment_id)

explain analyze --Index Scan using pay_hash_idx on payment  (cost=0.00..8.02 rows=1 width=26) (actual time=0.022..0.022 rows=1 loops=1)
select *
from payment
where payment_id = 78

16000

160 корзин по 100 записей

============ explain ===========

Ссылка на сервис по анализу плана запроса 
https://tatiyants.com/pev/

explain analyze
	select c.last_name, c.first_name, c.email, f.title
	from (
		select rental_id, inventory_id, customer_id, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
cost=2148.15 
rows=80 
width=60
actual time=10.483
rows=599
loops=1

80 * 60 = 4800 бт
600 * 60 = 36000 бт

16044 * 14
16044 * 36

explain (analyze, verbose)
	select c.last_name, c.first_name, c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
explain (analyze, buffers)
	select c.last_name, c.first_name, c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
explain (analyze, format json)
	select c.last_name, c.first_name, c.email, f.title
	from (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r 
	join customer c on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
select customer_id, count(*)
from payment
group by 1

explain --rows=80
select *
from payment
where payment_date::date = '01.08.2005'

explain analyse--rows=671
select *
from payment
where payment_date::date = '01.08.2005'

analyse payment

create statistics s1 on cast(payment_date as date) from payment

analyse payment

explain analyse--rows=671
select *
from payment
where payment_date::date = '01.08.2005'

loops > 1 если index scan - хорошо, если subquery scan, aggregate, wondow - катастрофа
project set - катастрофа

2000.23423523562362
1000..2000

postgresql enterprise

pg_hint_plan 

explain analyze --idx_fk_customer_id 

/*+ Index Scan (payment pay_strange_1_idx) */
select *
from payment p
where customer_id = 107 

======================== json ========================

СЛОЖНЫЕ ТИПЫ ДАННЫХ НЕЛЬЗЯ ПРИВОДИТЬ К СТРОКЕ, НЕДОПУСТИМО, ПЛОХО И УЖАСНО.

json::text
polygon::text
array::text

json - лучше не стоит, нуу очень долгий
jsonb - при необходитмости, можно работать, как с массивом

Создайте таблицу orders

CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "no more beer","qty": 6,"a":345}, "customer": "John Doe"}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24.5}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
 );

 
INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "01.01.2023","qty": "fgdfgh"}, "customer": "John Doe"}'
 )

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )
 
select *
from orders

6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

select json_object_keys(info->'items')
from orders

select info, pg_typeof(info)
from orders

select info->'items', pg_typeof(info->'items')
from orders

select info->'items'->'qty', pg_typeof(info->'items'->'qty')
from orders

--плохо
select (info->'items'->'qty')::text, pg_typeof((info->'items'->'qty')::text)
from orders

"fgdfgh"

--хорошо
select info->'items'->>'qty', pg_typeof(info->'items'->>'qty')
from orders

fgdfgh

select (info->'items'->>'qty')::numeric
from orders

SQL Error [22P02]: ОШИБКА: неверный синтаксис для типа numeric: "fgdfgh"

select sum((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'qty' ~ '[0-9]'

6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'qty' ~ '[0-9]' and info->'items'->>'product' like 'Toy%'

======================== array ========================

time[] ['10:00', '12:00']
int[] [457457,234,6796,1235]
text[] ['123', '01.01.2024', 'djkfbgjkdhfb']

create table some_arr (
	id serial,
	val int[])
	
insert into some_arr (val)
values (array[55,66]), ('{77,88}'::int[])

select * 
from some_arr

update some_arr
set val[-10] = 100
where id = 1

{[-10:2]={100,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,55,66}}

select val[-10:-5], val[2]
from some_arr

select array_upper(val, 1), array_lower(val, 1), array_length(val, 1)
from some_arr

select array_length('{{1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}}'::text[], 1) --11

select array_length('{{1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}}'::text[], 2) --3

select cardinality('{{1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}, {1,2,3}}'::text[]) --33

7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

select title, special_features, array_length(special_features, 1)
from film
 
7* Нужно посчитать кол-во сотрудников, задействованных на проектах.
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

select *, array_length(employees_id, 1) + 1
from projects p

select *, 
	case 
		when employees_id && array[assigned_id] then array_length(employees_id, 1)
		else array_length(employees_id, 1) + 1
	end	
from projects p

explain analyze

select "name", count(distinct unnest)
from (
	select *, unnest(array_append(employees_id, assigned_id))
	from projects)
group by project_id, "name"

select name, employees_id
from projects 
where employees_id && array[78, 12]

select name, employees_id
from projects 
where employees_id @> array[78]

select name, employees_id --то же, что и выше, один и тот же вариант
from projects 
where array[78] <@ employees_id

select name, employees_id
from projects 
where employees_id <@ array[78, 1577,1033,78,2084,1984,1922,1618,2689,1849]

select name, employees_id
from projects 
where 78 = any(employees_id) --some

select name, employees_id
from projects 
where 78 = all(employees_id) 

select project_id, name, employees_id --1, 30
from projects 
where not 78 = any(employees_id)

select project_id, name, employees_id
from projects 
where 78 != all(employees_id) 

select project_id, name, array_position(employees_id, 78)
from projects 
where project_id in (1, 30)

select project_id, name, array_positions(array_append(employees_id, 78), 78)
from projects 
where project_id in (1, 30)

5 5 7 4 9 5 7 2 8 6 9 5

1, 2, 6, 12

select array[1,2,3] || array[4,5,6]

https://postgrespro.ru/docs/postgresql/16/functions-subquery
https://postgrespro.ru/docs/postgrespro/16/functions-array


