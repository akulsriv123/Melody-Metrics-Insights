/* Q1: Who is the senior most employee based on job title? */

SELECT * FROM employee
ORDER BY levels DESC
limit 1;


/* Q2: Which countries have the most invoices? */

SELECT COUNT(*) AS p, billing_country FROM invoice
GROUP BY billing_country
ORDER BY p DESC;


/* Q3: What are the top 3 values of total invoice? */

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals. */

SELECT billing_city, SUM(total) as total_invoice FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money. */ 


SELECT c.customer_id, c.first_name, c.last_name, SUM(i.total) AS total_spending FROM customer AS c 
JOIN invoice AS i
ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spending DESC
LIMIT 1;



/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */


SELECT DISTINCT customer.email, customer.first_name, customer.last_name, genre.name 
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id 
WHERE genre.name = 'Rock'
ORDER BY email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */


SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS track_count FROM track
JOIN album ON track.album_id = album.album_id
JOIN artist ON album.artist_id = artist.artist_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.artist_id
ORDER BY track_count DESC
LIMIT 10;


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length FROM track)
ORDER BY milliseconds DESC;


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT c.customer_id, c.first_name, c.last_name, ar.name AS artist_name, SUM(il.unit_price*il.quantity) AS total_spent FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS tr ON il.track_id = tr.track_id
JOIN album AS a ON tr.album_id = a.album_id
JOIN artist AS ar ON a.artist_id = ar.artist_id
GROUP BY 1, 2, 3, 4
ORDER BY total_spent DESC;


/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */


WITH popular_genre AS (
	SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.genre_id, genre.name AS category, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
	FROM invoice_line
	JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
	JOIN customer ON invoice.customer_id = customer.customer_id
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN genre ON track.genre_id = genre.genre_id
	GROUP BY 2, 3, 4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre
WHERE RowNo <= 1;


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH customer_with_country AS 
(
	SELECT customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country, SUM(total) AS total_spending,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM invoice
	JOIN customer ON customer.customer_id = invoice.customer_id
	GROUP BY 1, 2, 3, 4
	ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM customer_with_country 
WHERE RowNo <= 1
	


