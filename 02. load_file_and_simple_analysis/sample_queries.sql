SELECT min(payment_date) min_payment,
	   max(payment_date) max_payment
FROM payment;

SELECT f.title, sum(p.amount) as revenue from payment p
JOIN rental r ON p.rental_id=r.rental_id
JOIN inventory i ON r.inventory_id=i.inventory_id
JOIN film f ON i.film_id=f.film_id
GROUP BY f.title ORDER BY revenue DESC;