CREATE TABLE order_summary_daily_pit
(
    order_date date,
    order_country varchar(10),
    total_revenue numeric,
    order_count int
);

INSERT INTO order_summary_daily_pit
(order_date, order_country, total_revenue, order_count)
WITH customer_pit as (
    SELECT
        cs.CustomerId,
        o.OrderId,
        MAX(cs.LastUpdated) AS max_updated_date
    FROM Orders o
    INNER JOIN Customers_staging cs
        ON o.CustomerId = cs.CustomerId
            AND cs.LastUpdated <= o.OrderDate
    GROUP BY cs.CustomerId, o.OrderId
)
SELECT
    o.OrderDate as order_date,
    cs.CustomerCountry as customer_country,
    SUM(o.OrderTotal) as total_revenue,
    COUNT(o.OrderId) as order_count
FROM Orders o
INNER JOIN customer_pit cp
    ON cp.CustomerId = o.CustomerId
        AND cp.OrderId = o.OrderId
INNER JOIN Customers_staging cs
    ON cs.CustomerId = cp.CustomerId
        AND cs.LastUpdated = cp.max_updated_date
GROUP BY o.OrderDate, cs.CustomerCountry;