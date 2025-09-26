CREATE DATABASE ECOMMERCE;
USE ECOMMERCE;

--Here I have imported dataset thata contains ecommerce_dataset_10000 table--

SELECT * FROM ecommerce_dataset_10000;

SELECT COUNT(*) AS TOTAL_ROWS FROM ecommerce_dataset_10000;
SELECT COUNT(DISTINCT customer_id) AS UNIQUE_CUSTOMER FROM ecommerce_dataset_10000;

SELECT first_name, last_name, country
FROM ecommerce_dataset_10000
WHERE country = 'USA'
ORDER BY last_name;

-- Number of customers per country
SELECT country, COUNT(*) AS total_customers
FROM ecommerce_dataset_10000
GROUP BY country
ORDER BY total_customers DESC;




-- Created four more tables(Customers,PRoducts, orders and orderdetais)

CREATE TABLE Customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    country VARCHAR(50)
);
INSERT INTO Customers (first_name, last_name, email, country) VALUES
('John', 'Doe', 'john@example.com', 'USA'),
('Jane', 'Smith', 'jane@example.com', 'UK'),
('Michael', 'Brown', 'michael@example.com', 'USA'),
('Emily', 'Davis', 'emily@example.com', 'Canada'),
('Robert', 'Johnson', 'robert@example.com', 'USA');

CREATE TABLE Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2)
);
INSERT INTO Products (product_name, category, price) VALUES
('Laptop', 'Electronics', 800.00),
('Phone', 'Electronics', 500.00),
('Book', 'Education', 20.00),
('Headphones', 'Electronics', 150.00),
('Notebook', 'Education', 10.00);

CREATE TABLE Orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
INSERT INTO Orders (customer_id, order_date, total_amount) VALUES
(1, '2025-09-01', 1320.00),
(2, '2025-09-02', 500.00),
(3, '2025-09-05', 170.00),
(4, '2025-09-06', 30.00),
(5, '2025-09-07', 800.00);

CREATE TABLE OrderDetails (
    order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 800.00),   
(1, 2, 1, 500.00),   
(1, 3, 1, 20.00),    
(2, 2, 1, 500.00),   
(3, 4, 1, 150.00),   
(3, 3, 1, 20.00),    
(4, 5, 3, 10.00),    
(5, 1, 1, 800.00); 



CREATE INDEX idx_orders_customer_date  
ON Orders(customer_id, order_date);			--This tells the database to create a new index on the Orders




-- Orders with customer and product details
SELECT o.order_id, c.first_name, c.last_name, p.product_name, od.quantity, od.unit_price
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
JOIN Products p ON od.product_id = p.product_id;



-- Customers who spent more than $500
SELECT first_name, last_name
FROM Customers
WHERE customer_id IN (
    SELECT o.customer_id
    FROM Orders o
    JOIN OrderDetails od ON o.order_id = od.order_id
    GROUP BY o.customer_id
    HAVING SUM(od.quantity * od.unit_price) > 500
);



CREATE VIEW Customer_Sales AS
SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
       SUM(od.quantity * od.unit_price) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
JOIN OrderDetails od ON o.order_id = od.order_id
GROUP BY c.customer_id;



SELECT 
    o.order_id, 
    c.first_name, 
    c.last_name, 
    p.product_name, 
    od.quantity, 
    od.unit_price,
    (od.quantity * od.unit_price) AS total_price
FROM OrderDetails od
INNER JOIN Orders o ON od.order_id = o.order_id
INNER JOIN Customers c ON o.customer_id = c.customer_id
INNER JOIN Products p ON od.product_id = p.product_id
ORDER BY o.order_id;



SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    o.order_id, 
    o.total_amount
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
ORDER BY c.customer_id;



SELECT 
    o.order_id, 
    o.total_amount, 
    c.first_name, 
    c.last_name
FROM Customers c
RIGHT JOIN Orders o ON c.customer_id = o.customer_id
ORDER BY o.order_id;



SELECT 
    p.product_name, 
    SUM(od.quantity * od.unit_price) AS total_revenue
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;



SELECT 
    c.first_name, 
    c.last_name, 
    AVG(o.total_amount) AS avg_order_value
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY avg_order_value DESC;



--Cretaed Trigger
DELIMITER $$
CREATE TRIGGER trg_update_order_total
AFTER INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET total_amount = (
        SELECT SUM(quantity * unit_price) 
        FROM OrderDetails 
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$
DELIMITER ;

INSERT INTO OrderDetails (order_id, product_id, quantity, unit_price) VALUES
(2, 3, 2, 20.00);
SELECT * FROM Orders WHERE order_id = 2;



--cretaed Stored Procedure
DELIMITER $$

CREATE PROCEDURE GetCustomerTotalSpending(IN cust_id INT)
BEGIN
    SELECT c.first_name, c.last_name, SUM(od.quantity * od.unit_price) AS total_spent
    FROM Customers c
    JOIN Orders o ON c.customer_id = o.customer_id
    JOIN OrderDetails od ON o.order_id = od.order_id
    WHERE c.customer_id = cust_id
    GROUP BY c.customer_id;
END$$

DELIMITER ;

CALL GetCustomerTotalSpending(1);
CALL GetCustomerTotalSpending(3);



