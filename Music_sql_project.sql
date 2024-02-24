--Q1.who is the seniour most employe based on job title?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

--Q2. Which countries have the most invoices?
SELECT COUNT(*) as count_of_countries, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY count_of_countries DESC;

--Q3.what are top 3 values of total invoices?
SELECT * FROM invoice
ORDER BY total DESC
LIMIT 3;

/*Q4.which city has the best customers?
we would like to thow a promotional music festival in the city
we made the most money. write  a query that returns one city that
has the highest sum of invoice totals. return both the city
name and sum of all invoice totals */
SELECT billing_city as city, SUM(total) AS sum_of_invoice_total
FROM invoice
GROUP BY city
ORDER BY sum_of_invoice_total DESC
LIMIT 1;

/*Q5. who is the best customer?the customer who has spent the most
money will be declared the best customer. Write a query that returns
the person who has spend the most money.*/
SELECT customer.customer_id,customer.first_name,customer.last_name,
customer.city, customer.address, sum(invoice.total) as total_money_spend
FROM customer join invoice
on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total_money_spend desc
limit 1;

/*Q6.write query to return the email, first name, last name, & genre
of all rock music listeners. Return your list ordered alphabatically
by email starting with A*/
select distinct  customer.email,customer.first_name,
customer.last_name
from customer join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
order by email;

/*Q7. let's invite the artists who have written the most rock music
in our dataset. write query that returns the artist name and total
track count of the top rock bands*/
select artist.name, count(track.name) as track_count
from artist join album on artist.artist_id = album.artist_id
join track on album.album_id = track.album_id
join genre on track.genre_id = genre.genre_id
where genre.name like 'Rock'
group by artist.name
order by track_count desc
limit 10;

/*Q8.Return all the track names that habve a song lwngth longer than
the average song length. Return the name and milliseconds for each
track.order by the song length with the longest songs listed first*/
select track.name, track.milliseconds as song_length from track where 
(select avg(track.milliseconds) as avg_song_length from track)
< track.milliseconds
order by song_length desc;

/*Q9.find how much amount spent by each customer on artist? write query
to return customer name, artist name and total spent*/
select distinct customer.customer_id, customer.first_name, customer.last_name, artist.name,
sum(invoice_line.unit_price*invoice_line.quantity) as total_earned
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join artist on album.artist_id = artist.artist_id
group by customer.customer_id,customer.first_name, customer.last_name, artist.name
order by total_earned desc;

/*Q10.We want to find out the most popular music genre for each country.
We determine the most popular genre as the genre with the highest amount
of purchases. Write a query that returns each country along with the
top Genre. For countries where the maximum number of purchases is shared
return all genres*/
with popular_genre as
(
	select count(invoice_line.quantity) as amount_of_purchases,
	genre.genre_id, genre.name, invoice.billing_country as country,
	row_number() over(partition by invoice.billing_country order by
					 count(invoice_line.quantity) desc) as RowNo
	from invoice
	join invoice_line on invoice.invoice_id= invoice_line.invoice_id
	join track on invoice_line.track_id = track.track_id
	join genre on track.genre_id = genre.genre_id
	group by 2,3,4
	order by 4 asc, 1 desc 
)
select * from popular_genre where RowNo <= 1;

/*Q11.Write a query that determines the customer
that has spent the most on music for each country. 
write a query that returns the country along with the top customer
and how much they spent. for countries where the top amount spent
is shared, provide all customers who spent this amount.*/

with recursive
	customer_with_country as (
		select customer.customer_id, customer.first_name, customer.last_name,
		invoice.billing_country, sum(invoice.total) as total_spending
		from invoice
		join customer on invoice.customer_id= customer.customer_id
		group by 1,2,3,4
		order by 2,3 desc
	),
	countries_max_spending as (
		select billing_country, max(total_spending) as max_spending
		from customer_with_country
		group by billing_country
	)
select customer_with_country.billing_country,
customer_with_country.total_spending, customer_with_country.first_name,
customer_with_country.last_name
from customer_with_country
join countries_max_spending on
customer_with_country.billing_country= countries_max_spending.billing_country
where customer_with_country.total_spending= countries_max_spending.max_spending
order by 1;