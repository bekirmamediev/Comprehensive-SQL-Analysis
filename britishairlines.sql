SELECT cp.period
	, cr.revenue
  , cp.active_users
FROM company_products cp 		
	LEFT JOIN company_revenue cr		
  	ON cp.client = cr.client
    AND cp.period = cr.period
WHERE cp.client = 'British Airways'


--q1 
--COUNT flight_id ac_subtype, avg fuel_efficiency

SELECT 
	COUNT (DISTINCT bf.flight_id) AS total_flight_id
  , COUNT (DISTINCT ba.ac_subtype) AS total_as_subtype
  , AVG (be.fuel_efficiency) AS avg_fuel_eff
FROM ba_flights bf
	LEFT JOIN ba_aircraft ba 
  	ON bf.flight_id = ba.flight_id
  LEFT JOIN ba_fuel_efficiency be 
  	ON ba.ac_subtype = be.ac_subtype
    
--q2 

SELECT 
	COUNT (DISTINCT bf.flight_id) AS total_flight_id
  , COUNT (DISTINCT ba.ac_subtype) AS total_as_subtype
  , AVG (be.fuel_efficiency) AS avg_fuel_eff
FROM ba_flights bf
	INNER JOIN ba_aircraft ba 
  	ON bf.flight_id = ba.flight_id
  INNER JOIN ba_fuel_efficiency be 
  	ON ba.ac_subtype = be.ac_subtype
    
 --q3 
SELECT 
 	bf.flight_id
  , ba.ac_subtype
  , ba.manufacturer
FROM ba_flights bf 
	LEFT JOIN ba_aircraft ba
  	ON bf.flight_id = ba.flight_id
WHERE ba.flight_id IS Null
--ba.ac_subtype IS Null 
--	AND ba.manufacturer IS Null

--q4
SELECT 
	bfe.ac_subtype
  , bfe.manufacturer
	, COUNT (DISTINCT actual_flight_date) 
FROM ba_fuel_efficiency bfe
	LEFT JOIN ba_aircraft ba 
  	ON bfe.ac_subtype = ba.ac_subtype
  LEFT JOIN ba_flights bf 
  	ON ba.flight_id = bf.flight_id
GROUP BY bfe.ac_subtype
  , bfe.manufacturer
  
--practice 

--q1
--Create a list of flights, showing the flight ID, departure city, arrival city, manufacturer, and aircraft sub-type that will be used for each flight

Show the results for all flights that are available even if not all information is available for all flights.
SELECT 
	bf.flight_id
  , bfr.departure_city
  , bfr.arrival_city
  , ba.manufacturer
  , ba.ac_subtype
FROM ba_flights bf 
	LEFT JOIN ba_flight_routes bfr ON bf.flight_number = bfr.flight_number
  LEFT JOIN ba_aircraft ba ON bf.flight_id = ba.flight_id


--q2
--What is the maximum number of passengers that have been on every available aircraft (manufacturer and sub-type) for flights that have been completed?

If the manufacturer and sub-type are not available for flights, we do not need to show the results of these flights
SELECT 
	bfe.ac_subtype
  , bfe.manufacturer
  , MAX(bf.total_passengers)
FROM ba_fuel_efficiency bfe 
	LEFT JOIN ba_aircraft ba ON bfe.ac_subtype = ba.ac_subtype
  LEFT JOIN ba_flights bf ON ba.flight_id = bf.flight_id
WHERE bf.status = 'Completed'
GROUP BY bfe.ac_subtype
  , bfe.manufacturer

--q3
--Since only some aircraft are capable of flying long distances overseas, we want to filter out the planes that only do shorter distances.

What aircraft (manufacturer and sub-type) have completed flights of a distance of more than 7,000 km? 

If the manufacturer and sub-type are not available for flights, we do not need to show the results of these flights.
SELECT DISTINCT 
	bfe.ac_subtype
  , bfe.manufacturer
  , bfe.fuel_efficiency
FROM ba_fuel_efficiency bfe 
	LEFT JOIN ba_aircraft ba ON bfe.ac_subtype = ba.ac_subtype
  LEFT JOIN ba_flights bf ON ba.flight_id = bf.flight_id
  LEFT JOIN ba_flight_routes bfr ON bf.flight_number = bfr.flight_number
WHERE bf.status = 'Completed'
	AND bfr.distance_flown > 7000

--q4
--What is the most used aircraft (manufacturer and sub-type) for flights departing from London and arriving in Basel, Trondheim, or Glasgow? 

Include the number of flights that the aircraft was used for.

If the manufacturer and sub-type are not available for flights, we do not need to show the results of these flights.
SELECT
	bfe.ac_subtype
  , bfe.manufacturer
  , COUNT (ba.flight_id) AS number_of_flights
FROM ba_fuel_efficiency bfe 
	LEFT JOIN ba_aircraft ba ON bfe.ac_subtype = ba.ac_subtype
  LEFT JOIN ba_flights bf ON ba.flight_id = bf.flight_id
  LEFT JOIN ba_flight_routes bfr ON bf.flight_number = bfr.flight_number
WHERE 1=1
	AND  bfr.departure_city = 'London'
  AND bfr.arrival_city in ('Basel', 'Trondheim','Glasgow')
GROUP BY bfe.ac_subtype
  , bfe.manufacturer
ORDER BY 3 DESC

--q5 
--For the flight routes highlighted in question 4 combined, would there have been an aircraft that, on average, would use less fuel on the flight routes? 

The fuel used in liters per flight can be calculated by multiplying the fuel efficiency metric by distance, baggage weight, and number of passengers. 

What aircraft (manufacturer and sub-type) would you recommend to use for each of these flight routes if you use the average fuel consumption as your guiding metric?

If the manufacturer and sub-type are not available for flights, we do not need to show the results of these flights.
SELECT
	bfe.ac_subtype
  , bfe.manufacturer
  , AVG (bfe.fuel_efficiency*bfr.distance_flown*bf.baggage_weight*bf.total_passengers) AS avg_total_liters
FROM ba_fuel_efficiency bfe 
	LEFT JOIN ba_aircraft ba ON bfe.ac_subtype = ba.ac_subtype
  LEFT JOIN ba_flights bf ON ba.flight_id = bf.flight_id
  LEFT JOIN ba_flight_routes bfr ON bf.flight_number = bfr.flight_number
WHERE 1=1
	AND  bfr.departure_city = 'London'
  AND bfr.arrival_city in ('Basel', 'Trondheim','Glasgow')
GROUP BY bfe.ac_subtype
  , bfe.manufacturer
ORDER BY 3 ASC

--q6
--The fuel used in liters per flight can be calculated by multiplying the fuel efficiency metric by distance, baggage weight, and number of passengers. 

Calculate the total amount of fuel used per kilometer flown of completed flights per manufacturer. 
What manufacturer has used less fuel per km in total?

If flights do not have data available about the aircraft type, you can exclude the flights from the analysis.

SELECT
--	bfe.ac_subtype
   bfe.manufacturer
  , SUM (bfe.fuel_efficiency*bfr.distance_flown*bf.baggage_weight*bf.total_passengers) / SUM(bfr.distance_flown) AS avg_total_liters
FROM ba_fuel_efficiency bfe 
	LEFT JOIN ba_aircraft ba ON bfe.ac_subtype = ba.ac_subtype
  LEFT JOIN ba_flights bf ON ba.flight_id = bf.flight_id
  LEFT JOIN ba_flight_routes bfr ON bf.flight_number = bfr.flight_number
WHERE 1=1
	AND bf.status = 'Completed'
GROUP BY --bfe.ac_subtype
   bfe.manufacturer
ORDER BY 2 ASC


--test 
SELECT 
	COUNT (DISTINCT ba.ac_subtype)
FROM ba_aircraft ba
  LEFT JOIN ba_flights bf ON ba.flight_id = bf.flight_id
WHERE bf.status = 'Completed'

SELECT 
	AVG (bf.total_passengers)
FROM ba_aircraft ba
	INNER JOIN ba_fuel_efficiency bfe ON bfe.manufacturer = ba.manufacturer
  INNER JOIN ba_flights bf ON ba.flight_id = bf.flight_id
WHERE ba.manufacturer = 'Boeing'
	AND bfe.capacity > 200
  
SELECT 
	COUNT (bf.flight_id) 
FROM ba_flights bf 
	LEFT JOIN ba_flight_routes bfr ON bf.flight_number = bfr.flight_number
  LEFT JOIN ba_aircraft ba ON bf.flight_id = ba.flight_id
  LEFT JOIN ba_fuel_efficiency bfe ON ba.ac_subtype = bfe.ac_subtype
WHERE bfr.distance_flown > 3000
	AND bfe.capacity < 100 
  
SELECT 
	COUNT (bf.flight_id) 
FROM ba_flights bf 
  LEFT JOIN ba_aircraft ba ON bf.flight_id = ba.flight_id
  LEFT JOIN ba_fuel_efficiency bfe ON ba.ac_subtype = bfe.ac_subtype
WHERE bfe.manufacturer = 'Airbus'
	AND bfe.manufacturer = 'ATR42'

SELECT 
	SUM (bf.baggage_weight) 
FROM ba_flights bf 
  LEFT JOIN ba_aircraft ba ON bf.flight_id = ba.flight_id
  LEFT JOIN ba_fuel_efficiency bfe ON ba.ac_subtype = bfe.ac_subtype
WHERE bfe.manufacturer = 'Boeing'
	AND bfe.fuel_efficiency > 0.04