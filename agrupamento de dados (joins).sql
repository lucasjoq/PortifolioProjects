--- COM O DATABASE 'BIKESTORES', QUEREMOS COMPILAR OS SEGUINTES DADOS EM UMA SÓ TABELA:
--- order_id,customers (NOME COMPLETO),city,state,order_date,total_units, revenue,product_name,category_name,store_name,sales_rep(nome completo

CREATE VIEW vendas AS
(
SELECT
	sales.orders.order_id,
	CONCAT(sales.customers.first_name, ' ' ,sales.customers.last_name) AS "Client",
	sales.customers.city,
	sales.customers.state,
	sales.orders.order_date,
	sales.order_items.quantity AS "total_units",
	SUM(sales.order_items.quantity*sales.order_items.list_price) AS "Revenue",
	production.products.product_name AS "Product",
	production.categories.category_name AS "Category",
	sales.stores.store_name AS "Store",
	CONCAT(sales.staffs.first_name, ' ' ,sales.staffs.last_name) as "Sales_Rep"
FROM
	sales.orders
JOIN
	sales.customers ON 
		sales.orders.customer_id = sales.customers.customer_id
JOIN
	sales.order_items ON 
		sales.orders.order_id = sales.order_items.order_id
JOIN
	production.products ON 
		sales.order_items.product_id = production.products.product_id
JOIN
	production.categories ON
		production.products.category_id = production.categories.category_id
JOIN
	sales.stores ON 
		sales.orders.store_id = sales.stores.store_id
JOIN
	sales.staffs ON 
		sales.orders.staff_id = sales.staffs.staff_id


GROUP BY
	sales.orders.order_id,
	CONCAT(sales.customers.first_name, ' ' ,sales.customers.last_name),
	sales.customers.city,
	sales.customers.state,
	sales.orders.order_date,
	sales.order_items.quantity,
	production.products.product_name,
	production.categories.category_name,
	sales.stores.store_name,
	CONCAT(sales.staffs.first_name, ' ' ,sales.staffs.last_name)

)