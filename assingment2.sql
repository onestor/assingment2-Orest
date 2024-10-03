CREATE DATABASE IF NOT EXISTS opt_db;
USE opt_db;

CREATE TABLE IF NOT EXISTS opt_clients (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    surname VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    status ENUM('active', 'inactive') NOT NULL
);

select *
from opt_clients oc 

CREATE TABLE IF NOT EXISTS opt_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_category ENUM('Category1', 'Category2', 'Category3', 'Category4', 'Category5') NOT NULL,
    description TEXT
);

select *
from opt_products op 

CREATE TABLE IF NOT EXISTS opt_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    order_date DATE NOT NULL,
    client_id CHAR(36),
    product_id INT,
    FOREIGN KEY (client_id) REFERENCES opt_clients(id),
    FOREIGN KEY (product_id) REFERENCES opt_products(product_id)
);

select *
from opt_orders oo 	


-- НЕ оптимізований

explain
select 
    p.product_category,
    c.status,
    count(*) as status_count
from opt_clients c
join opt_orders o on c.id = o.client_id
join opt_products p on o.product_id = p.product_id
where p.product_category = (
    select p2.product_category
    from opt_products p2
    join opt_orders o2 on p2.product_id = o2.product_id
    group by p2.product_category
    order by count(*) desc
    limit 1
)
group by p.product_category, c.status
order by status_count desc
limit 1;



-- ОПТИМІЗОВАНИЙ

create index idx_product_category on opt_products(product_category);
create index idx_client_id on opt_orders(client_id);

explain
with mostcategory as (
    select p.product_category
    from opt_products p
    join opt_orders o on p.product_id = o.product_id
    group by p.product_category
    order by count(*) desc
    limit 1
),
statuss as (
    select c.status, count(*) as status_count
    from opt_clients c
    join opt_orders o on c.id = o.client_id
    join opt_products p on o.product_id = p.product_id
    where p.product_category = (select product_category from mostcategory)
    group by c.status
)
select 
    (select product_category from mostcategory) as product_category,
    status, 
    status_count
from statuss
order by status_count desc
limit 1;


    


;





