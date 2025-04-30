create database ecommerce_db;
use ecommerce_db;
create table users ( user_id int auto_increment primary key, name varchar(100), email varchar(100), password varchar(100), phone int(10) , created_at datetime default current_timestamp);
create table categories ( cat_id int auto_increment primary key , cat_name varchar(100), description varchar(200));
create table products( product_id int auto_increment primary key , name varchar(100), d9escription varchar(200), price decimal(10,2) , stock int(10), created_at datetime default current_timestamp ,cat_id int ,foreign key( cat_id) references  categories(cat_id) );
create table orders(order_id int auto_increment primary key , user_id int , foreign key(user_id) references users(user_id),total_amount decimal(10,2), order_date datetime default current_timestamp, status varchar(50) );
create table order_items( order_item_id int auto_increment primary key , order_id int , foreign key(order_id) references orders(order_id) , product_id int , foreign key(product_id) references products(product_id) , quality int(100) , price decimal(10,2));
create table payments(pay_id int auto_increment primary key , order_id int , foreign key(order_id) references orders(order_id), amount decimal(10,2), pay_date datetime default current_timestamp, status varchar(100), payment_mode varchar(50));