/*
===============================================================
SILVER LAYER TABLES CREATION
=================================================================
SCRIPT PURPOSE:
	This script creates silver layer tables that will hold clean
	and standardized data from the bronze layer.

WARNING: 
	This script drops all silver layer tables if they exist, then
	create new ones.
=================================================================
*/

USE baggagehandling_wareHouse;
GO

-- check if table exists and drop if it does
IF OBJECT_ID('silver.flight_handling', 'U') IS NOT NULL
BEGIN
	DROP TABLE silver.flight_handling
END;
GO

-- create table flight handling
CREATE TABLE silver.flight_handling
(
date DATE,
shift NVARCHAR(50),
airline	NVARCHAR(50),
flight_number NVARCHAR(50),
aircraft_type NVARCHAR(50),
origin NVARCHAR(50),
via NVARCHAR(50),
destination NVARCHAR(50),
loading_sup_id INT,
sat TIME,
sdt TIME,	
aat TIME,	
adt TIME,
c_belt_on TIME,
c_belt_off TIME,
h_loader_on TIME,	
h_loader_off TIME,
cargo_doors_open TIME,
cargo_doors_closed TIME,
first_trolley_from_aircraft TIME,	
last_trolley_from_aircraft TIME,	
baggage_count_at_aircraft INT
);
GO


-- check if table exists and drop if it does
IF OBJECT_ID('silver.loading_supervisors', 'U') IS NOT NULL
BEGIN
	DROP TABLE silver.loading_supervisors
END;
GO

-- create table loading supervisor
CREATE TABLE silver.loading_supervisors
(
id INT PRIMARY KEY,
name VARCHAR(50),
shift VARCHAR(50)
);
GO


-- check if table exists and drop if it does
IF OBJECT_ID('silver.baggage_sort_area_log', 'U') IS NOT NULL
BEGIN
	DROP TABLE silver.baggage_sort_area_log
END;
GO

-- create table baggage_sort_area_log
CREATE TABLE silver.baggage_sort_area_log
(
date DATE,
flight_number VARCHAR(50),
belt_number VARCHAR(50),
sat TIME,
aat TIME,
offloaded_bags INT,
expected_bags INT,
fbag_on_belt TIME,
lbag_on_belt TIME
)
