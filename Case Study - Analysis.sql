-- database init
use sql_case_study

-- Importing 6 tables into this database manually.
-- I am performing this task using the import method.
-- The data has been successfully imported.

-- Now, checking each table one by one and examining the rows/columns for each table.
select count(*)as total_cnt from movie;
select count(*)as total_cnt from genre;
select count(*)as total_cnt from names;
select count(*)as total_cnt from ratings;
select count(*)as total_cnt from role_mapping;


SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'movie';

select count(1) from movie -- row_count

-- There are 9 columns in the movie dataset.
-- The total shape of the data is (rows: 7997, columns: 9).


--checking head(10)

SELECT *FROM movie LIMIT 100;-- I don't know why this command is not working. I am trying to find another command to display the top 10 rows of the dataset.

--this is working in sql 
SELECT TOP 10 * FROM movie;


-- check total movie= 7997
select count(*)as total_movie from movie



--I need to check the total number of movies until this date, based on the dataset. 
--I can see the following data points: in 2017, the total movie contribution is 38%; in 2018, it is 36%; and in 2019, it is 25%."

SELECT
  year, COUNT(1) AS Total_movie_cnt,
  COUNT(1)as Total_movie,ROUND((COUNT(1) / CAST((SELECT COUNT(1) FROM movie) AS DECIMAL)) * 100, 2) AS Total_pcnt
FROM movie
GROUP BY year
ORDER BY total_movie_cnt DESC;



--I need to print the month-to-month distribution of movies. 

--Since the monthname function is not available in SQL, I am using the CASE function to display the month names. 
--I am interested in identifying the top 5 months where I observe a larger number of movie releases.

--In March, September, January, and October, 10% of the movies were released, while in April, 8% were released.

SELECT TOP 5
  MONTH(date_published) AS Month,
  CASE MONTH(date_published)
	WHEN 1 THEN 'January'
    WHEN 2 THEN 'February'
    WHEN 3 THEN 'March'
    WHEN 4 THEN 'April'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'June'
    WHEN 7 THEN 'July'
    WHEN 8 THEN 'August'
    WHEN 9 THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
  END AS Month_name,count(1)as Total_movie,
  ROUND((COUNT(1) / CAST((SELECT COUNT(1) FROM movie) AS DECIMAL)) * 100, 2)as Total_pcnt
FROM movie
group by   MONTH(date_published),
  CASE MONTH(date_published)
	WHEN 1 THEN 'January'
    WHEN 2 THEN 'February'
    WHEN 3 THEN 'March'
    WHEN 4 THEN 'April'
    WHEN 5 THEN 'May'
    WHEN 6 THEN 'June'
    WHEN 7 THEN 'July'
    WHEN 8 THEN 'August'
    WHEN 9 THEN 'September'
    WHEN 10 THEN 'October'
    WHEN 11 THEN 'November'
    WHEN 12 THEN 'December'
  END
order by  count(1) desc



-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


-- There are some questions to check:
-- 1. First, title-wise.
-- 2. Identify the top 5 movies from each country based on their average rating, with only one movie selected from each country.
-- 3. Duration-wise.
-- 4. Income-wise.
-- 5. Language-wise.


--1 top 5 movie title wise
--output should (movie name,rating)
select top 10 title,avg_rating from movie t1
left join ratings t2
on t1.id=t2.movie_id
order by avg_rating desc

--2 Identify the top 5 movies from each country based on their highest average rating, with only one movie selected from each country.
--output >>>-- Title,Country,Avg_rating

with main as(
	select title,country,avg_rating,ROW_NUMBER()over(partition by country order by avg_rating desc)as rn 
	from movie t1
	left join ratings t2
	on t1.id=t2.movie_id
	where country is not null
)
select top 5 title,country,avg_rating from main
where rn=1
order by avg_rating desc


--3 duration wise --top10 Movie where rating is >= to the total average rating, and the votes are >= the total average votes, duration should be in desc order
--Output >>>-- title,rating,votes,duration in hour

--there are 135 movie list-

with a as(
	select title,duration,country,avg_rating,total_votes from movie t1
	left join ratings t2
	on t1.id=t2.movie_id
	where country='india'
		)
select top 10 title,avg_rating as rating,
			total_votes as vote,round(cast(duration as decimal)/60,2) as Duration
from a
where a.avg_rating>=(select avg(a.avg_rating) from a)
  and a.total_votes>=(select avg(total_votes) from a)
  order by a.duration desc


--4 Income wise >>>>-- top 5 movies for each country based on movie income, with the condition that the year is 2017.
--Output >>>-- country,title,total_income

with main as(
select country,title,worlwide_gross_income,
	   ROW_NUMBER()over(partition by country order by worlwide_gross_income)as rn
from movie t1
left join ratings t2
on t1.id=t2.movie_id
where year='2017'
  and worlwide_gross_income is not null
  )
select main.country,main.title,main.worlwide_gross_income from main
where rn <=5


--5 languge wise >>>-- Need to find the top 1 movies with the highest ratings and highest votes (1 movie for every language).
--Output >>>-- Title,Language,total_vote,Rating

with main as(
select title,languages,total_votes,avg_rating
	   ,ROW_NUMBER()over(partition by languages order by avg_rating desc,total_votes desc) as rn
from movie t1
left join ratings t2
on t1.id=t2.movie_id
where languages is not null
)
select title as Title,languages as Language,total_votes as Vote,avg_rating as rating from main
where rn =1
order by avg_rating desc


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


-- >> Need to find out which actor/actress has done the most films in their career. top 10
--Output >>-- Nmae, Movie count

with t1 as(
select id,name,movie_id,category from names a
join role_mapping b
on a.id=b.name_id)

select top 10 name, count(distinct t1.id)as Movie_count from movie t2
	join t1
	on t2.id=t1.movie_id
group by name
order by count(distinct t1.id) desc


-->> descriptive statistics for movie dataset
--There is one movie which is aound 13 hr >>>'la flor '


SELECT
	COUNT(*) AS Total_count,
	AVG(duration) AS duration_mean,
	SUM(duration) AS duration_sum,
	stdev(duration)as duration_std,
	min(duration)as duration_min,
	max(duration)as duration_max,
	AVG(worlwide_gross_income) AS gorss_income_mean,
	SUM(worlwide_gross_income) AS gorss_income_sum,
	STDEV(worlwide_gross_income)as gorss_income_std,
	min(worlwide_gross_income)as gorss_income_min,
	max(worlwide_gross_income)as gorss_income_max

FROM
movie




