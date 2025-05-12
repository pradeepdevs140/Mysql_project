
-- 1. Create Database
CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- 2. Core Tables
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(100),
    phone BIGINT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE admins (
    admin_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100),
    password VARCHAR(100),
    role VARCHAR(50),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE shipping_address (
    address_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    address_line1 VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE categories (
    cat_id INT AUTO_INCREMENT PRIMARY KEY,
    cat_name VARCHAR(100) UNIQUE,
    description VARCHAR(200)
);

CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    description VARCHAR(200),
    price DECIMAL(10,2),
    stock INT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    cat_id INT,
    FOREIGN KEY (cat_id) REFERENCES categories(cat_id)
);

CREATE TABLE reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    product_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    total_amount DECIMAL(10,2),
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50),
    address_id INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (address_id) REFERENCES shipping_address(address_id)
);

CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    pay_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    amount DECIMAL(10,2),
    pay_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(100),
    payment_mode VARCHAR(50),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Insert Admins
INSERT INTO admins (username, password, role) VALUES
('admin1', 'adminpass', 'superuser'),
('staff1', 'staffpass', 'manager');

-- Insert Users
INSERT INTO users (name, email, password, phone) VALUES
('Alice Smith', 'alice@example.com', 'password123', 1234567890),
('Bob Johnson', 'bob@example.com', 'securepass', 2345678901),
('Clara Lee', 'clara@example.com', 'pass456', 3456789012),
('David Wright', 'david@example.com', 'david789', 4567890123);

-- Shipping Address
INSERT INTO shipping_address (user_id, address_line1, city, state, postal_code, country) VALUES
(1, '123 Main Street', 'New York', 'NY', '10001', 'USA'),
(2, '456 Oak Avenue', 'Chicago', 'IL', '60616', 'USA');

-- Categories
INSERT INTO categories (cat_name, description) VALUES
('Electronics', 'Devices and gadgets'),
('Books', 'Wide range of books'),
('Clothing', 'Apparel and accessories');

-- Products
INSERT INTO products (name, description, price, stock, cat_id) VALUES
('Smartphone', '128GB Android smartphone', 299.99, 50, 1),
('Laptop', 'Laptop with 16GB RAM', 799.99, 30, 1),
('Novel', 'Fiction novel', 15.99, 100, 2),
('T-shirt', 'Cotton T-shirt', 9.99, 150, 3),
('Headphones', 'Wireless headphones', 49.99, 80, 1);

-- Reviews
INSERT INTO reviews (user_id, product_id, rating, comment) VALUES
(1, 1, 5, 'Great phone!'),
(2, 2, 4, 'Good laptop for the price.'),
(1, 3, 3, 'Average story.');

-- Orders
INSERT INTO orders (user_id, total_amount, status, address_id) VALUES
(1, 315.98, 'Processing', 1),
(2, 15.99, 'Shipped', 2);

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 299.99),
(1, 3, 1, 15.99),
(2, 3, 1, 15.99);

-- Payments
INSERT INTO payments (order_id, amount, status, payment_mode) VALUES
(1, 315.98, 'Completed', 'Credit Card'),
(2, 15.99, 'Completed', 'PayPal');

-- Views
CREATE VIEW product_inventory AS
SELECT product_id, name, stock FROM products;

CREATE VIEW user_orders AS
SELECT o.order_id, u.name, o.status, o.total_amount
FROM orders o JOIN users u ON o.user_id = u.user_id;

-- Stored Procedure
DELIMITER //
CREATE PROCEDURE GetUserReviews(IN uid INT)
BEGIN
    SELECT r.review_id, p.name, r.rating, r.comment
    FROM reviews r
    JOIN products p ON r.product_id = p.product_id
    WHERE r.user_id = uid;
END //
DELIMITER ;

-- Trigger to adjust stock
DELIMITER //
CREATE TRIGGER trg_update_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products SET stock = stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END //
DELIMITER ;

-- Constraints
ALTER TABLE products
ADD CONSTRAINT chk_price CHECK (price >= 0),
ADD CONSTRAINT chk_stock CHECK (stock >= 0);

ALTER TABLE order_items
ADD CONSTRAINT chk_quantity CHECK (quantity > 0);

-- Indexes
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_order_status ON orders(status);

-- Useful Queries
-- Revenue by product
SELECT p.name, SUM(oi.quantity * oi.price) AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id;

-- Users with most orders
SELECT u.name, COUNT(o.order_id) AS total_orders
FROM users u
JOIN orders o ON u.user_id = o.user_id
GROUP BY u.user_id
ORDER BY total_orders DESC;

-- Total revenue
SELECT SUM(amount) AS Total_Revenue FROM payments;

-- Start Transaction
START TRANSACTION;
UPDATE products SET stock = stock - 1 WHERE product_id = 1;
INSERT INTO orders (user_id, total_amount, status, address_id) VALUES (1, 299.99, 'Processing', 1);
COMMIT;
-- ROLLBACK; -- Uncomment to roll back instead of committing
