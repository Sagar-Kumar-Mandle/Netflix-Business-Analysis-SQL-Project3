# Netflix Business Analysis - SQL

## 📌Table of Contents
- [Overview](#overview)
- [Objective](#objective)
- [Dataset](#dataset)
- [Project Structure](#project-structure)
- [SQL Database](#sql-database)
    - [Database Schema](#database-schema)
    - [Data Analysis](#data-analysis)
- [Key Findings](#key-findings)
- [Author & Contact](#author--contact)

---

## Overview
<p align="justify">
In this project, I analyzed Netflix’s movies and TV shows data with SQL to uncover interesting insights and answer business-related questions. This README walks through the project’s goals, challenges, SQL queries used, main findings, and final takeaways.
</p>

---

## Objective
1. Database Creation - Create a database and table for the datasets. Insert data from the CSV file into the SQL database.
2. Business Analysis - Use a SQL tool to derive insights from data and solve specific business-related questions.

--- 

## Dataset

The data used in this project is sourced from a publicly available Netflix dataset on Kaggle.

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows)

--

## Project Structure
```
Netflix-Business-Analysis-SQL-Project3/
│
├── 1) CSV File /           #CSV Data
│      └── netflix_titles.csv
│
├── 2) Datasets /           #Database
│       ├── 1) Database.sql
│       └── 2) Table.sql      
│
├── Questions.sql           
├── README.md
├── Netflix_Business_SQL_Analysis.sql
│

```

---

## SQL Database

### Database Schema
- Database Creation

```sql
CREATE DATABASE netflix_website;
```

- Table Creation

```sql
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
```

### Data Analysis

1. **Count the number of Movies vs TV Shows**

```sql
SELECT
	type,
	COUNT(show_id) AS total_shows
FROM netflix_show_data
GROUP BY type;
```

2. **Find the most common rating for movies and TV shows**

```sql
WITH rankedrating AS
(
SELECT
	type,
	rating,
	COUNT(rating) AS rating_count
FROM netflix_show_data
GROUP BY 1,2
),
top1 AS
(
SELECT
	*,
	DENSE_RANK() OVER (PARTITION BY type ORDER BY rating_count DESC ) AS rno
FROM rankedrating
)
SELECT
	type,
	rating,
	rating_count
FROM top1
WHERE rno=1;
```

3. **List all movies released in a specific year (e.g., 2020)**

```sql
SELECT
	*
FROM netflix_show_data
WHERE release_year IN (2020)
	  AND
	  type IN ('Movie');
```

4. **Find the top 5 countries with the most content on Netflix**

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country,
	COUNT(show_id) AS total_shows
FROM netflix_show_data
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
```

5. **Identify the longest movie**

```sql
SELECT
	type,
	title,
	REGEXP_REPLACE(duration, '[^0-9]', '', 'g') ::INTEGER AS minutes
FROM netflix_show_data
WHERE type IN ('Movie')
ORDER BY 3 DESC NULLS LAST
LIMIT 1;
```
6. **Find content added in the last 5 years**

```sql
SELECT 
	* 
FROM netflix_show_data
WHERE date_added >= CURRENT_DATE - INTERVAL '5 YEAR';
```

7. **Find all the movies/TV shows by director 'Rajiv Chilaka'**
```sql

SELECT 
	* 
FROM netflix_show_data
WHERE director IS NOT NULL
	  AND
	  director ILIKE ('%Rajiv Chilaka%');
```

8. **List all TV shows with more than 5 seasons**

```sql
SELECT
	* 
FROM netflix_show_data
WHERE type IN ('TV Show')
	  AND
	  REGEXP_REPLACE(duration, '[^0-9]', '', 'g') ::INTEGER >5;
```

9. **Count the number of content items in each genre**

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
	COUNT(show_id) AS total_show
FROM netflix_show_data
GROUP BY 1;
```

10. **Find each year and the average numbers of content release in India on netflix. return top 10 year with highest avg content release**

```sql
WITH CTE AS
(
SELECT 
	DISTINCT
		release_year,
		count(release_year) over () AS total_shows,
		count(release_year) over (partition by release_year) AS total_shows_year
FROM netflix_show_data 
WHERE country ILIKE ('%India%')
ORDER BY 3 DESC
)
SELECT
	release_year,
	total_shows_year, 
	ROUND(total_shows_year * 100.0 / total_shows,2) AS average_content_release
FROM CTE
LIMIT 10;
```

11. **List all movies that are documentaries**

```sql
SELECT
	*
FROM netflix_show_data
WHERE listed_in ILIKE ('%Documentaries%');
```

12. **Find all content without a director**

```sql
SELECT
	*
FROM netflix_show_data
WHERE director IS NULL;
```

13. **Find how many movies actor 'Salman Khan' appeared in last 10 years**

```sql
SELECT
	*
FROM netflix_show_data
WHERE casts ILIKE ('%Salman Khan%')
	  AND
	  release_year::INTEGER >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

14. **Find the top 10 actors who have appeared in the highest number of movies produced in India.**

```sql
WITH top10 AS
(
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) AS performer,
	country,
	show_id
FROM netflix_show_data
WHERE country ILIKE ('%India%')
)
SELECT
	performer,
	COUNT(show_id) AS total_apperances
FROM top10
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```


15. **Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.**

```sql
SELECT
	CASE 
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END as Category,
	COUNT(show_id) AS content_count
FROM netflix_show_data
GROUP BY 1;
```

---

##  Key Findings

- Library: 69% of Netflix’s content library consists of movies.
- Origin of Content: Nearly half of the catalog originates from the USA, India, and the UK.
- Content Distribution: Netflix offers a diverse mix of movies and TV shows across multiple genres and ratings.
- Common Ratings: The most frequent ratings highlight the platform’s primary target audience.
- Actors: Several actors appear frequently, with a notable concentration in Indian productions.


---

## Author & Contact

**Sagar Kumar Mandle**   
📧 Email: sagarmandle11135@gmail.com 

🔗 [LinkedIn](https://www.linkedin.com/in/sagar-kumar-mandle-7086ba366/)