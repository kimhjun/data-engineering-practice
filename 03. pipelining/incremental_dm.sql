CREATE TABLE Customers_staging (
    CustomerId int,
    CustomerName varchar(20),
    CustomerCountry varchar(10),
    LastUpdated timestamp
);

INSERT INTO Customers_staging
    VALUES(100, 'Jane', 'USA', '2019-05-01 7:01:10');
INSERT INTO Customers_staging
    VALUES(101, 'Bob', 'UK', '2020-01-15 13:05:31');
INSERT INTO Customers_staging
    VALUES(102, 'Miles', 'UK', '2020-01-29 9:12:00');
INSERT INTO Customers_staging
    VALUES(100, 'Jane', 'UK', '2020-06-20 8:15:34');


CREATE TABLE order_summary_daily_current (
    order_date date,
    order_country varchar(10),
    total_revenue numeric,
    order_count int
);

INSERT INTO order_summary_daily_current
(order_date, order_country, total_revenue, order_count)
WITH customers_current AS (
    SELECT CustomerId,
        MAX(LastUpdated) AS latest_update
    FROM Customers_staging
    GROUP BY CustomerId
)
SELECT
    o.OrderDate, cs.CustomerCountry, SUM(o.OrderTotal) as total_revenue, COUNT(o.OrderId) as order_count
FROM Orders o
INNER JOIN customers_current cc
    ON cc.CustomerId = o.CustomerId
INNER JOIN Customers_staging cs
    ON cs.CustomerId = cc.CustomerId
        AND cs.LastUpdated = cc.latest_update
GROUP BY o.OrderDate, cs.CustomerCountry