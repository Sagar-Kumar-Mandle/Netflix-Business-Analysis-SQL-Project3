DROP TABLE IF EXISTS netflix_show_data;

CREATE TABLE IF NOT EXISTS netflix_show_data(
	show_id 		VARCHAR(8) 	PRIMARY KEY,
	type  			VARCHAR(8),
	title			TEXT,
	director		TEXT,
	casts 			TEXT,
	country			TEXT,
	date_added  	DATE,
	release_year 	BIGINT,
	rating			VARCHAR(16),
	duration 		VARCHAR(16),
	listed_in		TEXT,
	description 	TEXT
);

COPY netflix_show_data(show_id,type,title,director,casts,country,date_added,release_year,rating,duration,listed_in,description)
FROM 'D:\VCE\Sagar BCC\1) GIT HUB\2) SQL\1) Data Analysis Portifolio\3) Netflix Data Analysis\1) CSV Files\netflix_titles.csv'
DELIMITER','
HEADER CSV

SELECT * FROM netflix_show_data;