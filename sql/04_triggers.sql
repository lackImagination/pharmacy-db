DELIMITER $$
CREATE TRIGGER check_employee_phone_number BEFORE INSERT ON Employees FOR EACH ROW BEGIN
        DECLARE phone_length INT;
        SET phone_length = CHAR_LENGTH(NEW.employee_telephone_number);
        IF (phone_length < 11 OR phone_length > 13) THEN 
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid phone number length';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER check_prescription_availability BEFORE INSERT ON Sales_pharmaceuticals FOR EACH ROW BEGIN
    DECLARE r INT;
    SELECT recipe INTO r FROM Preparations WHERE id_preparation = NEW.id_preparation;
    IF r = 1 AND NEW.prescription_availability = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Cannot buy prescription-only item without prescription';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER check_quantity BEFORE INSERT ON Sales_pharmaceuticals FOR EACH ROW BEGIN
  IF NEW.quantity_pharmaceuticals = 0 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Error: Cannot add sales record with 0 quantity';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER purchase_wholesale BEFORE INSERT ON Sales_pharmaceuticals FOR EACH ROW BEGIN
  IF NEW.quantity_pharmaceuticals >= 11 THEN
    SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'Mistake: Trying to buy in bulk';
  END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER update_Supply_pharmaceuticals AFTER INSERT ON Sales_pharmaceuticals FOR EACH ROW BEGIN
    DECLARE delivery_id INT;
    
    CALL get_delivery_id_by_quantity(NEW.id_preparation, NEW.quantity_pharmaceuticals, delivery_id);

    IF delivery_id IS NOT NULL THEN
        UPDATE Supply_pharmaceuticals
        SET number_products_shipment = number_products_shipment - NEW.quantity_pharmaceuticals
        WHERE id_delivery = delivery_id AND Supply_pharmaceuticals.id_preparation = NEW.id_preparation;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Error: Delivery ID not found. Cannot update Supply_pharmaceuticals.';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER check_supplier_phone_number BEFORE INSERT ON Suppliers FOR EACH ROW BEGIN
        DECLARE phone_length INT;
        SET phone_length = CHAR_LENGTH(NEW.contact_phone_number);
        IF (phone_length < 11 OR phone_length > 13) THEN 
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Invalid phone number length';
        END IF;
    END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER update_date AFTER INSERT ON Supply_pharmaceuticals FOR EACH ROW BEGIN
  UPDATE Preparations
  SET expiration_date = NEW.new_expiration_date
  WHERE id_preparation = NEW.id_preparation;
END$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER update_price AFTER INSERT ON Supply_pharmaceuticals FOR EACH ROW BEGIN
  UPDATE Preparations
  SET unit_price = NEW.price_unit
  WHERE id_preparation = NEW.id_preparation;
END$$
DELIMITER ; 