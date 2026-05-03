CREATE DATABASE IF NOT EXISTS pharmacy; 
USE pharmacy; 
CREATE TABLE IF NOT EXISTS Suppliers (
  id_supplier INT(5) NOT NULL AUTO_INCREMENT,
  name_organization VARCHAR(45) NOT NULL,
  contact_phone_number VARCHAR(15) NOT NULL,
  PRIMARY KEY (id_supplier)
);

CREATE TABLE IF NOT EXISTS Categories (
  id_category INT(5) NOT NULL AUTO_INCREMENT,
  category_name VARCHAR(45) NOT NULL,
  PRIMARY KEY (id_category)
);

CREATE TABLE IF NOT EXISTS Manufacturers (
  id_manufacturer INT(5) NOT NULL AUTO_INCREMENT,
  name_manufacturer VARCHAR(45) NOT NULL,
  producer_country varchar(45) NOT NULL, 
  PRIMARY KEY (id_manufacturer)
);

CREATE TABLE IF NOT EXISTS Employees (
  id_employee INT(5) NOT NULL AUTO_INCREMENT,
  SNP_employee VARCHAR(45) NOT NULL,
  position VARCHAR(45) NOT NULL,
  employee_telephone_number VARCHAR(15) NOT NULL,
  PRIMARY KEY (id_employee)
);

CREATE TABLE IF NOT EXISTS Sales (
  id_sales INT(5) NOT NULL AUTO_INCREMENT,
  date_sale DATE NOT NULL,
  PRIMARY KEY (id_sales)
);

CREATE TABLE IF NOT EXISTS Deliveries (
  id_delivery INT(5) NOT NULL AUTO_INCREMENT,
  date_delivery DATE NOT NULL,
  id_supplier INT(5) NOT NULL,
  PRIMARY KEY (id_delivery),
  CONSTRAINT fk_supp_delivery FOREIGN KEY (id_supplier)
    REFERENCES Suppliers(id_supplier)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Preparations (
  id_preparation INT(5) NOT NULL AUTO_INCREMENT,
  name VARCHAR(45) NOT NULL,
  expiration_date DATE NOT NULL,
  active_ingredient VARCHAR(45),
  unique_characteristics VARCHAR(45),
  indications VARCHAR(45) NOT NULL,
  application VARCHAR(45) NOT NULL,
  unit_price FLOAT NOT NULL,
  id_manufacturer INT(5) NOT NULL,
  recipe tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (id_preparation),
  CONSTRAINT fk_manuf_prep FOREIGN KEY (id_manufacturer)
    REFERENCES Manufacturers(id_manufacturer)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Categories_preparations (
  id_preparation INT(5) NOT NULL,
  id_category INT(5) NOT NULL,
  PRIMARY KEY (id_preparation, id_category),
  CONSTRAINT fk_prep_cat FOREIGN KEY (id_preparation)
    REFERENCES Preparations(id_preparation)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_cat_prep FOREIGN KEY (id_category)
    REFERENCES Categories(id_category)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Supply_pharmaceuticals (
  id_preparation INT(5) NOT NULL,
  id_delivery INT(5) NOT NULL,
  number_products_shipment INT(5) NOT NULL,
  price_unit FLOAT NOT NULL,
  prescription_availability tinyint(1) DEFAULT '0',
  new_expiration_date DATE NOT NULL,
  PRIMARY KEY (id_preparation, id_delivery),
  CONSTRAINT fk_prep_ship FOREIGN KEY (id_preparation)
    REFERENCES Preparations(id_preparation)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_ship_supp FOREIGN KEY (id_delivery)
    REFERENCES Deliveries(id_delivery)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS Sales_pharmaceuticals (
  id_sales INT(5) NOT NULL,
  id_preparation INT(5) NOT NULL,
  id_employee INT(5) NOT NULL,
  quantity_pharmaceuticals INT(5) NOT NULL,
  PRIMARY KEY (id_sales, id_preparation),
  CONSTRAINT fk_sales_prep FOREIGN KEY (id_sales)
    REFERENCES Sales(id_sales)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_prep_sales FOREIGN KEY (id_preparation)
    REFERENCES Preparations(id_preparation)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_emp_sales FOREIGN KEY (id_employee)
    REFERENCES Employees(id_employee)
    ON DELETE CASCADE
    ON UPDATE CASCADE
