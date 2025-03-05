use imdb;
#1.Count the total number of records in each table of the database.
select 'director_mapping', count(movie_id) from director_mapping
union
select 'genre', count(genre) from genre
union
select 'movie' as table_name , count(title) as total_records from movie
union 
select'role_mapping', count(movie_id) from role_mapping
union 
select 'names', count(name) from names
union 
select 'ratings', count(movie_id) from ratings;


#2.Identify which columns in the movie table contain null values.
select 
    count(*) -count(title) as title_nulls,
    count(*) - count(year) as year_nulls,
    count(*) - count(date_published) as date_published_nulls,
    count(*) - count(duration) as duration_nulls,
    count(*) - count(worlwide_gross_income) as worlwide_gross_income_nulls,
    count(*) - count(languages) as languages_nulls,
    count(*) - count(production_company) as production_company_nulls
from movie;


#3.Determine the total number of movies released each year, and analyze how the trend changes month-wise.
select year(date_published) as release_year ,month(date_published)as release_month,
count(*) as total_movie
from movie
group by release_year, release_month 
order by release_year, release_month;

#4. How many movies were produced in either the USA or India in the year 2019
select count(title),year,country
from movie
where country in ( 'USA','INDIA') and year=2019
group by country ;

#5. List the unique genres in the dataset, and count how many movies belong exclusively to one genre.
select 
    (select count(distinct genre) from genre) as unique_genres,
    (select count(movie_id) 
     from(select movie_id 
           from genre 
           group by movie_id 
           having count(genre) = 1)as single_genre_movies) as exclusive_genre_movies;

#6Which genre has the highest total number of movies produced?
select genre,count(movie_id) as count_movies
from genre
group by genre
order by count_movies desc
limit 1;

#7. Calculate the average movie duration for each genre.
select g.genre,avg(m.duration) as movie_duration
from movie m
join genre g on m.id=g.movie_id
group by g.genre
order by movie_duration desc;

#8.Identify actors or actresses who have appeared in more than three movies with an average rating below 5.
select n.name,rm.name_id, count(r.movie_id) as rated_movies
from role_mapping rm
join ratings r on rm.movie_id = r.movie_id
join names n on rm.name_id = n.id
where r.avg_rating < 5
group by rm.name_id
having count(r.movie_id) > 3;

#9.Find the minimum and maximum values for each column in the ratings table, excluding the movie_id column.
select 
    min(avg_rating) as min_avg_rating, 
    max(avg_rating) as max_avg_rating,
    min(total_votes) as min_total_votes, 
    max(total_votes) as max_total_votes,
    min(median_rating) as min_median_rating, 
    max(median_rating) as max_median_rating
from ratings;

#10.Which are the top 10 movies based on their average rating?
select m.title,r.avg_rating
from movie m
join ratings r on m.id=r.movie_id
order by avg_rating desc
limit 10;

#11.Summarize the ratings table by grouping movies based on their median ratings.
select 
    median_rating,
    COUNT(movie_id) as movie_count
from ratings
group by median_rating
order by median_rating desc;

#12.How many movies, released in March 2017 in the USA within a specific genre, had more than 1,000 votes?
select count(distinct m.id) as movie_count
from movie m
join ratings r on m.id = r.movie_id
join genre g on m.id = g.movie_id
where m.date_published between '2017-03-01' and '2017-03-31'
and m.country = 'USA'
and r.total_votes > 1000;

#13. Find movies from each genre that begin with the word “The” and have an average rating greater than 8.
select g.genre, m.title, r.avg_rating
from movie m
join ratings r on m.id = r.movie_id
join genre g on m.id = g.movie_id
where m.title like'The %' and r.avg_rating > 8;

#14. Of the movies released between April 1, 2018, and April 1, 2019, how many received a median rating of 8?

select count(title) as movie_count
from movie m
join ratings r on m.id = r.movie_id
where m.date_published between '2018-04-01' and '2019-04-01' and r.median_rating = 8;

#15. Do German movies receive more votes on average than Italian movies?
select m.country, avg(r.total_votes) as avg_votes
from movie m
join ratings r on m.id = r.movie_id
where m.country in ('Germany', 'Italy')
group by m.country;

#16. Identify the columns in the names table that contain null values.

select 
    count(*) -count(id) as id_nulls,
    count(*) - count(name) as name_nulls,
    count(*) - count(height) as height_nulls,
    count(*) - count(date_of_birth) as birth_nulls,
    count(*) - count(known_for_movies) as movie_nulls
from names;

#17. Who are the top two actors whose movies have a median rating of 8 or higher?
select rm.name_id,n.name,r.median_rating
from role_mapping rm
join names n on rm.name_id=n.id
join ratings r on rm.movie_id=r.movie_id
where rm.category like 'actor' and r.median_rating >= 8
order by median_rating desc
limit 2;

#18. Which are the top three production companies based on the total number of votes their movies received?

select m.production_company, sum(r.total_votes) as total_votes
from movie m
join ratings r on m.id = r.movie_id
group by m.production_company
order by total_votes desc
limit 3;

#19. How many directors have worked on more than three movies?

select count(name_id) as director_count
from (
    select name_id
    from director_mapping
    group by name_id
    having count(movie_id) > 3
) as director_count;

#20. Calculate the average height of actors and actresses separately.
select rm.category, avg(n.height) as avg_height
from role_mapping rm
join names n on rm.name_id = n.id
where rm.category in ('actor', 'actress')
group by rm.category;

#21. List the 10 oldest movies in the dataset along with their title, country, and director.
select m.title,m.country,n.name as diroctor,m.date_published
from movie m
join director_mapping d on m.id=d.movie_id
join names n on d.name_id=n.id
order by m.date_published asc
limit 10;

#22. List the top 5 movies with the highest total votes, along with their genres.

select m.title,group_concat(distinct g.genre) as genre ,r.total_votes as total_vote
from movie m
join ratings r on m.id=r.movie_id
join genre g on r.movie_id=g.movie_id
group by m.id
order by total_vote desc
limit 5;
#23. Identify the movie with the longest duration, along with its genre and production company.
select m.title, m.duration, g.genre, m.production_company as production_company
from movie m
join genre g on m.id = g.movie_id
where m.duration = (select max(duration) from movie);

#24. Determine the total number of votes for each movie released in 2018.
select m.title,m.year,r.total_votes as total_vote
from movie m
join ratings r on m.id=r.movie_id
where m.year='2018'
order by total_vote desc;

#25. What is the most common language in which movies were produced?
select languages, count(languages) as movie_count
from movie
group by languages
order by movie_count desc
limit 1;


