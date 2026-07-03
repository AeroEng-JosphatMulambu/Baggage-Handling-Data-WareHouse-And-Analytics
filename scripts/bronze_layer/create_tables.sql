/*
===============================================================
CREATING ALL BRONZE LAYER TABLES
===============================================================
SCRIPT PURPOSE:
	This script creates 3 tables in the BRONZE LAYER
	"flight handling", "loading supervisors" and "basement log"
	The 3 tables will hold RAW data from source systems


WARNING:
	If tables exists, they will be dropped then recreated
	Proceed with caustion.
===============================================================
*/

USE baggagehandling_wareHouse;
GO

-- Check if table "flight handling" exists: drop if exits
IF OBJECT_ID('bronze.flight_handling', 'U') IS NOT NULL
BEGIN
	DROP TABLE bronze.flight_handling
END;
GO

-- create table "flight handling" in bronze layer
PRINT('Creating table flight handling')
PRINT('-------------------------------')

CREATE TABLE bronze.flight_handling
(
date NVARCHAR(50),
shift NVARCHAR(50),
airline	NVARCHAR(50),
flight_number NVARCHAR(50),
aircraft_type NVARCHAR(50),
route NVARCHAR(50),
loading_sup_id INT,
sat NVARCHAR(50),
sdt NVARCHAR(50),	
aat NVARCHAR(50),	
cargo_doors_open NVARCHAR(50),
c_belt_on NVARCHAR(50),
h_loader_on NVARCHAR(50),
first_trolley_from_aircraft NVARCHAR(50),
last_trolley_from_aircraft NVARCHAR(50),
adt NVARCHAR(50),
c_belt_off NVARCHAR(50),
h_loader_off NVARCHAR(50),
cargo_doors_closed NVARCHAR(50),
baggage_count_at_aircraft INT
);
GO
PRINT('Created table flight handling')
PRINT('-------------------------------')


-- Check if table "loading_supervisors" exists: drop if exits
IF OBJECT_ID('bronze.loading_supervisors', 'U') IS NOT NULL
BEGIN
	DROP TABLE bronze.loading_supervisors
END;
GO

PRINT('Creating table loading supervisors')
PRINT('-------------------------------')
CREATE TABLE bronze.loading_supervisors
(
id INT PRIMARY KEY,
name VARCHAR(50),
shift VARCHAR(50)
);
GO
PRINT('Created table loading supervisors')
PRINT('-------------------------------')


-- Check if table "baggage_sort_area_log" exists: drop if exits
IF OBJECT_ID('bronze.baggage_sort_area_log', 'U') IS NOT NULL
BEGIN
	DROP TABLE bronze.baggage_sort_area_log
END;
GO

PRINT('Creating table baggage_sort_area_log')
PRINT('-------------------------------')
CREATE TABLE bronze.baggage_sort_area_log
(
date VARCHAR(50),
flight_number VARCHAR(50),
belt_number VARCHAR(50),
sat VARCHAR(50),
aat VARCHAR(50),
offloaded_bags INT,
expected_bags INT,
fbag_on_belt VARCHAR(50),
lbag_on_belt VARCHAR(50)
);
GO
PRINT('Created table baggage_sort_area_log')
PRINT('-------------------------------')
