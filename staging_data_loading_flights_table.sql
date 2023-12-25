CREATE TABLE IF NOT EXISTS etl.load_kdz41_flights (
    loaded_ts TIMESTAMP NOT NULL PRIMARY KEY
);

DROP TABLE IF EXISTS etl.temp_new_flights_41;
CREATE TABLE etl.temp_new_flights_41 AS
SELECT
    MIN(loaded_ts) AS ts1,
    MAX(loaded_ts) AS ts2
FROM src.kdz_41_flights
WHERE loaded_ts >= COALESCE((SELECT MAX(loaded_ts) FROM etl.load_kdz41_flights), '1970-01-01')
AND origin = 'CLE';



DROP TABLE IF EXISTS etl.temp_flights_data_41;
CREATE TABLE etl.temp_flights_data_41 AS
SELECT
    year, quarter, month,
    TO_DATE(flight_date, 'MM/DD/YYYY HH:MI:SS AM') AS flight_date,
    TO_CHAR(TO_TIMESTAMP(LPAD(CASE WHEN dep_time = 2400 THEN 0 ELSE dep_time END::TEXT, 4, '0'), 'HH24MI'), 'HH24:MI:SS')::TIME AS dep_time,
    TO_CHAR(TO_TIMESTAMP(LPAD(CASE WHEN crs_dep_time = 2400 THEN 0 ELSE crs_dep_time END::TEXT, 4, '0'), 'HH24MI'), 'HH24:MI:SS')::TIME AS crs_dep_time,
    air_time, dep_delay_minutes,
    cancelled::INT, cancellation_code, weather_delay,
    reporting_airline, tail_number, flight_number, distance,
    origin, dest, loaded_ts
FROM src.kdz_41_flights, etl.temp_new_flights_41
WHERE loaded_ts >= ts1 AND loaded_ts <= ts2
AND origin = 'CLE';


INSERT INTO staging.kdz41_flights (
    year, quarter, month, flight_date,
    dep_time, crs_dep_time, air_time, dep_delay_minutes,
    cancelled, cancellation_code, weather_delay,
    reporting_airline, tail_number, flight_number, distance,
    origin, dest, loaded_ts
)
SELECT
    year, quarter, month, flight_date,
    dep_time, crs_dep_time, air_time, dep_delay_minutes,
    cancelled, cancellation_code, weather_delay,
    reporting_airline, tail_number, flight_number, distance,
    origin, dest, loaded_ts
FROM etl.temp_flights_data_41
where origin = 'CLE'
ON CONFLICT (flight_date, flight_number, origin, dest, crs_dep_time) DO UPDATE 
SET
    quarter = EXCLUDED.quarter,
    month = EXCLUDED.month,
    dep_time = EXCLUDED.dep_time,
    air_time = EXCLUDED.air_time,
    dep_delay_minutes = EXCLUDED.dep_delay_minutes,
    cancelled = EXCLUDED.cancelled,
    cancellation_code = EXCLUDED.cancellation_code,
    weather_delay = EXCLUDED.weather_delay,
    reporting_airline = EXCLUDED.reporting_airline,
    tail_number = EXCLUDED.tail_number,
    distance = EXCLUDED.distance,
    loaded_ts = EXCLUDED.loaded_ts;

   
   DELETE FROM etl.load_kdz41_flights
WHERE EXISTS (SELECT 1 FROM etl.temp_new_flights_41);

INSERT INTO etl.load_kdz41_flights(loaded_ts)
SELECT ts2
FROM etl.temp_new_flights_41
WHERE EXISTS (SELECT 1 FROM etl.temp_new_flights_41);