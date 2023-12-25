INSERT INTO dds.kdz41_airport_weather  (
    airport_dk, 
    weather_type_dk, 
    cold, 
    rain, 
    snow, 
    thunderstorm, 
    drizzle, 
    fog_mist, 
    t, 
    max_gws, 
    w_speed, 
    date_start, 
    date_end, 
    loaded_ts
)
SELECT
    dwh.id_airport.dwh_dk as airport_dk,
    CONCAT(
        CASE WHEN t_air_temperature < 0 THEN '1' ELSE '0' END,
        CASE WHEN ww_present LIKE '%rain%' OR ww_recent LIKE '%rain%' THEN '1' ELSE '0' END,
        CASE WHEN ww_present LIKE '%snow%' OR ww_recent LIKE '%snow%' THEN '1' ELSE '0' END,
        CASE WHEN ww_present LIKE '%thunderstorm%' OR ww_recent LIKE '%thunderstorm%' THEN '1' ELSE '0' END,
        CASE WHEN ww_present LIKE '%drizzle%' OR ww_recent LIKE '%drizzle%' THEN '1' ELSE '0' END,
        CASE WHEN ww_present LIKE '%fog%' OR ww_present LIKE '%mist%' OR ww_recent LIKE '%fog%' OR ww_recent LIKE '%mist%' THEN '1' ELSE '0' END
    ) AS weather_type_dk,
    CASE WHEN t_air_temperature < 0 THEN 1 ELSE 0 END AS cold,
    CASE WHEN ww_present LIKE '%rain%' OR ww_recent LIKE '%rain%' THEN 1 ELSE 0 END AS rain,
    CASE WHEN ww_present LIKE '%snow%' OR ww_recent LIKE '%snow%' THEN 1 ELSE 0 END AS snow,
    CASE WHEN ww_present LIKE '%thunderstorm%' OR ww_recent LIKE '%thunderstorm%' THEN 1 ELSE 0 END AS thunderstorm,
    CASE WHEN ww_present LIKE '%drizzle%' OR ww_recent LIKE '%drizzle%' THEN 1 ELSE 0 END AS drizzle,
    CASE WHEN ww_present LIKE '%fog%' OR ww_present LIKE '%mist%' OR ww_recent LIKE '%fog%' OR ww_recent LIKE '%mist%' THEN 1 ELSE 0 END AS fog_mist,
    t_air_temperature AS t,
    ff10_max_gust_value AS max_gws,
    ff_wind_speed AS w_speed,
    to_timestamp(local_datetime, 'DD.MM.YYYY HH24:MI') AS date_start,
  COALESCE(
    LEAD(to_timestamp(local_datetime, 'DD.MM.YYYY HH24:MI')) OVER (PARTITION BY icao_code ORDER BY local_datetime), 
    '3000-01-01 00:00:00'::timestamp
      ) AS date_end,
  now() AS loaded_ts
FROM
    staging.kdz41_weather
JOIN
    dwh.id_airport ON staging.kdz41_weather.icao_code = dwh.id_airport.src_icao_id;
--WHERE
    --staging.kdz41_weather.last_updated_timestamp > (SELECT MAX(loaded_ts) FROM dds.kdz41_airport_weather);