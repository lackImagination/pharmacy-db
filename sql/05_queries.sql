SELECT Categories.category_name
FROM Categories
JOIN Categories_preparations ON Categories.id_category = Categories_preparations.id_category
JOIN Preparations ON Categories_preparations.id_preparation = Preparations.id_preparation
WHERE Preparations.name = "Ветом 1,1" AND Preparations.unique_characteristics = "50 шт пакетики";

SELECT name_manufacturer, COUNT(*) AS num_preparations
FROM Manufacturers
JOIN Preparations ON Manufacturers.id_manufacturer = Preparations.id_manufacturer
GROUP BY name_manufacturer;

SELECT Categories.category_name, Preparations.name, Preparations.unit_price
FROM Categories
JOIN Categories_preparations ON Categories.id_category = Categories_preparations.id_category
JOIN Preparations ON Categories_preparations.id_preparation = Preparations.id_preparation
WHERE Preparations.unit_price = (
  SELECT MAX(unit_price)
  FROM Preparations
);

SELECT id_preparation, Preparations.name
FROM Sales_pharmaceuticals
JOIN Preparations USING(id_preparation)
WHERE Sales_pharmaceuticals.id_preparation = (SELECT id_preparation
FROM (
	SELECT SUM(quantity_pharmaceuticals) as total_sales, id_preparation
	FROM Sales_pharmaceuticals
	GROUP BY id_preparation
    ) as sales_by_preparation
    WHERE total_sales = (
	SELECT MAX(sales_by_preparation.total_sales)
	FROM (
		SELECT SUM(quantity_pharmaceuticals) as total_sales, id_preparation
		FROM Sales_pharmaceuticals
		GROUP BY id_preparation
        ) as sales_by_preparation
    ) 
)
GROUP BY id_preparation;

SELECT Sales.date_sale, SUM(Sales_pharmaceuticals.quantity_pharmaceuticals * Preparations.unit_price) AS total_profit
FROM Sales
JOIN Sales_pharmaceuticals USING(id_sales)
JOIN Preparations USING(id_preparation)
GROUP BY Sales.date_sale
ORDER BY total_profit DESC;

SELECT Sales.date_sale, SUM(Sales_pharmaceuticals.quantity_pharmaceuticals * Preparations.unit_price) AS total_profit
FROM Sales
INNER JOIN Sales_pharmaceuticals ON Sales.id_sales = Sales_pharmaceuticals.id_sales
INNER JOIN Preparations ON Sales_pharmaceuticals.id_preparation = Preparations.id_preparation
GROUP BY Sales.date_sale
HAVING SUM(Sales_pharmaceuticals.quantity_pharmaceuticals * Preparations.unit_price) = 
(SELECT MAX(profit) FROM 
(SELECT SUM(Sales_pharmaceuticals.quantity_pharmaceuticals * Preparations.unit_price) AS profit 
FROM Sales
INNER JOIN Sales_pharmaceuticals ON Sales.id_sales = Sales_pharmaceuticals.id_sales
INNER JOIN Preparations ON Sales_pharmaceuticals.id_preparation = Preparations.id_preparation
GROUP BY Sales.date_sale) AS profits)
ORDER BY total_profit DESC;

SELECT Preparations.id_preparation, Preparations.name, Manufacturers.name_manufacturer
FROM Preparations
JOIN Manufacturers USING(id_manufacturer)
WHERE Preparations.unit_price = 
(SELECT MAX(unit_price) FROM Preparations)

SELECT * FROM Supply_pharmaceuticals
WHERE (id_delivery, id_preparation) IN 
(SELECT id_delivery, id_preparation FROM Supply_pharmaceuticals
JOIN Deliveries USING(id_delivery)
JOIN Suppliers USING(id_supplier)
WHERE Suppliers.name_organization = 'Frisquet'
AND YEAR(Deliveries.date_delivery) = YEAR(CURRENT_DATE())-1);

SELECT SUM(sub.query_total) AS total_sales FROM (
SELECT SUM(quantity_pharmaceuticals) AS query_total FROM Sales_pharmaceuticals
JOIN Preparations USING(id_preparation)
JOIN Categories_preparations USING(id_preparation)
JOIN Categories USING(id_category)
WHERE Categories.category_name = 'Жаропонижающие'
) as sub;

SELECT * 
FROM Sales_pharmaceuticals
JOIN Sales USING(id_sales)
WHERE id_employee = (
    SELECT id_employee FROM Employees
    WHERE SNP_employee = 'Данилова Снежана Георгьевна'
) AND date_sale BETWEEN DATE_SUB(NOW(), INTERVAL 2 YEAR) AND NOW();