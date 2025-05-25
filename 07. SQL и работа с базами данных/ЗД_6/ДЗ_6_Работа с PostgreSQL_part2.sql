--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

select f.film_id, f.title, f.special_features from film f 
where 'Behind the Scenes' = any(f.special_features)



--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.
select f.film_id, f.title, f.special_features from film f 
--where f.special_features @> array['Behind the Scenes'] -- т.к поиск только одного атрибута в массиве, то использую логическое "И" 
--where f.special_features && array['Behind the Scenes'] -- т.к поиск только одного атрибута в массиве, то могу использовать лог. "ИЛИ"
--where f.special_features <@ array['Behind the Scenes'] -- в данном случае поиск только тех массивов, которые содержат ТОЛЬКО 'Behind the Scenes' (лог. "=")  
where not 'Behind the Scenes' != all(f.special_features)


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--explain analyze --cost=683.98..685.48 rows=599 width=10) (actual time=15.303..15.334 rows=599 loops=1
with cte_1 as (
	select f.film_id, f.title, f.special_features from film f 
	where 'Behind the Scenes' = any(f.special_features)),
cte_2 as (
	select r.customer_id, i.film_id 
	from rental r
	join inventory i using(inventory_id))
select customer_id, count(film_id) film_count
from cte_1
join cte_2 using(film_id)
group by customer_id
order by customer_id

-- С одним CTE
explain analyze -- Sort  (cost=683.98..685.48 rows=599 width=10) (actual time=14.122..14.155 rows=599 loops=1)
with cte as (
	select f.film_id, f.title, f.special_features from film f 
	where 'Behind the Scenes' = any(f.special_features))
select customer_id, count(cte.film_id) film_count
from cte
join inventory i on i.film_id = cte.film_id
join rental r using(inventory_id)
group by customer_id
order by customer_id	

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.


--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".
--explain analyze --Sort  (cost=683.98..685.48 rows=599 width=10) (actual time=8.091..8.110 rows=599 loops=1)
select customer_id,  count(t.film_id) film_count
from (
	select f2.film_id, f2.special_features
	from film f2 
	where 'Behind the Scenes' = any(f2.special_features)) as t
join inventory i on i.film_id = t.film_id
join rental r using(inventory_id)
group by customer_id
order by customer_id

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.


--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view  Behind_the_Scenes as 
	select customer_id,  count(t.film_id) film_count
	from (
		select f2.film_id, f2.special_features
		from film f2 
		where 'Behind the Scenes' = any(f2.special_features)) as t
	join inventory i on i.film_id = t.film_id
	join rental r using(inventory_id)
	group by customer_id
	order by customer_id

create unique index attr_film_id_idx on behind_the_scenes(customer_id) -- создание уникального индекса столбца customer_id для возможности обновления	
	
refresh materialized view concurrently behind_the_scenes	

--commit -- команда завершения транзакции

select * from  behind_the_scenes bts 

 
--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;
--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.
explain analyze --explain (analyze, format json) -- Sort  (cost=683.98..685.48 rows=599 width=10) (actual time=16.034..16.067 rows=599 loops=1)
with cte as (
	select f.film_id, f.title, f.special_features from film f 
	where 'Behind the Scenes' = any(f.special_features))
select customer_id, count(cte.film_id) film_count
from cte
join inventory i on i.film_id = cte.film_id
join rental r using(inventory_id)
group by customer_id
order by customer_id

explain analyze --explain (analyze, format json)  --Sort  (cost=683.98..685.48 rows=599 width=10) (actual time=13.941..13.973 rows=599 loops=1)
select customer_id,  count(t.film_id) film_count
from (
	select f2.film_id, f2.special_features
	from film f2 
	where 'Behind the Scenes' = any(f2.special_features)) as t
join inventory i on i.film_id = t.film_id
join rental r using(inventory_id)
group by customer_id
order by customer_id


1)
CTE:      ->  Seq Scan on film f  (cost=0.00..77.50 rows=538 width=4) (actual time=0.026..0.602 rows=538 loops=1)

subquery: ->  Seq Scan on film f2  (cost=0.00..77.50 rows=538 width=4) (actual time=0.014..0.491 rows=538 loops=1)
В подзапросе чуть быстрее сканирование, но стоимость одинаковая  

2) Стоимость всего запроса получилось удинаковой, время чуть быстрее у подзапроса.




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.





--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день





