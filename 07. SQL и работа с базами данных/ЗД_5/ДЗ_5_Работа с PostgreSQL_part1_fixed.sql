--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.
select  p.customer_id, p.payment_id, p.payment_date, row_number() over(order by p.payment_date)
from payment p

select  p.customer_id, p.payment_id, p.payment_date, row_number() over(partition by p.customer_id order by p.payment_date)
from payment p

select p.customer_id, p.payment_id, p.payment_date, sum(p.amount) over (partition by p.customer_id order by p.payment_date, p.amount)
from payment p

select p.customer_id, p.payment_id, p.payment_date, p.amount, dense_rank() over(partition by p.customer_id order by p.amount desc)
from payment p 

--в один запрос
select  p.customer_id, p.payment_id, p.payment_date, p.amount, row_number() over(order by p.payment_date),
	row_number() over(partition by p.customer_id order by p.payment_date),
	sum(p.amount) over (partition by p.customer_id order by p.payment_date, p.amount),
	dense_rank() over(partition by p.customer_id order by p.amount desc)
from payment p


--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.
select p.customer_id, p.payment_id, p.payment_date, p.amount, 
	   lag(p.amount,1,0) over(partition by p.customer_id order by p.payment_date) last_amount
from payment p 


--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select p.customer_id, p.payment_id, p.payment_date, p.amount,
	   p.amount - lead(p.amount,1,0) over(partition by p.customer_id order by p.payment_date) difference
from payment p 


--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select customer_id, payment_id, payment_date, amount
from ( 
	select *, last_value(payment_id) over (partition by customer_id)
		from(
		select *
		from payment 
		order by customer_id, payment_date))
where last_value = payment_id




--последняя рента через max
select *--r.customer_id, inventory_id, r.rental_date
from rental r
where (r.customer_id, r.rental_date) in
	(select customer_id, max(rental_date)
	from rental  
	group by 1)
order by r.customer_id 


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.




--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку




--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм








