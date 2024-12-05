CREATE TABLE Ownership (
Owner_id INT,
Owner_type VARCHAR (50),
Cname VARCHAR (50),
Bname VARCHAR (50),
Fname VARCHAR (50),
Lname VARCHAR(50),
Phone VARCHAR(15) NOT NULL,
Email VARCHAR(50) UNIQUE,
PRIMARY KEY(Owner_id),
CHECK ((Owner_type = 'Company' AND Cname IS NOT NULL) OR 
           (Owner_type = 'Individual' AND Fname IS NOT NULL AND Lname IS NOT NULL))
);

CREATE TABLE CARTYPE (
Type_id INT,
Car_type VARCHAR (50),
Weekly_rate DECIMAL(5,2),
Daily_rate DECIMAL(5,2),
Hourly_rate DECIMAL(5,2),
PRIMARY KEY(Type_id)
);

CREATE TABLE CAR(
Vehicle_id NUMERIC (4),
Model VARCHAR (50),
M_Year NUMERIC (4),
Type_id INT NOT NULL,
Number_plate VARCHAR(30) UNIQUE NOT NULL,
Mileage DECIMAL(10,2) NOT NULL,
VIN VARCHAR(17) UNIQUE NOT NULL,
Status VARCHAR(20) DEFAULT 'Available',
PRIMARY KEY(Vehicle_id),
FOREIGN KEY(Type_id) REFERENCES CARTYPE(Type_id),
CHECK (Status IN ('Available', 'Rented', 'Under Maintenance'))
);

CREATE TABLE AVAILABILITY(
Vehicle_id NUMERIC (4),
Available_start DATE,
Available_end DATE,
PRIMARY KEY(Vehicle_id),
FOREIGN KEY(Vehicle_id) REFERENCES CAR (Vehicle_id)
);

CREATE TABLE VEHICLE_OWNER(
Vehicle_id NUMERIC (4),
Owner_id INT,
PRIMARY KEY(Vehicle_id, Owner_id),
FOREIGN KEY(Vehicle_id) REFERENCES CAR (Vehicle_id),
FOREIGN KEY(Owner_id) REFERENCES Ownership(Owner_id)
);

CREATE TABLE CUSTOMER(
Idno INT,
License_no Varchar (20) NOT NULL UNIQUE,
Phone VARCHAR (12) NOT NULL UNIQUE,
Email VARCHAR(50) UNIQUE,
Customer_type VARCHAR (50),
Initial CHAR (1),
Fname VARCHAR (20),
Lname VARCHAR (20),
Cname VARCHAR (50),
CAddress VARCHAR (100),
PRIMARY KEY(Idno),
CHECK ((Customer_type = 'Business' AND Cname IS NOT NULL) OR 
(Customer_type = 'Individual' AND Fname IS NOT NULL AND Lname IS NOT NULL))
);

CREATE TABLE RENTS(
Rent_id SERIAL PRIMARY KEY,
Customer_id INT,
Vehicle_id NUMERIC(4),
Start_date DATE,
Return_date DATE,
Actual_return_date DATE,
Dailyrent DECIMAL(5,2),
Active BOOLEAN DEFAULT TRUE,
Payment_status VARCHAR(20) DEFAULT 'Pending',
FOREIGN KEY(Customer_id) REFERENCES CUSTOMER(Idno),
FOREIGN KEY(Vehicle_id) REFERENCES CAR(Vehicle_id),
CHECK (Payment_status IN ('Paid', 'Pending', 'Overdue'))
);

CREATE TABLE RENTALDETAILS(
Rent_id SERIAL PRIMARY KEY,
Amount_due DECIMAL,
Noofdays INT NOT NULL,
Noofweeks INT,
Dailyrent DECIMAL(5, 2) NOT NULL,
FOREIGN KEY (Rent_id) REFERENCES Rents(Rent_id)
);

CREATE TABLE PAYMENT (
Payment_id SERIAL PRIMARY KEY,
Rent_id INT NOT NULL,
Payment_date DATE NOT NULL,
Amount_paid DECIMAL(10,2) NOT NULL,
Payment_method VARCHAR(20) NOT NULL,
FOREIGN KEY (Rent_id) REFERENCES RENTS(Rent_id)
);

CREATE TABLE MAINTENANCE (
Maintenance_id SERIAL PRIMARY KEY,
Vehicle_id NUMERIC(4) NOT NULL,
Maintenance_date DATE NOT NULL,
Description TEXT NOT NULL,
Cost DECIMAL(10,2),
FOREIGN KEY (Vehicle_id) REFERENCES CAR(Vehicle_id)
);