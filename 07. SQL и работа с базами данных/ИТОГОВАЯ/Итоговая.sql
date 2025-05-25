select * from aircrafts a 

select * from airports  

select * from boarding_passes bp 

select * from bookings b 

select * from flights f 

select * from seats s 

select * from tickets

-------------------------------ЗАДАНИЯ-----------------------------------

--1. Выведите название самолетов, которые имеют менее 50 посадочных мест?
select a.model, t.count "number of seats"
from (
	select aircraft_code, count(*) 
	from seats s 
	group by aircraft_code
	having count(*) < 50) t
join aircrafts a using (aircraft_code) 



--2. Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

---------два столбца--------

select  date_trunc('month', b.book_date)::date,
		round((sum(b.total_amount) / lag(sum(b.total_amount)) over (order by date_trunc('month', b.book_date)) - 1) * 100, 2) as  "% Изменения"
from bookings b
group by date_trunc('month', b.book_date)

---------четыре столбца--------
select  date_trunc('month', b.book_date)::date, sum(b.total_amount) as "Текущий месяц",
		lag(sum(b.total_amount)) over (order by date_trunc('month', b.book_date)) as "Предыдущий месяц",
		round((sum(b.total_amount) / lag(sum(b.total_amount)) over (order by date_trunc('month', b.book_date)) - 1) * 100, 2) as  "% Изменения"
from bookings b
group by date_trunc('month', b.book_date)



--3. Выведите названия самолетов не имеющих бизнес - класс. Решение должно быть через функцию array_agg
-- вывожу только один столбец 	

select a.model
from (
	select aircraft_code, array_agg(fare_conditions) 
	from seats s 
	group by s.aircraft_code
	having not 'Business' = any(array_agg(fare_conditions)))
join aircrafts a using (aircraft_code)
	
/*5. Найдите процентное соотношение перелетов по маршрутам от общего количества перелетов. 
Выведите в результат названия аэропортов и процентное отношение.
Решение должно быть через оконную функцию.*/ 
--flight_id -- рейс, перелет. --33121  

--explain analyze
select a.airport_name "Аэропорт А", a2.airport_name "Аэропорт Б", t_1."% change"
from (
	select f.departure_airport, f.arrival_airport, count(*) * 100. / sum(count(*)) over() "% change"
	from flights f
	group by f.departure_airport, f.arrival_airport) t_1
join airports a on a.airport_code = t_1.departure_airport
join airports a2 on a2.airport_code = t_1.arrival_airport
order by a.airport_name, a2.airport_name



--6. Выведите количество пассажиров по каждому коду сотового оператора, если учесть, что код оператора - это три символа после +7
--explain analyze 
select substring(t.contact_data->>'phone', 3, 3) "Код", count(*) "Количество пассажиров"   
from tickets t 
group by substring(t.contact_data->>'phone', 3, 3)


/*7. Классифицируйте финансовые обороты (сумма стоимости перелетов) по маршрутам:
 До 50 млн - low
 От 50 млн включительно до 150 млн - middle
 От 150 млн включительно - high
 Выведите в результат количество маршрутов в каждом полученном классе
*/
-- 1 056 621, 1 045 726, 10 895 -  null tf.amount

--explain analyze 
select t."Сlass", count(*) "Количество"
from ( 
	select f.departure_airport , f.arrival_airport, sum(tf.amount),
		case 
			when sum(tf.amount) < 50000000 then 'low'
			when sum(tf.amount) >= 50000000 and sum(tf.amount) < 150000000 then 'middle'
			when sum(tf.amount) >= 150000000 then 'high'
	 	end "Сlass" 
	from flights f
	join ticket_flights tf using (flight_id)
	group by f.departure_airport , f.arrival_airport) as t
group by t."Сlass"


--8. Вычислите медиану стоимости перелетов, медиану размера бронирования и отношение медианы бронирования к медиане стоимости перелетов, округленной до сотых

explain analyze
select percentile_cont(0.5) within group(order by b.total_amount) as median_bookings, 
	   t.median_ticket_flights, 
	  round((percentile_cont(0.5) within group(order by b.total_amount) / t.median_ticket_flights)::numeric, 2) as ratio
from bookings b, 
	(select percentile_cont(0.5) within group(order by amount) as median_ticket_flights
	from ticket_flights) t 
GROUP by  t.median_ticket_flights

---------------ОТВЕТ ЭКСПЕРТА--------------
--explain analyze
select t2.mediana_bookings, t1.mediana_tickets, round(t2.mediana_bookings /  t1.mediana_tickets, 2)
from (select percentile_cont(0.5) within group(order by amount)::numeric mediana_tickets from ticket_flights) t1,
(select percentile_cont(0.5) within group(order by total_amount)::numeric mediana_bookings from bookings) t2
 


select percentile_cont(0.5) within group(order by tf.amount)
from ticket_flights tf 
 
select percentile_cont(0.5) within group(order by b.total_amount)
from bookings b 

--4. Вывести накопительный итог количества мест в самолетах по каждому аэропорту на каждый день, учитывая только те самолеты, 
--которые летали пустыми и только те дни, где из одного аэропорта таких самолетов вылетало более одного.
--В результате должны быть код аэропорта, дата, количество пустых мест в самолете и накопительный итог.



select a.model, t.count
from 
	(select s.aircraft_code, count(s.fare_conditions)
	from seats s
	group by s.aircraft_code) t
join aircrafts a on a.aircraft_code = t.aircraft_code 
order by t.count

--2 546 170
select f.flight_id, f.aircraft_code, tf.ticket_no
from flights f 
left join ticket_flights tf on tf.flight_id = f.flight_id 
where tf.ticket_no is null


select s.aircraft_code, count(f.flight_id) --s.seat_no, tf.ticket_no 
from seats s 
join aircrafts a on a.aircraft_code = s.aircraft_code 
join flights f on f.aircraft_code = a.aircraft_code
left join ticket_flights tf on tf.flight_id = f.flight_id 
where tf.ticket_no  is  null
group by s.aircraft_code, f.flight_id