CREATE TABLE src.kdz_41_flights (
 "year" int4 NOT NULL,
 quarter int4 NULL,
 "month" int4 NOT NULL,
 flight_date varchar NOT NULL,
 reporting_airline varchar(10) NULL,
 tail_number varchar(10) NULL,
 flight_number varchar(15) NOT NULL,
 origin varchar(15) NULL,
 dest varchar(10) NULL,
 crs_dep_time int4 NOT NULL,
 dep_time int4 NULL,
 dep_delay_minutes float8 NULL,
 cancelled float8 NOT NULL,
 cancellation_code bpchar(1) NULL,
 air_time float8 NULL,
 distance float8 NULL,
 weather_delay float8 NULL,
 loaded_ts timestamp NOT NULL DEFAULT now()
);

CREATE TABLE src.kdz_41_weather (
 icao_code varchar(10) NOT null,
 local_datetime varchar(25) NOT NULL,
 t_air_temperature numeric(3, 1) NULL,
 p0_sea_lvl numeric(4, 1) NULL,
 p_station_lvl numeric(4, 1) NULL,
 u_humidity int4 NULL,
 dd_wind_direction varchar(100) NULL,
 ff_wind_speed int4 NULL,
 ff10_max_gust_value int4 NULL,
 ww_present varchar(100) NULL,
 ww_recent varchar(50) NULL,
 c_total_clouds varchar(200) NULL,
 vv_horizontal_visibility numeric(3, 1) NULL,
 td_temperature_dewpoint numeric(3, 1) NULL,
 loaded_ts timestamp NOT NULL DEFAULT now()
);