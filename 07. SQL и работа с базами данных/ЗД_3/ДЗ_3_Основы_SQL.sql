--=============== МОДУЛЬ 3. ОСНОВЫ SQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите для каждого покупателя его адрес проживания, 
--город и страну проживания.
select concat_ws(' ', c.first_name, c.last_name) as "Customer name", a.address, c2.city, c3.country 
from customer c 
join address a on c.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id
join country c3 on c3.country_id = c2.country_id 


--ЗАДАНИЕ №2
--С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select c.store_id "ID магазина", count(c.store_id) "Количество покупателей" 
from customer c 
group by c.store_id 



--Доработайте запрос и выведите только те магазины, 
--у которых количество покупателей больше 300-от.
--Для решения используйте фильтрацию по сгруппированным строкам 
--с использованием функции агрегации.
select c.store_id "ID магазина", count(c.store_id) "Количество покупателей" 
from customer c 
group by c.store_id
having count(c.store_id) > 300




-- Доработайте запрос, добавив в него информацию о городе магазина, 
--а также фамилию и имя продавца, который работает в этом магазине.
select t."ID магазина", t."Количество покупателей", c2.city Город, t."Имя сотрудника"
from (
	select c.store_id "ID магазина", concat_ws(' ', s.last_name, s.first_name) "Имя сотрудника", 
		   count(c.store_id) "Количество покупателей"
	from customer c
	join staff s on s.store_id = c.store_id 
	group by c.store_id, concat_ws(' ', s.last_name, s.first_name)
	having count(c.store_id) > 300) as t
join store s2 on s2.store_id = t."ID магазина"
join address a on a.address_id = s2.address_id 
join city c2 on c2.city_id = a.city_id 

	
	
--ЗАДАНИЕ №3
--Выведите ТОП-5 покупателей, 
--которые взяли в аренду за всё время наибольшее количество фильмов
select concat_ws(' ', c.last_name, c.first_name) "Фамилия и имя покупателя", t.count "Количество фильмов"
from (
	select  p.customer_id, count(p.customer_id)         --i.film_id, r.rental_id, p.payment_id
	from payment p 
	join rental r on r.rental_id = p.rental_id          -- связь количество аренд
	join inventory i on i.inventory_id = r.inventory_id -- связь количество фильмов
	group by p.customer_id
	order by count(p.customer_id) desc
	limit 5) as t 
join customer c on c.customer_id = t.customer_id 		-- связь с ФИО
order by t.count desc 


--ЗАДАНИЕ №4
--Посчитайте для каждого покупателя 4 аналитических показателя:
--  1. количество фильмов, которые он взял в аренду
--  2. общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа)
--  3. минимальное значение платежа за аренду фильма
--  4. максимальное значение платежа за аренду фильма
select t."ФИО", count(t."ФИО") as "Количество фильмов", 
	   ceil(sum(t.amount)) "Общая стоимость платежей", min(t.amount) "МИН. стоимость платежа", 
	   max(t.amount) "МАКС. стоимость платежа" 
from (
	select concat_ws(' ', c.last_name, c.first_name) "ФИО", i.film_id, p.amount 
	from payment p 
	join rental r on r.rental_id = p.rental_id          		
	join inventory i on i.inventory_id = r.inventory_id
	join customer c on c.customer_id = p.customer_id) as t
group by t."ФИО"	             
--having t."ФИО" = 'WATSON THERESA' -- CROUSE ALBERT, COLLAZO TOMMY, WILES JON, TUBBS DUANE, WATSON THERESA (<ДЛЯ ПРОВЕРКИ>)

--ВАРИАНТ_2--НЕ ДОРАБОТАНО
select t."Фамилия и имя покупателя", t.array_film_id, t.array_amount
from (
select concat_ws(' ', c.last_name, c.first_name) "Фамилия и имя покупателя", 
	   array_agg(i.film_id) array_film_id, 
	   array_agg(p.amount )array_amount    
	from payment p 
	join rental r on r.rental_id = p.rental_id          		
	join inventory i on i.inventory_id = r.inventory_id
	join customer c on c.customer_id = p.customer_id
	group by concat_ws(' ', c.last_name, c.first_name)) as t


--ЗАДАНИЕ №5
--Используя данные из таблицы городов, составьте все возможные пары городов так, чтобы 
--в результате не было пар с одинаковыми названиями городов. Решение должно быть через Декартово произведение.
select c1.city "Город 1", c2.city "Город 2"
from city c1 
cross join city c2
where c1.city < c2.city 
order by 1, 2

--ЗАДАНИЕ №6
--Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и 
--дате возврата (поле return_date), вычислите для каждого покупателя среднее количество 
--дней, за которые он возвращает фильмы. В результате должны быть дробные значения, а не интервал.
 
select r.customer_id "ID покупателя", round(avg(r.return_date::date - r.rental_date::date), 2) "Среднее количество дней на возрат"
from rental r
group by r.customer_id 
order by r.customer_id 


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.
select t_2.title "Название фильма", t_2.rating "Рейтинг", t_2."Жанр", t_2.release_year "Год выпуска", t_2."Язык", 
	   count(t.rental_id) "Количество аренд", sum(t.amount) "Общая стоимость аренды"
from (
	select  r.rental_id, i.film_id, p.amount
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id) as t
join (select f.film_id, f.title, f.rating, c."name" "Жанр", f.release_year, l."name" "Язык"  
	from film f 
	join film_category fc on fc.film_id = f.film_id 
	join category c on c.category_id = fc.category_id 
	join "language" l on l.language_id = f.language_id) as t_2 on t.film_id = t_2.film_id 
group by t_2.title, t_2.rating, t_2."Жанр", t_2.release_year, t_2."Язык"
order by 1


--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.

--Вариант_1 
select t_3.title "Название фильма", t_3.rating "Рейтинг", t_3."Жанр", t_3.release_year "Год выпуска", t_3."Язык", 
	   count(t.rental_id) "Количество аренд", sum(t.amount) "Общая стоимость аренды"
from (
	select  r.rental_id, i.film_id, p.amount
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id) as t
right join (select t_null.film_id, f2.title, f2.rating, c."name" "Жанр", f2.release_year, l."name" "Язык"
	from (
		select f.film_id 
		from film f 
		except
		select i.film_id 
		from inventory i) as t_null
	join film f2 on f2.film_id = t_null.film_id
	join film_category fc on fc.film_id = f2.film_id 
	join category c on c.category_id = fc.category_id 
	join "language" l on l.language_id = f2.language_id) as t_3 on t_3.film_id = t.film_id 
group by t_3.title, t_3.rating, t_3."Жанр", t_3.release_year, t_3."Язык"
order by 1


--Вариант_2
select t_2.title "Название фильма", t_2.rating "Рейтинг", t_2."Жанр", t_2.release_year "Год выпуска", t_2."Язык", 
	   count(t.rental_id) "Количество аренд", sum(t.amount) "Общая стоимость аренды"
from (
	select  r.rental_id, i.film_id, p.amount
	from rental r 
	join inventory i on i.inventory_id = r.inventory_id
	join payment p on p.rental_id = r.rental_id) as t
right join (
	select f.film_id, f.title, f.rating, c."name" "Жанр", f.release_year, l."name" "Язык"  
	from film f 
	join film_category fc on fc.film_id = f.film_id 
	join category c on c.category_id = fc.category_id 
	join "language" l on l.language_id = f.language_id
	where f.film_id in 
		(select f.film_id 
		from film f 
		except
		select i.film_id 
		from inventory i)) as t_2 on t_2.film_id = t.film_id 
group by t_2.title, t_2.rating, t_2."Жанр", t_2.release_year, t_2."Язык"
order by 1


--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".
select p.staff_id, count(p.payment_id) "Количество продаж",
	case 
		when count(p.payment_id) > 7300 then 'Да'
		else 'Нет'
	end as "Премия" 
from payment p 
group by p.staff_id


