psql -d expdb -U marko

CREATE TABLE ephor(timestamp TIMESTAMP,
                    device VARCHAR, 
                    temperature NUMERIC,
                    humidity real,
                    pressure real,
                    PM1 real,
                    PM2_5 real,
                    PM10 real,
                    PC0_3 real,
                    PC0_5 real,
                    PC1 real,
                    PC2_5 real,
                    PC5 real,
                    PC10 real,
                    UV_B real,
                    light real,
                    sound real);
COPY ephor(timestamp, device, temperature, humidity,pressure,PM1,PM2_5,PM10,PC0_3,PC0_5,PC1,PC2_5,PC5,PC10,UV_B, light, sound)
FROM 'EP6_20_110_sen.csv'
DELIMITER ','
CSV HEADER;