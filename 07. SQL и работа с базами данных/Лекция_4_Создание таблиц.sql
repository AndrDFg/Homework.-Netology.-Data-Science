--MDL - операторы которые отвечают за манипуляциями данных в таблице
select 
insert --внесение новых данных
update --изменения уже существующих данных
delete --удаление данных

--DLL - 
create --создать сущность
alter -- изменить сущность
drop -- удалить сущность

======================== Создание таблиц ========================

https://dbdiagram.io/, https://sqldbm.com, https://pgmodeler.io

create database название

create schema lecture_4

set search_path to lecture_4

1. Создайте таблицу "автор" с полями:
- id 
- имя
- псевдоним (может не быть)
- дата рождения
- город рождения
- родной язык
* Используйте 
    CREATE TABLE table_name (
        column_name TYPE column_constraint,
    );
* для id подойдет serial, ограничение primary key
* Имя и дата рождения - not null
* город и язык - внешние ключи

create table author (
	author_id serial primary key,
	author_name varchar(150) not null,
	nick_name varchar(75),
	born_date date not null check(born_date <= current_date and date_part('year', born_date) >= 1600),
	city_id int2 not null references city(city_id),
	--language_id int2 not null references language(language_id),
	created_at timestamp not null default current_timestamp,
	created_user varchar(64) not null default current_user, 
	deleted boolean not null default false--,
	--deleted int2 not null check(deleted in (0, 1)) default 0
)

select 
from author
where deleted is true

p_id	fio		city	product		category	amount	date
1		ИИИ		Москва	утюг		техника
--2		ИИИ		Москва	утюг		игрушка

select 
from (
	select id, name, id, name, id, name
	from a 
	join b 
	join c) 

serial = integer + sequence + default nextval(sequence)

uuid

create table ... (
	id uuid primary key default gen_random_uuid()
)

create table ... (
	id varchar(24) primary key 
)

varchar(100)
varchar(8000)
25 35 35

select gen_random_uuid()

2f605139-13ec-4a75-87f4-abd938d00415
d9feffdc-8b14-4338-a9f0-7d72f52eb03b

create extension "uuid-ossp"

select uuid_generate_v1()

e95fef44-55a5-11ef-8ad5-cf3982e9507e
eb784f38-55a5-11ef-8ad6-8304855cb514
ed213750-55a5-11ef-8ad7-03725eb2968a

1*  Создайте таблицы "Язык", "Город", "Страна".
* для id подойдет serial, ограничение primary key
* названия - not null и проверка на уникальность

create table city (
	city_id serial2 primary key,
	city_name varchar(75) not null, 
	country_id int2 not null references country(country_id)
)

create table country (
	country_id serial2 primary key,
	country_name varchar(75) not null unique)
	
create table language (
	language_id serial2 primary key,
	language_name varchar(75) not null unique)


== Отношения / связи ==
А		Б
один к одному  		Б является атрибутом А
один ко многим		А и Б два отдельных справочника
многие ко многим	в реляционной модели не существует, реализуется через два отношения один 
					ко многим А-В и В-Б
					
create table author (
	author_id 
	author_fio
	born_date
)

create table language (
	language_id
)

create table author_language (
	author_id int references author(author_id),
	language_id int references language(language_id),
	primary key (author_id, language_id)
)

1	1
1	2
2	1	
2	2

======================== Заполнение таблицы ========================

2. Вставьте данные в таблицу с языками:
'Русский', 'Французский', 'Японский'
* Можно вставлять несколько строк одновременно:
    INSERT INTO table (column1, column2, …)
    VALUES
     (value1, value2, …),
     (value1, value2, …) ,...;

insert into "language" (language_name)
values ('Русский'), ('Французский'), ('Японский')

select * from "language" l

insert into "language" 
values (4, 'Монгольский')

SQL Error [428C9]: ОШИБКА: в столбец "language_id" можно вставить только значение по умолчанию
  Подробности: Столбец "language_id" является столбцом идентификации со свойством GENERATED ALWAYS.
  Подсказка: Для переопределения укажите OVERRIDING SYSTEM VALUE.
  
insert into "language" 
overriding system value
values (4, 'Монгольский')

SQL Error [22P02]: ОШИБКА: неверный синтаксис для типа smallint: "Монгольский"

insert into "language" (language_name)
values ('Канадский')

SQL Error [23505]: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "language_pkey"
  Подробности: Ключ "(language_id)=(4)" уже существует.
  
-- демонстрация работы счетчика и сброс счетчика
alter sequence language_language_id_seq restart with 789 

insert into "language" (language_name)
values ('Кимтайский')

drop table language

create table language (
	language_id int2 primary key generated always as identity,
	language_name varchar(75) not null unique)	
	
generated always as identity  -- в ручную нельзя вести индификатор, возможно только через overriding system values

generated default as identity -- в ручную внестиможно

--Работает начиная с 13 версии PostgreSQL - stored

create table test_2 (
	author_id int2 primary key generated always as identity,
	last_name varchar(30) not null,
	first_name varchar(20) not null, 
	middle_name varchar(30) not null,
	fio varchar(80) generated always as (initcap(last_name || ' ' || first_name || ' ' || middle_name)) stored, -- автоматическая генерация на основании др.столбцо
	qty numeric,
	cost_per_one numeric,
	total_cost numeric generated always as (round(qty * cost_per_one / 1.2, 2)) stored) -- stored - хранить вычесляемые  данные на жест.диске как обычные данные.
	
insert into test_2 (last_name, first_name, middle_name, qty, cost_per_one)
values ('ИВАНОВ', 'иван', 'ИвАнОВИч', 5, 1000)
	
select * from test_2

2.1 Вставьте даные в таблицу со странами из таблиц country базы dvd-rental:

select country_id, country
from public.country 

select * from country c

insert into country (country_id, country_name)
select country_id, country
from public.country 

alter sequence country_country_id_seq restart with 110   --рестар счётчика с 110 поз таблицы country, столбца country_id т.к 109 записей есть, начинаем со 110

2.2 Вставьте данные в таблицу с городами соблюдая связи из таблиц city базы dvd-rental:

select * from city

insert into city (city_name, country_id) --city новая таб со столбцами city_name, country_id) 
select city, country_id -- источник столбцы другой таблицы. city, country_id - столбцы старой табл. 
from public.city c -- public.city c - данные из старой таблицы

2.3 Вставьте данные в таблицу с авторами, идентификаторы языков и городов оставьте пустыми.
Жюль Верн, 08.02.1828
Михаил Лермонтов, 03.10.1814
Харуки Мураками, 12.01.1949

insert into author (author_name, nick_name, born_date, city_id, created_user)
values ('Жюль Верн', null, '08.02.1828', 34, 'nikolay'),
('Михаил Лермонтов', 'Диарбекир', '03.10.1814', 444, default),
('Харуки Мураками', null, '12.01.1949', 156, default)

select *
from author a

```sql
select 
.... 
```

======================== Модификация таблицы ========================

3. Добавьте поле "идентификатор языка" в таблицу с авторами
* ALTER TABLE table_name 
  ADD COLUMN new_column_name TYPE;

select * from author a
 
-- добавление нового столбца
alter table author add column language_id int2

-- удаление столбца
alter table author drop column language_id

-- добавление ограничения not null
alter table author alter column language_id set not null
 
-- удаление ограничения not null
alter table author alter column language_id drop not null

-- добавление ограничения unique
alter table author add constraint language_id_unique unique (language_id)

-- удаление ограничения unique
alter table author drop constraint language_id_unique

-- изменение типа данных столбца
alter table author alter column language_id type varchar(150)

alter table author alter column language_id type int2 using (language_id::int2)

-- добавление ограничения внешнего ключа
alter table author add constraint author_language_pkey foreign key (language_id) references language(language_id)

alter table author drop constraint author_language_pkey 

alter table author add constraint author_language_fkey foreign key (language_id) references language(language_id)

 ======================== Модификация данных ========================

4. Обновите данные, проставив корректное языки писателям:
Жюль Габриэль Верн - Французский
Михаил Юрьевич Лермонтов - Российский
Харуки Мураками - Японский

select * from author a

1	Жюль Верн
2	Михаил Лермонтов
3	Харуки Мураками

select * from "language" l

1	Русский
2	Французский
3	Японский

update author
set language_id = 2
where author_id = 1

update author
set language_id = 3

update author
set language_id = 1, nick_name = 'какое-то значение', city_id = 555
where author_id = 2

update author
set language_id = 1, nick_name = 'какое-то значение', city_id = 555
where city_id in (select city_id from city where country_id = 1)

 ======================== Удаление данных ========================
 
5. Удалите Лермонтова

delete from author
where author_id = 2

delete from city
where city_id = 156

delete from author -- в некоторых базах можно востановить данные, truncate - востановить в любой базе невозможно 

truncate city cascade  -- truncate - усечение таблицы, адаление всех записей как delete, но без возможности востановления 

--cascade - Он устраняет связанные записи в дочерней таблице (внешние ключи) при удалении родительской записи, 
--исключая таким образом риск оставить в базе данных «осиротевшие» записи, 
--которые могут искажать результаты анализа данных и нарушать работу приложения.

5.1 Удалите все страны

drop table country cascade -- удаление родителькой табл country со всеми связаннми ключами в дочерних табл 

drop schema lecture_4 cascade -- удаление всей схемы!!!

========================================================================================================================
Поведение FK по умолчанию
Принцип работы cascaded

--РОДИТЕЛЬСКАЯ
create table country (
	country_id serial2 primary key,
	country_name varchar(75) not null unique)
	 
insert into country (country_id, country_name)
select country_id, country
from public.country 

--ДОЧЕРНЯЯ
create table city (
	city_id serial2 primary key,
	city_name varchar(75) not null, 
	country_id int2 default 3 references country(country_id) on update set default on delete set null 
															 --(on update cascade on delete cascade)
															 -- запись для возможности удаления id родительской табл
)                                                               

cascade 
restrict 
no action 
set default 
set null

insert into city (city_name, country_id)
select city, country_id
from public.city c

select * from country

select * from city

drop table country cascade

drop table city cascade

cascade

drop table country cascade

truncate country cascade

delete from country
where country_id = 1

update country
set country_id = 5000
where country_id = 2

drop cascade при удалении род табл, данные в доч. табл сохранились, удалится FK у дочерней таблицы!!!
truncate cascade при удалении род табл данные удаляются и в доч.табл, но сохранится FK (внешн кл.)
delete cascade данные удалены сохранится FK

========================================================================================================================

