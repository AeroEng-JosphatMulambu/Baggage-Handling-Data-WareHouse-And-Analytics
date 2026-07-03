/*
=============================================================================
CREATING GOLD LAYER VIEW
=============================================================================
SCRIPT PURPOSE:
	This script integrates and enriches data that is cleaned and standardized
	from the silver layer tables base on the business need into one view 
	optimised for analytics

NOTE:
	Data model behind this view is a GALAXY SCHEMA combing 2 fact tables
	and 1 dimension table. The view can be queried directly for analytics 
	and reporting.
============================================================================
*/
USE baggagehandling_wareHouse;
GO

-- check if view exist: drop if it does
IF OBJECT_ID('gold.ramp_operations', 'V') IS NOT NULL
BEGIN
	DROP VIEW gold.ramp_operations
END;
GO

-- create view "ramp operations"
CREATE VIEW gold.ramp_operations AS
SELECT
fh.date,
ls.shift,
ls.name AS loading_supervisor,
fh.airline,
fh.flight_number,
fh.aircraft_type,
fh.origin,
fh.via,
fh.destination,
fh.sat AS standard_arrival_time,
fh.sdt AS standard_departure_time,
fh.aat AS chocks_on,
fh.cargo_doors_open,
fh.c_belt_on AS conveyor_belt_positioned,
fh.c_belt_off AS conveyor_belt_retracted,
fh.h_loader_on AS high_loader_positioned,
fh.h_loader_off AS high_loader_retracted,
fh.cargo_doors_closed,
fh.adt AS chocks_off,
fh.first_trolley_from_aircraft,
fh.last_trolley_from_aircraft,
bl.belt_number AS offload_belt_number,
bl.fbag_on_belt AS first_bag_on_belt,
bl.lbag_on_belt AS last_bag_on_belt,
fh.baggage_count_at_aircraft AS offload_count_at_aircraft,
CASE
	WHEN (fh.baggage_count_at_aircraft - bl.offloaded_bags) < -5 OR 
	(fh.baggage_count_at_aircraft - bl.offloaded_bags) > 5 THEN fh.baggage_count_at_aircraft
	ELSE
		bl.offloaded_bags
END AS offload_count_on_offload_belt,
CASE
	WHEN (fh.baggage_count_at_aircraft - bl.expected_bags) < -5 OR 
	(fh.baggage_count_at_aircraft - bl.expected_bags) > 5 THEN fh.baggage_count_at_aircraft
	ELSE
		bl.expected_bags
END AS expected_bags
FROM
silver.flight_handling AS fh
LEFT JOIN silver.baggage_sort_area_log AS bl
ON fh.date = bl.date AND fh.flight_number = bl.flight_number
LEFT JOIN silver.loading_supervisors AS ls
ON fh.loading_sup_id = ls.id
