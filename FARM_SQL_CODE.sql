CREATE TABLE farmers (
  farmer_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  phone_number VARCHAR(255) NOT NULL,
  dob DATE NOT NULL,
  PRIMARY KEY (farmer_id)
);

CREATE TABLE farms (
  farm_id INT NOT NULL AUTO_INCREMENT,
  farmer_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL,
  size DECIMAL(10,2) NOT NULL,
  type_of_farming ENUM('conventional', 'organic', 'sustainable') NOT NULL,

  PRIMARY KEY (farm_id),
  FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id)
);

CREATE TABLE crops (
  crop_id INT NOT NULL AUTO_INCREMENT,
  farm_id INT NOT NULL,
  variety VARCHAR(255) NOT NULL,
  planting_date DATE NOT NULL,
  harvesting_date DATE NOT NULL,
  expected_yield DECIMAL(10,2) NOT NULL,

  PRIMARY KEY (crop_id),
  FOREIGN KEY (farm_id) REFERENCES farms(farm_id)
);

CREATE TABLE livestock (
  livestock_id INT NOT NULL AUTO_INCREMENT,
  farm_id INT NOT NULL,
  breed VARCHAR(255) NOT NULL,
  age INT NOT NULL,
  weight DECIMAL(10,2) NOT NULL,
  health_status ENUM('healthy', 'sick', 'injured') NOT NULL,

  PRIMARY KEY (livestock_id),
  FOREIGN KEY (farm_id) REFERENCES farms(farm_id)
);

CREATE TABLE customers (
  customer_id INT NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone_number VARCHAR(255) NOT NULL,
  email_address VARCHAR(255) NOT NULL,

  PRIMARY KEY (customer_id)
);

CREATE TABLE orders (
  order_id INT NOT NULL AUTO_INCREMENT,
  farmer_id INT NOT NULL,
  customer_id INT NOT NULL,
  order_date DATE NOT NULL,
  item_cropid INT,
  item_livestockid INT,
  quantity_crop INT,
  quantity_livestock INT,

  PRIMARY KEY (order_id),
  FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (item_cropid) REFERENCES crops(crop_id),
  FOREIGN KEY (item_livestockid) REFERENCES livestock(livestock_id)
);
CREATE TABLE crop_sales (
  sale_id INT NOT NULL AUTO_INCREMENT,
  sale_date DATE NOT NULL,
  customer_id INT NOT NULL,
  sale_amount DECIMAL(10,2) NOT NULL,
  sale_status ENUM('open', 'closed', 'canceled') NOT NULL,
  crop_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (sale_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (crop_id) REFERENCES crops(crop_id)
);

CREATE TABLE livestock_sales (
  sale_id INT NOT NULL AUTO_INCREMENT,
  sale_date DATE NOT NULL,
  customer_id INT NOT NULL,
  sale_amount DECIMAL(10,2) NOT NULL,
  sale_status ENUM('open', 'closed', 'canceled') NOT NULL,
  livestock_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (sale_id),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (livestock_id) REFERENCES livestock(livestock_id)
);


CREATE TABLE expenses (
  expense_id INT NOT NULL AUTO_INCREMENT,
  farmer_id INT NOT NULL,
  expense_date DATE NOT NULL,
  expense_type ENUM('feed', 'supplies', 'equipment', 'labor','others') NOT NULL,
  expense_amount DECIMAL(10,2) NOT NULL,

  PRIMARY KEY (expense_id),
  FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id)
);

CREATE TABLE equipment (
  equipment_id INT NOT NULL AUTO_INCREMENT,
  farmer_id INT NOT NULL,
  equipment_type ENUM('tractor', 'combine', 'harvester','others') NOT NULL,
  equipment_brand VARCHAR(255) NOT NULL,
  equipment_model VARCHAR(255) NOT NULL,
  equipment_year INT NOT NULL,

  PRIMARY KEY (equipment_id),
  FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id)
);

CREATE TABLE employees (
  employee_id INT NOT NULL AUTO_INCREMENT,
  farmer_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  address VARCHAR(255) NOT NULL,
  phone_number VARCHAR(255) NOT NULL,
  hire_date DATE NOT NULL,
  position ENUM('manager', 'supervisor', 'worker') NOT NULL,
  salary DECIMAL(10,2) NOT NULL,
  department ENUM('farming', 'sales', 'administration') NOT NULL,
  expected_date_of_salary DATE NOT NULL,
  PRIMARY KEY (employee_id),
  FOREIGN KEY (farmer_id) REFERENCES farmers(farmer_id)
);


DELIMITER //
CREATE PROCEDURE AddCrop(IN farmId INT, IN variety VARCHAR(255), IN plantingDate DATE, IN harvestingDate DATE, IN expectedYield DECIMAL(10,2))
BEGIN
    INSERT INTO crops (farm_id, variety, planting_date, harvesting_date, expected_yield)
    VALUES (farmId, variety, plantingDate, harvestingDate, expectedYield);
END //
DELIMITER ;
DELIMITER //

CREATE PROCEDURE RemoveCropById(IN p_crop_id INT)
BEGIN
    DELETE FROM crops WHERE crop_id = p_crop_id;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE AddLivestock(
    IN p_farm_id INT,
    IN p_breed VARCHAR(255),
    IN p_age INT,
    IN p_weight DECIMAL(10,2),
    IN p_health_status ENUM('healthy', 'sick', 'injured')
)
BEGIN
    INSERT INTO livestock (farm_id, breed, age, weight, health_status) 
    VALUES (p_farm_id, p_breed, p_age, p_weight, p_health_status);
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE RemoveLivestockById(IN p_livestock_id INT)
BEGIN
    DELETE FROM livestock WHERE livestock_id = p_livestock_id;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE AddEmployee(
    IN p_farmer_id INT,
    IN p_name VARCHAR(255),
    IN p_address VARCHAR(255),
    IN p_phone_number VARCHAR(255),
    IN p_hire_date DATE,
    IN p_position ENUM('manager', 'supervisor', 'worker'),
    IN p_salary DECIMAL(10,2),
    IN p_department ENUM('farming', 'sales', 'administration'),
    IN p_expected_date_of_salary DATE
)
BEGIN
    INSERT INTO employees (farmer_id, name, address, phone_number, hire_date, position, salary, department, expected_date_of_salary)
    VALUES (p_farmer_id, p_name, p_address, p_phone_number, p_hire_date, p_position, p_salary, p_department, p_expected_date_of_salary);
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE RemoveEmployeeById(IN p_employee_id INT)
BEGIN
    DELETE FROM employees WHERE employee_id = p_employee_id;
END //

DELIMITER ;


DELIMITER //
CREATE PROCEDURE GetFarmerCrops(IN farmerId INT)
BEGIN
    SELECT * FROM crops
    WHERE farm_id IN (SELECT farm_id FROM farms WHERE farmer_id = farmerId);
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION CalculateTotalSales(customerId INT) RETURNS DECIMAL(10,2) READS SQL DATA
BEGIN
    DECLARE totalSales DECIMAL(10,2);
    SELECT SUM(sale_amount) INTO totalSales
    FROM crop_sales
    WHERE customer_id = customerId;

    RETURN totalSales;
END //
DELIMITER ;

DELIMITER //

CREATE PROCEDURE GetLivestockByFarmerId(IN p_farmerId INT)
BEGIN
    SELECT *
    FROM livestock
    WHERE farm_id IN (SELECT farm_id FROM farms WHERE farmer_id = p_farmerId);
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE GetEquipmentByFarmerId(IN p_farmerId INT)
BEGIN
    SELECT *
    FROM equipment
    WHERE farmer_id = p_farmerId;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE GetOrdersByFarmerId(IN p_farmerId INT)
BEGIN
    SELECT *
    FROM orders
    WHERE farmer_id = p_farmerId;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE GetSalesByFarmerId(IN p_farmerId INT)
BEGIN
    SELECT *
    FROM crop_sales
    WHERE crop_id IN (SELECT crop_id FROM crops WHERE farm_id IN (SELECT farm_id FROM farms WHERE farmer_id = p_farmerId))
    UNION
    SELECT *
    FROM livestock_sales
    WHERE livestock_id IN (SELECT livestock_id FROM livestock WHERE farm_id IN (SELECT farm_id FROM farms WHERE farmer_id = p_farmerId));
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE GetEmployeesByFarmerId(IN p_farmerId INT)
BEGIN
    SELECT *
    FROM employees
    WHERE farmer_id = p_farmerId;
END //

DELIMITER ;
