SELECT * FROM netflix_show_data;
-------------------------------------------------------------------------------------------------------
-- 1.Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT(show_id) AS total_shows
FROM netflix_show_data
GROUP BY type;

-- 2.Find the most common rating for movies and TV shows

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

-- 3.List all movies released in a specific year (e.g., 2020)

SELECT
	*
FROM netflix_show_data
WHERE release_year IN (2020)
	  AND
	  type IN ('Movie');


-- 4.Find the top 5 countries with the most content on Netflix

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) AS country,
	COUNT(show_id) AS total_shows
FROM netflix_show_data
WHERE country IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- 5.Identify the longest movie

SELECT
	type,
	title,
	REGEXP_REPLACE(duration, '[^0-9]', '', 'g') ::INTEGER AS minutes
FROM netflix_show_data
WHERE type IN ('Movie')
ORDER BY 3 DESC NULLS LAST
LIMIT 1;

--	6.Find content added in the last 5 years

SELECT 
	* 
FROM netflix_show_data
WHERE date_added >= CURRENT_DATE - INTERVAL '5 YEAR';

-- 7.Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT 
	* 
FROM netflix_show_data
WHERE director IS NOT NULL
	  AND
	  director ILIKE ('%Rajiv Chilaka%');

-- 8.List all TV shows with more than 5 seasons

SELECT
	* 
FROM netflix_show_data
WHERE type IN ('TV Show')
	  AND
	  REGEXP_REPLACE(duration, '[^0-9]', '', 'g') ::INTEGER >5;

-- 9.Count the number of content items in each genre

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(listed_in,','))) AS genre,
	COUNT(show_id) AS total_show
FROM netflix_show_data
GROUP BY 1;

-- 10.Find each year and the average numbers of content release in India on netflix. 
--    return top 10 year with highest avg content release

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

-- 11.List all movies that are documentaries

SELECT
	*
FROM netflix_show_data
WHERE listed_in ILIKE ('%Documentaries%');

-- 12.Find all content without a director

SELECT
	*
FROM netflix_show_data
WHERE director IS NULL;

-- 13.Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT
	*
FROM netflix_show_data
WHERE casts ILIKE ('%Salman Khan%')
	  AND
	  release_year::INTEGER >= EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- 14.Find the top 10 actors who have appeared in the highest number of movies produced in India.

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

/*
15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
    the description field. Label content containing these keywords as 'Bad' and all other 
    content as 'Good'. Count how many items fall into each category.
*/

SELECT
	CASE 
		WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
		ELSE 'Good'
	END as Category,
	COUNT(show_id) AS content_count
FROM netflix_show_data
GROUP BY 1;
