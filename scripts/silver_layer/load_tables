/*
===========================================================================
LOADING SILVER LAYER TABLES
===========================================================================
SCRIPT PURPOSE:
	This script cleans, standardizes the data from the bronze layer tables 
	and loads it into the silver layer tables. It operates on a full batch 
	load of data from bronze layer tables by truncating and loading the 
	silver layer tables.
===========================================================================
*/

USE baggagehandling_wareHouse;
GO

CREATE PROCEDURE silver.load_data AS
BEGIN
	BEGIN TRY
		DECLARE @loadstarttime AS DATETIME, @loadendtime AS DATETIME, @timetoload AS INT
		/* LOADING THE SILVER baggage_sort_area_log TABLE*/
		SET @loadstarttime = GETDATE()
		TRUNCATE TABLE silver.baggage_sort_area_log
		PRINT('--------------------------------------')
		PRINT('LOADING THE SILVER baggage_sort_area_log TABLE')
		PRINT('--------------------------------------')
		INSERT INTO silver.baggage_sort_area_log
		SELECT
		CAST(CONVERT(DATE,RTRIM(LTRIM(date)),5) AS date) AS date,
		UPPER(flight_number) AS flight_number,
		CONCAT(UPPER(LEFT(REPLACE(RTRIM(LTRIM(belt_number)), ' ', '-'),1)), 
		SUBSTRING(LOWER(REPLACE(RTRIM(LTRIM(belt_number)), ' ', '-')),2, 
		LEN(REPLACE(RTRIM(LTRIM(belt_number)), ' ', '-'))-1)) AS belt_number,
		CAST(sat AS time) AS sat,
		CAST(aat AS time) AS aat,
		CASE
			WHEN offloaded_bags < 0 THEN offloaded_bags*-1
			WHEN offloaded_bags = 0 THEN expected_bags
			ELSE
				 offloaded_bags
		END AS offloaded_bags,
		CASE
			WHEN expected_bags < 0 THEN expected_bags*-1
			WHEN expected_bags = 0 THEN offloaded_bags
			ELSE
				 expected_bags
		END AS expected_bags,
		CAST(fbag_on_belt AS time) AS fbag_on_belt,
		CAST(lbag_on_belt AS time) AS lbag_on_belt
		FROM
		bronze.baggage_sort_area_log

		PRINT('--------------------------------------')
		PRINT('LOADED THE SILVER baggage_sort_area_log TABLE')
		PRINT('--------------------------------------')

		/* LOADING THE SILVER LOADING SUPERVISORS TABLE*/
		TRUNCATE TABLE silver.loading_supervisors
		PRINT('--------------------------------------------')
		PRINT('LOADING THE SILVER LOADING SUPERVISORS TABLE')
		PRINT('--------------------------------------------')
		INSERT INTO silver.loading_supervisors
		SELECT
		id,
		RTRIM(LTRIM(name)) AS name,
		CASE
			WHEN CONCAT(
			UPPER(LEFT(shift, 1)), 
			RTRIM(LOWER(SUBSTRING(shift, 2, CHARINDEX(' ', shift)-1))), 
			'-', 
			UPPER(RIGHT(shift, 1))
			) = 'Shift-C' THEN 'Shift-B'
			ELSE CONCAT(
			UPPER(LEFT(shift, 1)), 
			RTRIM(LOWER(SUBSTRING(shift, 2, CHARINDEX(' ', shift)-1))), 
			'-', 
			UPPER(RIGHT(shift, 1))
			)
		END AS shift
		FROM
		bronze.loading_supervisors
		PRINT('-------------------------------------------')
		PRINT('LOADED THE SILVER LOADING SUPERVISORS TABLE')
		PRINT('-------------------------------------------')

		/* LOADING THE SILVER FLIGHT HANDLING TABLE*/
		TRUNCATE TABLE silver.flight_handling
		PRINT('----------------------------------------')
		PRINT('LOADING THE SILVER FLIGHT HANDLING TABLE')
		PRINT('----------------------------------------');
		WITH CTE1 AS (
			SELECT
			CONVERT(DATE,date,5) AS date,
			CONCAT(
				UPPER(LEFT(shift, 1)), 
				RTRIM(LOWER(SUBSTRING(shift, 2, CHARINDEX(' ', shift)-1))), 
				'-', 
				UPPER(RIGHT(shift, 1))
				) AS shift,
			RTRIM(LTRIM(airline)) AS airline,
			RTRIM(LTRIM(flight_number)) AS flight_number,
			RTRIM(LTRIM(aircraft_type)) AS aircraft_type,
			UPPER(RTRIM(LTRIM(SUBSTRING(route,1,CHARINDEX('-',route,1)-1)))) AS origin,
			UPPER(RTRIM(LTRIM(RIGHT(route, 3)))) AS via,
			CAST(SUBSTRING(route, CHARINDEX('-', route,1) +1, 3) AS nvarchar) AS destination,
			loading_sup_id,
			CAST(sat AS time) AS sat,
			CAST(sdt AS time) AS sdt,
			CAST(aat AS time) AS aat,
			-- HERE SHOULD BE CARGO DOORS OPEN. cleaned as per logic
			CASE
				WHEN CAST(aat AS time) > CAST(cargo_doors_open AS time) THEN CAST(DATEADD(MINUTE, 5, CAST(aat AS time)) AS time)
				WHEN DATEDIFF(MINUTE, CAST(aat AS time), CAST(cargo_doors_open AS time)) > 5 THEN CAST(DATEADD(MINUTE, 5, CAST(aat AS time)) AS time)
				ELSE CAST(cargo_doors_open AS time)
			END AS cargo_doors_open,
		--------------------------------------------------------------------------------
		--------------------------------------------------------------------------------
		-- move cleaning to next cte1
		c_belt_on, -- cleaned as per logic
		h_loader_on, -- cleaned as per logic

		-- move cleaning to cte2
		CASE
			WHEN first_trolley_from_aircraft IS NULL THEN cargo_doors_open
			ELSE first_trolley_from_aircraft
		END AS first_trolley_from_aircraft,

		CASE
			WHEN last_trolley_from_aircraft IS NULL THEN cargo_doors_open
			ELSE last_trolley_from_aircraft
		END AS last_trolley_from_aircraft,
		adt,
		c_belt_off,
		h_loader_off,
		cargo_doors_closed,
		baggage_count_at_aircraft
		FROM
		bronze.flight_handling ),

		CTE2 AS (
		SELECT
		date, shift, airline, flight_number, aircraft_type, origin, via, destination, loading_sup_id, sat, sdt, aat, cargo_doors_open,
		CASE
			WHEN cargo_doors_open > CAST(c_belt_on AS time) THEN CAST(DATEADD(MINUTE, 5, cargo_doors_open) AS time)
			WHEN DATEDIFF(MINUTE, cargo_doors_open, CAST(c_belt_on AS time)) > 5 THEN CAST(DATEADD(MINUTE, 5, cargo_doors_open) AS time)
			ELSE CAST(c_belt_on AS time)
		END AS c_belt_on,
		CASE
			WHEN airline NOT IN ('Ethiopian Airways', 'Qatar Airways') THEN NULL
			WHEN cargo_doors_open > CAST(h_loader_on AS time) THEN CAST(DATEADD(MINUTE, 5, cargo_doors_open) AS time)
			WHEN DATEDIFF(MINUTE, cargo_doors_open, CAST(h_loader_on AS time)) > 5 THEN CAST(DATEADD(MINUTE, 5, cargo_doors_open) AS time)
			ELSE CAST(h_loader_on AS time)
		END as h_loader_on,
		------------------------------------------------------------------
		------------------------------------------------------------------
		first_trolley_from_aircraft,
		last_trolley_from_aircraft,
		adt,
		c_belt_off,
		h_loader_off,
		cargo_doors_closed,
		baggage_count_at_aircraft
		FROM CTE1 ),

		CTE3 AS (
		SELECT
		date, shift, airline, flight_number, aircraft_type, origin, via, destination, loading_sup_id, sat, sdt, aat, cargo_doors_open,
		c_belt_on, h_loader_on,
		CASE
			WHEN CAST(first_trolley_from_aircraft AS time) <=
				(CASE                           -- OTHER OPTION IS TO CREATE A COLUMN FOR THIS LOGIC THEN REFERENCE THE COLUMN IN REQUIRED LOGIC
					WHEN c_belt_on <= h_loader_on THEN CAST(c_belt_on AS time)
					WHEN h_loader_on IS NULL THEN CAST(c_belt_on AS time)
					ELSE CAST(c_belt_on AS time)
				END) THEN CAST(DATEADD(MINUTE, 5, (CASE
													WHEN c_belt_on <= h_loader_on THEN c_belt_on
													WHEN h_loader_on IS NULL THEN c_belt_on
													ELSE h_loader_on
											  END)) AS time)
			WHEN DATEDIFF(MINUTE, (CASE
										WHEN c_belt_on <= h_loader_on THEN CAST(c_belt_on AS time)
										WHEN h_loader_on IS NULL THEN CAST(c_belt_on AS time)
										ELSE CAST(h_loader_on AS time)
									END), CAST(first_trolley_from_aircraft AS time)) > 10 THEN CAST(DATEADD(MINUTE, 10, 
																					(CASE
																						WHEN c_belt_on <= h_loader_on THEN c_belt_on
																						WHEN h_loader_on IS NULL THEN c_belt_on
																						ELSE h_loader_on
																						END)) AS time)
			WHEN DATEDIFF(MINUTE, (CASE
										WHEN c_belt_on <= h_loader_on THEN c_belt_on
										WHEN h_loader_on IS NULL THEN c_belt_on
										ELSE h_loader_on
									END), CAST(first_trolley_from_aircraft AS time)) < 5 THEN CAST(DATEADD(MINUTE, 4, 
																					(CASE
																						WHEN c_belt_on <= h_loader_on THEN c_belt_on
																						WHEN h_loader_on IS NULL THEN c_belt_on
																						ELSE h_loader_on
																						END)) AS time)
			ELSE CAST(first_trolley_from_aircraft AS time)
		END AS first_trolley_from_aircraft,
		------------------------------------------------------------
		-- MOVE THE CLEANING TO NEXT CTE TO PROPERLY REFERENCE THE CLEANED FIRST CART FROM AIRCRAFT
		------------------------------------------------------------
		last_trolley_from_aircraft,
		adt,
		c_belt_off,
		h_loader_off,
		cargo_doors_closed,
		baggage_count_at_aircraft
		FROM
		CTE2 ),

		CTE4 AS (
		SELECT
		date, shift, airline, flight_number, aircraft_type, origin, via, destination, loading_sup_id, sat, sdt, aat, cargo_doors_open,
		c_belt_on, h_loader_on, first_trolley_from_aircraft,
		CASE
			WHEN CAST(last_trolley_from_aircraft AS time) < first_trolley_from_aircraft THEN
				CAST(CASE
					WHEN airline IN ('Ethiopian Airways', 'Qatar Airways') THEN DATEADD(MINUTE, 20, first_trolley_from_aircraft)
					ELSE DATEADD(MINUTE, 10, first_trolley_from_aircraft)
				END AS time)

			WHEN DATEDIFF(MINUTE, first_trolley_from_aircraft, CAST(last_trolley_from_aircraft AS time)) > 20 THEN
				CAST(CASE
					WHEN airline IN ('Ethiopian Airways', 'Qatar Airways') THEN DATEADD(MINUTE, 20, first_trolley_from_aircraft)
					ELSE DATEADD(MINUTE, 10, first_trolley_from_aircraft)
				END AS time)
			ELSE CAST(last_trolley_from_aircraft AS time)
		END AS last_trolley_from_aircraft,
		----------------------------------------------------------------
		----------------------------------------------------------------
		CASE
			 WHEN airline = 'RwandAir' AND aat  >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'RwandAir' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 40 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Ethiopian Airways' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Ethiopian Airways' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 100 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Malawian Airlines' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Malawian Airlines' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 30 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Uganda Airlines' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Uganda Airlines' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 40 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'South African Airways' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'South African Airways' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 40 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Qatar Airways' AND aat >= CAST(adt AS time) AND flight_number = 'QR1455' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Qatar Airways' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 100 AND flight_number = 'QR1455' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Qatar Airways' AND aat >= CAST(adt AS time) AND flight_number = 'QR1456' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Qatar Airways' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 80 AND flight_number = 'QR1456' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Kenya Airways' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Kenya Airways' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 40 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Air Botswana' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Air Botswana' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 35 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Airlink' AND aat >= CAST(adt AS time) AND flight_number = '4Z162' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Airlink' AND DATEDIFF(MINUTE, aat , CAST(adt AS time)) < 40 AND flight_number = '4Z162' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Airlink' AND aat >= CAST(adt AS time) AND flight_number = '4Z166' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Airlink' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 30 AND flight_number = '4Z166' THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Turkish Airlines' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Turkish Airlines' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 50 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Air Tanzania' AND aat >= CAST(adt AS time) THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 WHEN airline = 'Air Tanzania' AND DATEDIFF(MINUTE, aat, CAST(adt AS time)) < 45 THEN CAST(DATEADD(MINUTE, DATEDIFF(MINUTE, sat, sdt), aat) AS time)
			 ELSE CAST(adt AS time)
			END AS adt,
		----------------------------------------------------------------
		-- TO BE CLEANED IN NEXT CTE
		c_belt_off,
		h_loader_off,
		cargo_doors_closed,
		baggage_count_at_aircraft
		FROM
		CTE3),

		CTE5 AS (
		SELECT
		date, shift, airline, flight_number, aircraft_type, origin, via, destination, loading_sup_id, sat, sdt, aat, cargo_doors_open,
		c_belt_on, h_loader_on, first_trolley_from_aircraft, last_trolley_from_aircraft, adt,
		CASE
			WHEN CAST(c_belt_off AS time) <= first_trolley_from_aircraft THEN CAST(DATEADD(MINUTE, -5, adt) AS time)
			WHEN CAST(c_belt_off AS time) > adt THEN CAST(DATEADD(MINUTE, -5, adt) AS time)
			ELSE CAST(c_belt_off AS time)
		END AS c_belt_off,
		CASE
			WHEN h_loader_on IS NULL THEN NULL
			WHEN CAST(h_loader_off AS time) <= first_trolley_from_aircraft THEN CAST(DATEADD(MINUTE, -5, adt) AS time)
			WHEN CAST(h_loader_off AS time) > adt THEN CAST(DATEADD(MINUTE, -5, adt) AS time)
			ELSE CAST(h_loader_off AS time)
		END AS h_loader_off,
		cargo_doors_closed,
		baggage_count_at_aircraft
		FROM
		CTE4),

		CTE6 AS (
		SELECT
		date, shift, airline, flight_number, aircraft_type, origin, via, destination, loading_sup_id, sat, sdt, aat, cargo_doors_open,
		c_belt_on, h_loader_on, first_trolley_from_aircraft, last_trolley_from_aircraft, adt, c_belt_off, h_loader_off,
		CASE
			WHEN h_loader_on IS NOT NULL THEN 
				CASE
					WHEN h_loader_off >= c_belt_off THEN CAST(DATEADD(MINUTE, 1, h_loader_off) AS time)
					WHEN h_loader_off < c_belt_off THEN CAST(c_belt_off AS time)
				END
			ELSE CAST(c_belt_off AS time)
		END AS cargo_doors_closed,
		CASE
			WHEN aircraft_type = 'DH8' THEN 
			CASE
				WHEN baggage_count_at_aircraft > 50 THEN 50
				WHEN baggage_count_at_aircraft < 5 THEN 5
				ELSE baggage_count_at_aircraft
			END
			WHEN aircraft_type = 'CRJ900'THEN
			CASE
				WHEN baggage_count_at_aircraft > 100 THEN 100
				WHEN baggage_count_at_aircraft < 10 THEN 10
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'B737' THEN
			CASE
				WHEN baggage_count_at_aircraft > 160 THEN 160
				WHEN baggage_count_at_aircraft < 20 THEN 20
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'E135' THEN
			CASE
				WHEN baggage_count_at_aircraft > 45 THEN 45
				WHEN baggage_count_at_aircraft < 5 THEN 5
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'B777' THEN
			CASE
				WHEN baggage_count_at_aircraft > 500 THEN 500
				WHEN baggage_count_at_aircraft < 90 THEN 90
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'A220' THEN
			CASE
				WHEN baggage_count_at_aircraft > 80 THEN 80
				WHEN baggage_count_at_aircraft < 20 THEN 20
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'A320' THEN
			CASE
				WHEN baggage_count_at_aircraft > 200 THEN 200
				WHEN baggage_count_at_aircraft < 50 THEN 50
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'A350' THEN
			CASE
				WHEN baggage_count_at_aircraft > 450 THEN 450
				WHEN baggage_count_at_aircraft < 90 THEN 90
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'E175' THEN
			CASE
				WHEN baggage_count_at_aircraft > 85 THEN 85
				WHEN baggage_count_at_aircraft < 30 THEN 30
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'E195' THEN
			CASE
				WHEN baggage_count_at_aircraft > 90 THEN 90
				WHEN baggage_count_at_aircraft < 40 THEN 40
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'B787' THEN
			CASE
				WHEN baggage_count_at_aircraft > 400 THEN 400
				WHEN baggage_count_at_aircraft < 90 THEN 90
				ELSE baggage_count_at_aircraft
			END

			WHEN aircraft_type = 'B737 Max' THEN
			CASE
				WHEN baggage_count_at_aircraft > 300 THEN 300
				WHEN baggage_count_at_aircraft < 90 THEN 90
				ELSE baggage_count_at_aircraft
			END

		END AS cpm_baggage_count
		FROM
		CTE5)
		INSERT INTO silver.flight_handling
		SELECT
		date,
		shift,
		airline,
		flight_number,
		aircraft_type,
		origin,
		via,
		destination,
		loading_sup_id,
		sat,
		sdt,	
		aat,
		adt,
		c_belt_on,
		c_belt_off,
		h_loader_on,
		h_loader_off,
		cargo_doors_open,
		cargo_doors_closed,
		first_trolley_from_aircraft,
		last_trolley_from_aircraft,
		cpm_baggage_count
		FROM
		CTE6
		PRINT('---------------------------------------')
		PRINT('LOADED THE SILVER FLIGHT HANDLING TABLE')
		PRINT('---------------------------------------')

		SET @loadendtime = GETDATE()
		SET @timetoload = DATEDIFF(SECOND, @loadstarttime, @loadendtime)
		PRINT('TIME TAKEN TO LOAD SILVER LAYER TABLES IS '+ CAST(@timetoload AS NVARCHAR)+ ' SECONDS')
	END TRY
	BEGIN CATCH
		SELECT
			ERROR_LINE() AS err_line,
			ERROR_MESSAGE() AS err_message,
			ERROR_NUMBER() AS err_number,
			ERROR_PROCEDURE() AS err_procedure,
			ERROR_SEVERITY() AS err_severity
	END CATCH
END;
GO

EXEC silver.load_data
