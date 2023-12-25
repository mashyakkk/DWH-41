CREATE TABLE IF NOT EXISTS etl.load_kdz41_weather (
    loaded_ts TIMESTAMP NOT NULL PRIMARY KEY
);

DROP TABLE IF EXISTS etl.temp_new_weather_41;
CREATE TABLE etl.temp_new_weather_41 AS
SELECT
    MIN(loaded_ts) AS ts1,
    MAX(loaded_ts) AS ts2
FROM src.kdz_41_weather
WHERE loaded_ts >= COALESCE((SELECT MAX(loaded_ts) FROM etl.load_kdz41_weather), '1970-01-01');




DROP TABLE IF EXISTS etl.temp_weather_data_41;
CREATE TABLE etl.temp_weather_data_41 AS
SELECT DISTINCT ON (icao_code, local_datetime)
    icao_code,
    local_datetime, -- Assuming this is in a correct format that matches the target table
    COALESCE(t_air_temperature, 0) AS t_air_temperature,
    COALESCE(p0_sea_lvl, 0) AS p0_sea_lvl,
    COALESCE(p_station_lvl, 0) AS p_station_lvl,
    COALESCE(u_humidity, 0) AS u_humidity,
    dd_wind_direction,
    ff_wind_speed,
    ff10_max_gust_value,
    ww_present,
    ww_recent,
    c_total_clouds,
    COALESCE(vv_horizontal_visibility, 0) AS vv_horizontal_visibility,
    COALESCE(td_temperature_dewpoint, 0) AS td_temperature_dewpoint,
    loaded_ts
FROM src.kdz_41_weather, etl.temp_new_weather_41
WHERE loaded_ts >= ts1 AND loaded_ts <= ts2;





INSERT INTO staging.kdz41_weather (
    icao_code, local_datetime, t_air_temperature, p0_sea_lvl, p_station_lvl, u_humidity,
    dd_wind_direction, ff_wind_speed, ff10_max_gust_value, ww_present, ww_recent, c_total_clouds,
    vv_horizontal_visibility, td_temperature_dewpoint, loaded_ts
)
SELECT
    icao_code, local_datetime, t_air_temperature, p0_sea_lvl, p_station_lvl, u_humidity,
    dd_wind_direction, ff_wind_speed, ff10_max_gust_value, ww_present, ww_recent, c_total_clouds,
    vv_horizontal_visibility, td_temperature_dewpoint, loaded_ts
FROM etl.temp_weather_data_41
ON CONFLICT (icao_code, local_datetime) DO UPDATE 
SET
    t_air_temperature = EXCLUDED.t_air_temperature,
    p0_sea_lvl = EXCLUDED.p0_sea_lvl,
    p_station_lvl = EXCLUDED.p_station_lvl,
    u_humidity = EXCLUDED.u_humidity,
    dd_wind_direction = EXCLUDED.dd_wind_direction,
    ff_wind_speed = EXCLUDED.ff_wind_speed,
    ff10_max_gust_value = EXCLUDED.ff10_max_gust_value,
    ww_present = EXCLUDED.ww_present,
    ww_recent = EXCLUDED.ww_recent,
    c_total_clouds = EXCLUDED.c_total_clouds,
    vv_horizontal_visibility = EXCLUDED.vv_horizontal_visibility,
    td_temperature_dewpoint = EXCLUDED.td_temperature_dewpoint,
    loaded_ts = EXCLUDED.loaded_ts;

   
   
   
   DELETE FROM etl.load_kdz41_weather
WHERE EXISTS (SELECT 1 FROM etl.temp_new_weather_41);

INSERT INTO etl.load_kdz41_weather(loaded_ts)
SELECT ts2
FROM etl.temp_new_weather_41
WHERE EXISTS (SELECT 1 FROM etl.temp_new_weather_41);