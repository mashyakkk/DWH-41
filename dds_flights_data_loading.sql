INSERT INTO dds.kdz41_flights (
    year, 
    quarter, 
    month, 
    flight_scheduled_date,
    flight_actual_date, 
    flight_dep_scheduled_ts, 
    flight_dep_actual_ts, 
    report_airline, 
    tail_number, 
    flight_number_reporting_airline, 
    airport_origin_dk, 
    origin_code, 
    airport_dest_dk, 
    dest_code, 
    dep_delay_minutes, 
    cancelled, 
    cancellation_code, 
    weather_delay, 
    air_time, 
    distance, 
    loaded_ts
)
SELECT
    year,
    quarter,
    month,
    flight_date::date AS flight_scheduled_date,
    CASE 
        WHEN cancelled = 0 THEN (TO_TIMESTAMP(flight_date::text  ' '  crs_dep_time::text, 'YYYY-MM-DD HH24:MI:SS') + COALESCE(dep_delay_minutes, 0) * INTERVAL '1 minute')::date 
        ELSE NULL 
    END AS flight_actual_date,
    TO_TIMESTAMP(flight_date::text  ' '  crs_dep_time::text, 'YYYY-MM-DD HH24:MI:SS') AS flight_dep_scheduled_ts,
    CASE 
        WHEN cancelled = 0 THEN TO_TIMESTAMP(flight_date::text  ' '  crs_dep_time::text, 'YYYY-MM-DD HH24:MI:SS') + COALESCE(dep_delay_minutes, 0) * INTERVAL '1 minute' 
        ELSE NULL 
    END AS flight_dep_actual_ts,
    reporting_airline,
    COALESCE(tail_number, 'Unknown') AS tail_number,
    flight_number,
    (SELECT airport_dk FROM dds.airport WHERE iata_code = origin) AS airport_origin_dk,
    origin,
    (SELECT airport_dk FROM dds.airport WHERE iata_code = dest) AS airport_dest_dk,
    dest,
    dep_delay_minutes,
    cancelled,
    cancellation_code,
    weather_delay,
    air_time,
    distance,
    now() AS loaded_ts
FROM
    staging.kdz41_flights;