/*
===========================================================================
LOAD DATA IN BRONZE LAYER TABLES
===========================================================================
SCRIPT PURPOSE:
	This script loads data from the source files into the respective 
	bronze layer tables.
	The script ingests data via a FULL BATCH LOAD by truncating the tables 
	then load the full data from the source files.
===========================================================================
*/
USE baggagehandling_wareHouse;
GO

CREATE PROCEDURE bronze.load_data AS
BEGIN
	BEGIN TRY
		DECLARE @loadstart DATETIME, @loadend DATETIME, @timetoload INT

		SET @loadstart = GETDATE()

		PRINT('========== STARTING TO LOAD DATA IN THE BRONZE LAYER ==========')
		PRINT('===============================================================')
		PRINT(' ')
		PRINT('---------- LOADING TABLE: LOADING SUPERVISORS ----------')

		TRUNCATE TABLE bronze.loading_supervisors
		BULK INSERT bronze.loading_supervisors
		FROM 'D:\DATA ENGINEERING FOLDER\Baggage Handling Files\loading_supervisors.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		PRINT(' ')
		PRINT('---------- LOADED TABLE: LOADING SUPERVISORS ----------')


		PRINT(' ')
		PRINT('---------- LOADING TABLE: BASEMENT LOG ----------')
		TRUNCATE TABLE bronze.baggage_sort_area_log
		BULK INSERT bronze.baggage_sort_area_log
		FROM 'D:\DATA ENGINEERING FOLDER\Baggage Handling Files\basement_log_file.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		PRINT(' ')
		PRINT('---------- LOADED TABLE: BAGGAGE SORT AREA LOG ----------')


		PRINT(' ')
		PRINT('---------- LOADING TABLE: FLIGHT HANDLING ----------')
		TRUNCATE TABLE bronze.flight_handling
		BULK INSERT bronze.flight_handling
		FROM 'D:\DATA ENGINEERING FOLDER\Baggage Handling Files\flight_handling_file.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		)
		PRINT(' ')
		PRINT('---------- LOADED TABLE: FLIGHT HANDLING ----------')
		SET @loadend = GETDATE()
		SET @timetoload = DATEDIFF(SECOND, @loadstart, @loadend)
		PRINT('TIME TAKEN TO LOAD BRONZE LAYER: ' + CAST(@timetoload AS VARCHAR)  + ' SECOND(S)')
	END try
	BEGIN CATCH
		SELECT
			ERROR_NUMBER() AS error_num, 
			ERROR_MESSAGE() AS error_mess, 
			ERROR_LINE() AS error_lin, 
			ERROR_PROCEDURE() AS error_proc, 
			ERROR_SEVERITY() AS error_sev
	END CATCH

END;
GO

EXEC bronze.load_data
