CREATE TABLE dimDate (
	date_key integer NOT NULL PRIMARY KEY,
	date date NOT NULL,
	year smallint NOT NULL,
	quarter smallint NOT NULL,
	month smallint NOT NULL,
	day smallint NOT NULL,
	week smallint NOT NULL,
	is_weekend boolean
);

CREATE TABLE dimCustomer (
	customer_key serial PRIMARY KEY,
	customer_id smallint NOT NULL,
	first_name varchar(45) NOT NULL,
	last_name varchar(45) NOT NULL,
	email varchar(50),
	address varchar(50) NOT NULL,
	address2 varchar(50),
	district varchar(20) NOT NULL,
	city varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	postal_code varchar(10),
	phone varchar(20) NOT NULL,
	active smallint NOT NULL,
	create_date timestamp NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL
);

CREATE TABLE dimMovie (
	movie_key serial PRIMARY KEY,
	film_id smallint NOT NULL,
	title varchar(255) NOT NULL,
	description text,
	release_year year,
	language varchar(20) NOT NULL,
	original_language varchar(20),
	rental_duration smallint NOT NULL,
	length smallint NOT NULL,
	ratings varchar(5) NOT NULL,
	special_features varchar(60) NOT NULL
);

CREATE TABLE dimStore (
	store_key serial PRIMARY KEY,
	store_id smallint NOT NULL,
	address varchar(50) NOT NULL,
	address2 varchar(50),
	district varchar(20) NOT NULL,
	city varchar(50) NOT NULL,
	country varchar(50) NOT NULL,
	postal_code varchar(10),
	manager_first_name varchar(45) NOT NULL,
	manager_last_name varchar(45) NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL
);

INSERT INTO dimDate (date_key, date, year, quarter, month, day, week, is_weekend)
SELECT DISTINCT
	(to_char(payment_date::DATE, 'yyyyMMDD')::integer) AS date_key,
	date(payment_date) AS date,
	extract(year FROM payment_date) AS year,
	extract(quarter FROM payment_date) AS quarter,
	extract(month FROM payment_date) AS month,
	extract(day FROM payment_date) AS day,
	extract(week FROM payment_date) AS week,
	CASE WHEN extract(ISODOW FROM payment_date) IN (6, 7) THEN
		TRUE
	ELSE
		FALSE
	END
FROM
	payment;


INSERT INTO dimCustomer (customer_key, customer_id, first_name, last_name, email, address, address2, district, city, country, postal_code,
						phone, active, create_date, start_date, end_date)
SELECT c.customer_id as customer_key,
	   c.customer_id,
	   c.first_name,
	   c.last_name,
	   c.email,
	   a.address as address,
	   a.address2 as address2,
	   a.district as district,
	   ci.city as city,
	   co.country as country,
	   a.postal_code as postal_code,
	   a.phone as phone,
	   c.active as active,
	   c.create_date,
	   now() as start_date,
	   now() as end_date
FROM customer c
JOIN address a ON (c.address_id=a.address_id)
JOIN city ci ON (a.city_id=ci.city_id)
JOIN country co ON (ci.country_id=co.country_id);


INSERT INTO dimStore (store_key, store_id, address, address2, district, city, country, postal_code,
						manager_first_name, manager_last_name, start_date, end_date)
SELECT s.store_id as store_key,
	   s.store_id,
		a.address as address,
	   a.address2 as address2,
	   a.district as district,
	   ci.city as city,
	   co.country as country,
	   a.postal_code as postal_code,
	   st.first_name as manager_first_name,
	   st.last_name as manager_last_name,
	   now() as start_date,
	   now() as end_date
FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city ci ON (a.city_id=ci.city_id)
JOIN country co ON (ci.country_id=co.country_id)
JOIN staff st ON (s.store_id=st.store_id);

INSERT INTO dimMovie (movie_key, film_id, title, description, release_year, language, rental_duration, length, ratings, special_features)
SELECT f.film_id as movie_key,
	   f.film_id,
	   f.title,
	   f.description,
	   f.release_year,
	   l.name as language,
	   f.rental_duration,
	   f.length,
	   f.rating,
	   f.special_features
FROM film f
JOIN language l ON f.language_id = l.language_id
;


CREATE TABLE factSales
(
	sales_key SERIAL PRIMARY KEY,
	date_key integer REFERENCES dimDate (date_key),
	customer_key integer REFERENCES dimCustomer (customer_key),
	movie_key integer REFERENCES dimMovie (movie_key),
	store_key integer REFERENCES dimStore (store_key),
	sales_amount numeric
);


INSERT INTO factSales (date_key, customer_key, movie_key, store_key, sales_amount)
SELECT
	TO_CHAR(payment_date :: DATE, 'yyyyMMDD')::integer AS date_key,
	p.customer_id as customer_key,
	i.film_id as movie_key,
	i.store_id as store_key,
	p.amount as sales_amount
FROM payment p
JOIN rental r ON p.rental_id = r.rental_id
JOIN inventory i ON r.inventory_id = i.inventory_id;