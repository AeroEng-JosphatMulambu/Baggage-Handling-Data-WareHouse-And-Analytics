/*
==================================================================
CREATING DATABASE AND SCHEMAS
==================================================================
SCRIPT PURPOSE:
	This script creates a database "baggagehandling_warehouse"
	If it exits,its entirely dropped then recreated. Additionally,
	it creates 3 schemas "bronze", "silver" and "gold" in the database.

WARNING:
	Running this script will erase all the contents of the database
	if it exits. Proceed with caution.
=================================================================
*/

USE master;
GO

-- check if database exists: drop if exists
IF DB_ID('baggagehandling_wareHouse') IS NOT NULL
BEGIN
	PRINT('database exists')
	PRINT('---------------')
	PRINT('dropping database')
	PRINT('-----------------')
	DROP database BaggageHandling_WareHouse
	PRINT('database successfully dropped')
	PRINT('-----------------------------')
END;
GO

-- create databse and 3 schemas
CREATE database baggagehandling_wareHouse
PRINT('database created')
PRINT('----------------');
GO

USE baggagehandling_wareHouse;
GO

CREATE Schema bronze;
GO
PRINT('bronze schema created')
PRINT('----------------');
GO

CREATE Schema silver;
GO
PRINT('silver schema created')
PRINT('----------------');
GO

CREATE Schema gold;
GO
PRINT('gold schema created')
PRINT('----------------')
