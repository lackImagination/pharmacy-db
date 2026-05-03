DELIMITER $$
CREATE PROCEDURE check(IN id_sale INT)
BEGIN
  SELECT 
    Sales.id_sales, 
    Sales.date_sale, 
    Employees.SNP_employee, 
    Sales_pharmaceuticals.id_preparation, 
    Preparations.unit_price, 
    SUM(Sales_pharmaceuticals.quantity_pharmaceuticals) AS total_sales,
    SUM(Sales_pharmaceuticals.quantity_pharmaceuticals * Preparations.unit_price) AS total_revenue
  FROM Employees
  JOIN Sales_pharmaceuticals USING(id_employee)
  JOIN Sales USING(id_sales)
  JOIN Preparations USING(id_preparation)
  WHERE Sales.id_sales = id_sale
  GROUP BY Sales.id_sales, Sales_pharmaceuticals.id_preparation
  ORDER BY Sales.id_sales;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE delete_zero_shipments()
BEGIN
  DELETE FROM Supply_pharmaceuticals
  WHERE number_products_shipment = 0;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE expired_preparations()
BEGIN
    SELECT name, expiration_date
    FROM Preparations
    WHERE expiration_date <= DATE_ADD(CURDATE(), INTERVAL 1 MONTH);
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE find_employee_with_highest_sales(IN start_date DATE, IN end_date DATE)
BEGIN
  SELECT e.SNP_employee, SUM(sp.quantity_pharmaceuticals * p.unit_price) AS total_sales
  FROM Sales_pharmaceuticals sp
  JOIN Sales s USING(id_sales)
  JOIN Employees e USING(id_employee)
  JOIN Preparations p USING(id_preparation)
  WHERE s.date_sale BETWEEN start_date AND end_date
  GROUP BY e.id_employee
  ORDER BY total_sales DESC
  LIMIT 1;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE get_delivery_id_by_quantity(IN p_id_preparation INT, IN p_quantity INT, OUT p_delivery_id INT)
BEGIN
    SELECT id_delivery
    INTO p_delivery_id
    FROM Supply_pharmaceuticals
    WHERE id_preparation = p_id_preparation AND number_products_shipment >= p_quantity
    ORDER BY number_products_shipment ASC
    LIMIT 1;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE low_stock_preparations()
BEGIN
    SELECT name, expiration_date, SUM(number_products_shipment) AS total_stock
    FROM Preparations
    JOIN Supply_pharmaceuticals ON Preparations.id_preparation = Supply_pharmaceuticals.id_preparation
    GROUP BY Preparations.id_preparation
    HAVING total_stock < 20;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE search_by_active_substance(IN act_substance VARCHAR(45))
BEGIN
	SELECT p.id_preparation, p.name, p.active_ingredient, p.unit_price, s.number_products_shipment, p.indications, 
	SUM(s.number_products_shipment) as available_quantity
	FROM Manufacturers m
	JOIN Preparations p USING(id_manufacturer)
	JOIN Supply_pharmaceuticals s USING(id_preparation)
	WHERE s.new_expiration_date >= CURDATE() AND s.number_products_shipment > 0 AND p.active_ingredient = act_substance
	GROUP BY p.id_preparation, p.name, p.active_ingredient, p.unit_price, s.number_products_shipment, p.indications;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE search_by_category(IN category VARCHAR(45))
BEGIN
	SELECT p.id_preparation, p.name, c.category_name, p.unit_price, s.number_products_shipment, p.indications, 
	SUM(s.number_products_shipment) as available_quantity
	FROM Manufacturers m
	JOIN Preparations p USING(id_manufacturer)
	JOIN Supply_pharmaceuticals s USING(id_preparation)
    JOIN Categories_preparations cp USING(id_preparation)
    JOIN Categories c USING(id_category)
	WHERE s.new_expiration_date >= CURDATE() AND s.number_products_shipment > 0 AND c.category_name = category
	GROUP BY p.id_preparation, p.name, m.producer_country, p.unit_price, s.number_products_shipment, p.indications;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE search_by_country(IN country VARCHAR(45))
BEGIN
	SELECT p.id_preparation, p.name, m.producer_country, p.unit_price, s.number_products_shipment, p.indications, 
	SUM(s.number_products_shipment) as available_quantity
	FROM Manufacturers m
	JOIN Preparations p USING(id_manufacturer)
	JOIN Supply_pharmaceuticals s USING(id_preparation)
	WHERE s.new_expiration_date >= CURDATE() AND s.number_products_shipment > 0 AND m.producer_country = country
	GROUP BY p.id_preparation, p.name, m.producer_country, p.unit_price, s.number_products_shipment, p.indications;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE search_by_manufacturer(IN m_name VARCHAR(45))
BEGIN
	SELECT p.id_preparation, p.name, m.name_manufacturer, p.unit_price, s.number_products_shipment, p.indications, 
	SUM(s.number_products_shipment) as available_quantity
	FROM Manufacturers m
	JOIN Preparations p USING(id_manufacturer)
	JOIN Supply_pharmaceuticals s USING(id_preparation)
	WHERE s.new_expiration_date >= CURDATE() AND s.number_products_shipment > 0 AND m.name_manufacturer = m_name
	GROUP BY p.id_preparation, p.name, m.name_manufacturer, p.unit_price, s.number_products_shipment, p.indications;
END$$
DELIMITER ;

DELIMITER $$
CREATE  PROCEDURE total_revenue(IN start_date DATE, IN end_date DATE, OUT revenue DECIMAL(10,2))
BEGIN
SELECT 
    SUM(p.unit_price*sp.quantity_pharmaceuticals) AS total_revenue
FROM Sales_pharmaceuticals sp
JOIN Sales s ON sp.id_sales = s.id_sales
JOIN Preparations p ON sp.id_preparation = p.id_preparation
WHERE s.date_sale BETWEEN start_date AND end_date
INTO revenue;
END$$
DELIMITER ; 