INSERT INTO mart.fact_departure (
    airport_origin_dk,
    airport_destination_dk,
    weather_type_dk,
    flight_scheduled_ts,
    flight_actual_time,
    flight_number,
    distance,
    tail_number,
    airline,
    dep_delay_min,
    cancelled,
    cancellation_code,
    t,
    max_gws,
    w_speed,
    air_time,
    author,
    loaded_ts
)
SELECT DISTINCT ON (f.flight_dep_scheduled_ts, f.flight_number_reporting_airline, f.airport_origin_dk, f.airport_dest_dk)
    f.airport_origin_dk,
    f.airport_dest_dk,
    w.weather_type_dk,
    f.flight_dep_scheduled_ts,
    f.flight_dep_actual_ts,
    f.flight_number_reporting_airline,
    f.distance,
    f.tail_number,
    f.report_airline,
    COALESCE(f.dep_delay_minutes, 0)::int,
    f.cancelled::int2,
    f.cancellation_code,
    w.t,
    w.max_gws,
    w.w_speed,
    COALESCE(f.air_time, 0)::int,
    '41',
    NOW()
FROM
    dds.kdz41_flights f
LEFT JOIN dds.kdz41_airport_weather w ON
    f.airport_origin_dk = w.airport_dk
    AND f.flight_dep_scheduled_ts BETWEEN w.date_start AND w.date_end
ON CONFLICT (flight_scheduled_ts, flight_number, airport_origin_dk, airport_destination_dk)
DO UPDATE SET
    flight_actual_time = EXCLUDED.flight_actual_time,
    weather_type_dk = EXCLUDED.weather_type_dk,
    distance = EXCLUDED.distance,
    tail_number = EXCLUDED.tail_number,
    airline = EXCLUDED.airline,
    dep_delay_min = EXCLUDED.dep_delay_min,
    cancelled = EXCLUDED.cancelled,
    cancellation_code = EXCLUDED.cancellation_code,
    t = EXCLUDED.t,
    max_gws = EXCLUDED.max_gws,
    w_speed = EXCLUDED.w_speed,
    air_time = EXCLUDED.air_time,
    author = EXCLUDED.author,
    loaded_ts = EXCLUDED.loaded_ts;