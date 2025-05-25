Задание 1.Выведите информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, 
а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.
Ожидаемый результат запроса: letsdocode.ru...in/2-7.png

select title, rating, rental_rate
from film 
where (rating = 'R' and rental_rate between 0. and 3.) or
	(rating = 'PG-13' and rental_rate >= 4.)

Задание 2. Получите информацию о трёх фильмах с самым длинным описанием фильма.
Ожидаемый результат запроса: letsdocode.ru...in/2-8.png

select title, description, char_length(description)
from film 
order by char_length(description) desc 
fetch first 3 rows with ties

select title, description, char_length(description)
from film 
order by char_length(description) desc 
limit 3

Задание 3. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
в первой колонке должно быть значение, указанное до @,
во второй колонке должно быть значение, указанное после @.
Ожидаемый результат запроса: letsdocode.ru...in/2-9.png

select email, 
	split_part(email, '@', 1),
	split_part(email, '@', 2)
from customer 

select email, 
	split_part(email, '@', 1),
	substring(email, strpos(email, '@'))
from customer 

Задание 4. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква строки должна быть заглавной, 
остальные строчными.
Ожидаемый результат запроса: letsdocode.ru...n/2-10.png

--ложное решение
select email, 
	concat(left(split_part(email, '@', 1), 1), lower(right(split_part(email, '@', 1), -1))),
	concat(upper(left(split_part(email, '@', 2), 1)), right(split_part(email, '@', 2), -1))
from customer 
order by customer_id

pa.tri.cia.johnson777	Sa.KILacustomer.org

J	ennifer.davis

--верное решение
select email, 
	concat(upper(left(split_part(email, '@', 1), 1)), lower(right(split_part(email, '@', 1), -1))),
	concat(upper(left(split_part(email, '@', 2), 1)), lower(right(split_part(email, '@', 2), -1)))
from customer 
order by customer_id

select email, 
	overlay(
		lower(split_part(email, '@', 1))
		placing upper(left(split_part(email, '@', 1), 1))
		from 1 
		for 1),
	overlay(
		lower(split_part(email, '@', 2))
		placing upper(left(split_part(email, '@', 2), 1))
		from 1 
		for 1)
from customer 
order by customer_id

Задание 1. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
Ожидаемый результат запроса: letsdocode.ru...in/3-7.png

--ложный запрос
select f.title, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on f.film_id = i.film_id --f.film_id стал НЕУНИКАЛЕН
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
left join "language" l on f.language_id = l.language_id
left join film_category fc on fc.film_id = f.film_id --fc.film_id НЕУНИКАЛЕН
left join category c on c.category_id = fc.category_id
group by f.film_id, l.language_id, c.category_id

select * from film_category

insert into film_category
values (1,1),(1,2),(1,3),(1,4),(1,5)

select f.title, l."name", c.string_agg, i.count, i.sum
from film f
left join (
	select i.film_id, count(r.rental_id), sum(p.amount)
	from inventory i  --f.film_id стал НЕУНИКАЛЕН
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	group by i.film_id) i on f.film_id = i.film_id
left join "language" l on f.language_id = l.language_id
left join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc --fc.film_id НЕУНИКАЛЕН
	left join category c on c.category_id = fc.category_id
	group by fc.film_id) c on c.film_id = f.film_id

Задание 2. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd-дисках.
Ожидаемый результат запроса: letsdocode.ru...in/3-8.png

explain analyze --1783.82 / 22
select f.title, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on f.film_id = i.film_id --f.film_id стал НЕУНИКАЛЕН
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
left join "language" l on f.language_id = l.language_id
left join film_category fc on fc.film_id = f.film_id --fc.film_id НЕУНИКАЛЕН
left join category c on c.category_id = fc.category_id
group by f.film_id, l.language_id, c.category_id
having count(r.rental_id) = 0

explain analyze --483.46 / 1.6
select f.title, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on f.film_id = i.film_id --f.film_id стал НЕУНИКАЛЕН
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
left join "language" l on f.language_id = l.language_id
left join film_category fc on fc.film_id = f.film_id --fc.film_id НЕУНИКАЛЕН
left join category c on c.category_id = fc.category_id
where i.inventory_id is null
group by f.film_id, l.language_id, c.category_id

explain analyze --534.92 / 2.4
select f.title, l."name", c.string_agg, f.count, f.sum
from  (
	select f.film_id, f.language_id, f.title, count(r.rental_id), sum(p.amount)
	from film f
	left join inventory i on f.film_id = i.film_id
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	where i.inventory_id is null
	group by f.film_id) f
left join "language" l on f.language_id = l.language_id
left join (
	select fc.film_id, string_agg(c.name, ', ')
	from film_category fc --fc.film_id НЕУНИКАЛЕН
	left join category c on c.category_id = fc.category_id
	group by fc.film_id) c on c.film_id = f.film_id

Задание 3. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». 
Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».
Ожидаемый результат запроса: letsdocode.ru...in/3-9.png

--ложное решение
select staff_id, count(*),
	case 
		when count(*) > 7300 then 'yes'
		else 'no'
	end
from payment 
group by 1

select * from staff s

insert into staff
values (3,	'no more Mike',	'Hillyer',	3,	'Mike.Hillyer@sakilastaff.com',	1,	true,	'Mike',	'8cb2237d0679ca88db6464eac60da96345513964',	'2006-02-15 04:57:16', null	)

select s.staff_id, count(p.payment_id),
	case 
		when count(*) > 7300 then 'yes'
		else 'no'
	end
from staff s 
left join payment p on p.staff_id = s.staff_id
group by 1

select 
from customer c 

count(*) > 300

Задание 1. Создайте новую таблицу film_new со следующими полями:
· film_name — название фильма — тип данных varchar(255) и ограничение not null;
· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;
· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;
· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, что значение должно быть больше 0.
Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new (
	film_id serial primary key,
	film_name varchar(255) not null,
	film_year integer check(film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check(film_duration > 0))

Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler’s List];
· film_year — array[1994, 1999, 1985, 1994, 1993];
· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];
· film_duration — array[142, 189, 116, 142, 195].

insert into film_new (film_name, film_year, film_rental_rate, film_duration)


explain analyze --0.06 / 0.009
select *
from unnest(
	array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List'],
	array[1994, 1999, 1985, 1994, 1993],
	array[2.99, 0.99, 1.99, 2.99, 3.99],
	array[142, 189, 116, 142, 195])

select unnest(array)

from unnest(array1, array2, array3 ... arrayN)

select * from film_new

insert into film_new (film_name, film_year, film_rental_rate, film_duration)

values (unnest (array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List']),
unnest (array[1994, 1999, 1985, 1994, 1993]), unnest (array[2.99, 0.99, 1.99, 2.99, 3.99]),  unnest (array[142, 189, 116, 142, 195]))

explain analyze --0.05 / 0.005
select unnest (array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List']),
unnest (array[1994, 1999, 1985, 1994, 1993]), unnest (array[2.99, 0.99, 1.99, 2.99, 3.99]),  unnest (array[142, 189, 116, 142, 195])

Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, что стоимость аренды всех фильмов поднялась на 1.41.

update film_new
set film_rental_rate = film_rental_rate + 1.41

Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом из таблицы film_new.

delete from film_new
where film_id = 3

Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values ('dsfgadsfhg', 323, 35, 23)

Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую вычисляемую колонку 
«длительность фильма в часах», округлённую до десятых.

alter table 

select *, round(film_duration / 60., 1)
from film_new

Задание 7. Удалите таблицу film_new.

drop table film_new

Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом 
по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
Ожидаемый результат запроса: letsdocode.ru...in/5-5.png

select staff_id, payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment 
where date_trunc('month', payment_date) = '01.08.2005'
group by 1, 2
order by 1, 2

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку 
на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
Ожидаемый результат запроса: letsdocode.ru...in/5-6.png

select *
from (
	select customer_id, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005')
where row_number % 100 = 0

--очень плохо
right(row_number, 2) = '00'
like '%00'

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.
Ожидаемый результат запроса: letsdocode.ru...in/5-7.png

explain analyze --6686.03 / 34
select distinct c.country, 
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by count(i.film_id) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by sum(p.amount) desc),
	first_value(concat(c3.last_name, ' ', c3.first_name)) over (partition by c.country_id order by max(r.rental_date) desc)
from country c
left join city c2 on c.country_id = c2.country_id
left join address a on a.city_id = c2.city_id
left join customer c3 on c3.address_id = a.address_id
left join rental r on c3.customer_id = r.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join payment p on r.rental_id = p.rental_id
group by c.country_id, c3.customer_id
order by 1

explain analyze --1271.96 / 14
with cte as (
	select r.customer_id, count, sum, max
	from (
		select r.customer_id, count(i.film_id), max(r.rental_date)
		from rental r
		join inventory i on r.inventory_id = i.inventory_id
		group by r.customer_id) r
	join (
		select customer_id, sum(amount)
		from payment 
		group by customer_id) p on p.customer_id = r.customer_id),
cte2 as (
	select c2.country_id, 
		case 
			when count = max(count) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name)
		end cc,
		case 
			when sum = max(sum) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name)
		end cs,
		case 
			when max = max(max) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name)
		end cm	
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id)
select c.*, string_agg(cc, ', '), string_agg(cs, ', '), string_agg(cm, ', ')
from country c
left join cte2 on cte2.country_id = c.country_id
group by c.country_id
order by 1

explain analyze --1434.04 / 15
with cte as (
	select r.customer_id, count, sum, max
	from (
		select r.customer_id, count(i.film_id), max(r.rental_date)
		from rental r
		join inventory i on r.inventory_id = i.inventory_id
		group by r.customer_id) r
	join (
		select customer_id, sum(amount)
		from payment 
		group by customer_id) p on p.customer_id = r.customer_id),
cte2 as (
	select c2.country_id, concat(c.last_name, ' ', c.first_name),
		dense_rank() over (partition by c2.country_id order by count desc) dc,
		dense_rank() over (partition by c2.country_id order by sum desc) ds,
		dense_rank() over (partition by c2.country_id order by max desc) dm
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id)
select c.*, 
	string_agg(concat, ', ') filter (where dc = 1), 
	string_agg(concat, ', ') filter (where ds = 1), 
	string_agg(concat, ', ') filter (where dm = 1)
from country c
left join cte2 on cte2.country_id = c.country_id
group by c.country_id
order by 1

explain analyze --1515.13 / 16
with cte as (
	select r.customer_id, count, sum, max
	from (
		select r.customer_id, count(i.film_id), max(r.rental_date)
		from rental r
		join inventory i on r.inventory_id = i.inventory_id
		group by r.customer_id) r
	join (
		select customer_id, sum(amount)
		from payment 
		group by customer_id) p on p.customer_id = r.customer_id),
cte2 as (
	select c2.country_id, concat(c.last_name, ' ', c.first_name),
		dense_rank() over (partition by c2.country_id order by count desc) dc,
		dense_rank() over (partition by c2.country_id order by sum desc) ds,
		dense_rank() over (partition by c2.country_id order by max desc) dm
	from cte 
	join customer c on c.customer_id = cte.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id)
select c.*, string_agg(distinct c1.concat, ', '), string_agg(distinct c2.concat, ', '), string_agg(distinct c3.concat, ', ') 
from country c
left join cte2 c1 on c1.country_id = c.country_id and c1.dc = 1
left join cte2 c2 on c2.country_id = c.country_id and c2.ds = 1
left join cte2 c3 on c3.country_id = c.country_id and c3.dm = 1
group by c.country_id
order by 1

Задание 1. Откройте по ссылке SQL-запрос.
Сделайте explain analyze этого запроса.
Основываясь на описании запроса, найдите узкие места и опишите их.
Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. Описание строк в explain можно посмотреть по ссылке.

select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

Behind the Scenes123123

345345Behind the Scenes

explain analyze --623.59 / 7.5
select concat(c.last_name, ' ', c.first_name), count(*)
from rental r
right join inventory i on r.inventory_id = i.inventory_id and 
	i.film_id in (	
		select film_id
		from film 
		where special_features && array['Behind the Scenes'])
join customer c on c.customer_id = r.customer_id
group by c.customer_id

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
Ожидаемый результат запроса: letsdocode.ru...in/6-5.png

select *
from (
	select *, row_number() over (partition by staff_id order by payment_date)
	from payment)
where row_number = 1

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.
Ожидаемый результат запроса: letsdocode.ru...in/6-6.png

Решения нет.

аренда			платеж
диск			диск
пользователь	пользователь
сотрудник		сотрудник	
диск			пользователь
диск			сотрудник	--ожидаемый результат
сотрудник		диск
сотрудник		пользователь
пользователь  	сотрудник
пользователь	диск

explain analyze --3103.20 / 16
select *
from (
	select i.store_id, r.rental_date::date, count(*),
		row_number() over (partition by i.store_id order by count(*) desc)
	from rental r
	join inventory i on r.inventory_id = i.inventory_id
	group by i.store_id, r.rental_date::date) r
join (
	select s.store_id, p.payment_date::date, sum(p.amount),
		row_number() over (partition by s.store_id order by sum(p.amount))
	from payment p
	join staff s on s.staff_id = p.staff_id
	group by s.store_id, p.payment_date::date) p on r.store_id = p.store_id
where p.row_number = 1 and r.row_number = 1


select distinct on(p.store_id) p.store_id, p.rental_date as day_max_rent, p.count as total_rents_per_day, 
					t.payment_date as day_min_pay, t.sum as total_amount_per_day
from(
	select i.store_id , r.rental_date::date , count(r.rental_id)
	from inventory i 
	join rental r on i.inventory_id = r.inventory_id 
	group by i.store_id , r.rental_date::date
	order by i.store_id , count desc) p
join (select distinct on(q.store_id) q.store_id, q.payment_date, q.sum
		from(
			select s.store_id , p.payment_date::date , sum(p.amount)
			from store s 
			join payment p on p.staff_id = s.manager_staff_id 
			group by s.store_id , p.payment_date::date
			order by s.store_id , sum) q) t using(store_id)
order by p.store_id

explain analyze --3468.36
with tab as(
	select s.store_id, i.inventory_id, r.rental_id, r.rental_date::date as ren_date, p.payment_id, p.amount, p.payment_date ::date as pay_date
	from store s 
		left join inventory i on s.store_id = i.store_id 
		left join rental r on i.inventory_id = r.inventory_id 
		left join payment p on r.rental_id = p.rental_id
	order by s.store_id, r.rental_date
),
tab_a as(
	select store_id, ren_date, count(rental_id) as kol_r
	from tab
	group by store_id, ren_date
),
a as (
	select *
	from tab_a 
	where (store_id, kol_r) in (select store_id, max(kol_r) from tab_a group by store_id)), 
tab_s as(
	select store_id, pay_date, sum(amount) as sum_p
	from tab
	group by store_id, pay_date
),
b as (
	select *
	from tab_s 
	where (store_id, sum_p) in (select store_id, min(sum_p) from tab_s group by store_id))
select s.store_id, t1.ren_date as "Лучший день аренды", t1.kol_r as "Кол фильмов", t2.pay_date as "Худший день продаж", t2.sum_p as "Сумма продаж"
from store s
	left join a t1 on s.store_id = t1.store_id 
	left join b t2 on s.store_id = t2.store_id 
	
explain analyze --1350.20 / 20
with cte as(
		select 	sf.store_id,
				payment_date::date DT,
				rental_date::date , 
				sum(amount) over (partition by sf.store_id, payment_date::date) SM,
				count(film_id) over (partition by sf.store_id, rental_date::date) CT
		from payment
		join staff sf using (staff_id) -- доступ store_id
		join rental using(rental_id)
		join inventory using(inventory_id)
		),
MIN_SUM as (
			select 	distinct store_id,
					DT, SM
			from cte
			where (store_id, SM) in (select store_id, min(SM) from cte group by 1) 
			),
MAX_CNT as(
			select distinct store_id,
					rental_date,
					CT
			from cte
			where (store_id, CT) in (select store_id, max(CT) from cte group by 1)		
)
select 	*
from MIN_SUM
join MAX_CNT using (store_id)

date() / ::date / cast ... as date
numeric()

select now()::date as x

select date(now())