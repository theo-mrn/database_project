SELECT 
    FLOOR(EXTRACT(YEAR FROM m.release_date) / 10) * 10 AS decade,
    AVG(f.profit) AS avg_profit
FROM 
    Movies m
JOIN 
    Production p ON m.id = p.movie_id
JOIN 
    Financials f ON m.id = f.movie_id
GROUP BY 
    FLOOR(EXTRACT(YEAR FROM m.release_date) / 10) * 10, 
    p.production_country
HAVING 
    AVG(f.profit) > 0
ORDER BY 
    avg_profit DESC;

WITH GlobalVoteStats AS (
    SELECT 
        AVG(vote_average) AS global_avg_vote
    FROM 
        Votes
)

-- 2 profits générés par les films de chaque réalisateur.
SELECT 
    p.name AS director, 
    SUM(f.profit) AS total_profit
FROM 
    People p
JOIN 
    Financials f ON p.movie_id = f.movie_id
WHERE 
    p.role = 'Director'
GROUP BY 
    p.name
ORDER BY 
    total_profit DESC
FETCH FIRST 10 ROWS ONLY;


SELECT 
    p.name AS director, 
    COUNT(p.movie_id) AS number_of_movies,
    SUM(f.profit) AS total_profit,
    ROUND(SUM(f.profit) / COUNT(p.movie_id), 2) AS profit_per_movie
FROM 
    People p
JOIN 
    Financials f ON p.movie_id = f.movie_id
WHERE 
    p.role = 'Director'
GROUP BY 
    p.name
ORDER BY 
    total_profit DESC
FETCH FIRST 10 ROWS ONLY;


--  3 votes moyens par budget des films 
SELECT 
    CASE 
        WHEN f.budget < 1000000 THEN 'Low Budget (<1M)'
        WHEN f.budget BETWEEN 1000000 AND 10000000 THEN 'Mid Budget (1M-10M)'
        WHEN f.budget > 10000000 THEN 'High Budget (>10M)'
    END AS budget_range,
    AVG(v.vote_average) AS avg_vote,
    COUNT(*) AS movie_count
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
JOIN 
    Votes v ON m.id = v.movie_id
GROUP BY 
    CASE 
        WHEN f.budget < 1000000 THEN 'Low Budget (<1M)'
        WHEN f.budget BETWEEN 1000000 AND 10000000 THEN 'Mid Budget (1M-10M)'
        WHEN f.budget > 10000000 THEN 'High Budget (>10M)'
    END
ORDER BY 
    avg_vote DESC;



select * from Movies where id=1;

--4 Films les plus longs 
SELECT 
    m.original_language,
    m.ORIGINAL_TITLE,
    m.runtime
FROM 
    Movies m
JOIN (
    SELECT 
        original_language, 
        AVG(runtime) AS avg_runtime
    FROM 
       Movies
    GROUP BY 
        original_language
) lang_avg ON m.original_language = lang_avg.original_language
WHERE 
    m.runtime > lang_avg.avg_runtime;



-- 5 Rank Movies Based on Profit  
SELECT 
    m.title, 
    f.profit, 
    RANK() OVER (ORDER BY f.profit DESC) AS profit_rank
FROM 
    Movies m
JOIN 
    ADMIN_USER.Financials f ON m.id = f.movie_id
ORDER BY 
    profit_rank ASC
FETCH FIRST 15 ROWS ONLY;


-- Temps moyen par réalisateur 
SELECT 
    p.name AS director, 
    TRUNC(AVG(m.runtime) / 60) || ' ' || 
    CASE 
        WHEN TRUNC(AVG(m.runtime) / 60) = 1 THEN 'heure' 
        ELSE 'heures' 
    END || ' ' || 
    MOD(TRUNC(AVG(m.runtime)), 60) || ' ' || 
    CASE 
        WHEN MOD(TRUNC(AVG(m.runtime)), 60) = 1 THEN 'minute' 
        ELSE 'minutes' 
    END AS avg_runtime, 
    COUNT(m.id) AS movie_count
FROM 
    People p
JOIN 
    Movies m ON p.movie_id = m.id
WHERE 
    p.role = 'Director' 
GROUP BY 
    p.name
HAVING 
    COUNT(m.id) > 2 
ORDER BY 
    AVG(m.runtime) DESC;


-- Films les plus populaires par réalisateur
SELECT 
    p.name AS director, 
    m.title, 
    v.popularity
FROM 
    People p
JOIN 
    Movies m ON p.movie_id = m.id
JOIN 
    Votes v ON m.id = v.movie_id
WHERE 
    p.role = 'Director' AND
    (p.name, v.popularity) IN (
        SELECT 
            p.name, 
            MAX(v.popularity)
        FROM 
            People p
        JOIN 
            Movies m ON p.movie_id = m.id
        JOIN 
            Votes v ON m.id = v.movie_id
        WHERE 
            p.role = 'Director'
        GROUP BY 
            p.name
    )
ORDER BY 
    v.popularity DESC;








-- 6 films avec un ratio revenu/budget
SELECT 
    m.title, 
    f.budget, 
    f.revenue, 
    (f.revenue - NULLIF(f.budget, 0)) AS profit
FROM 
    ADMIN_USER.Movies m
JOIN 
    ADMIN_USER.Financials f ON m.id = f.movie_id
WHERE 
    f.budget > 0
ORDER BY 
    profit DESC
FETCH FIRST 10 ROWS ONLY;


-- 7 Liste des films ayant le plus grand nombre de votes 
SELECT 
    m.title, 
    v.vote_count, 
    v.vote_average
FROM 
    Movies m
JOIN 
    Votes v ON m.id = v.movie_id
ORDER BY 
    v.vote_count DESC
FETCH FIRST 10 ROWS ONLY;




-- 8 Analyser les revenus par langue d'origine des films OK
SELECT 
    m.original_language, 
    COUNT(*) AS movie_count, 
    SUM(f.revenue) AS total_revenue, 
    AVG(f.revenue) AS avg_revenue
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
GROUP BY 
    m.original_language
ORDER BY 
    total_revenue DESC;








--9 Identifier les réalisateurs les plus actifs 
SELECT 
    p.name AS director, 
    COUNT(*) AS movie_count
FROM 
    People p
WHERE 
    p.role = 'Director'
GROUP BY 
    p.name
ORDER BY 
    movie_count DESC
FETCH FIRST 5 ROWS ONLY;



-- 10 Trouver les films les mieux notés dans chaque langue OK
SELECT 
    m.original_language, 
    m.title, 
    v.vote_average
FROM 
    Movies m
JOIN 
    Votes v ON m.id = v.movie_id
WHERE 
    v.vote_average = (
        SELECT 
            MAX(vote_average)
        FROM 
            Votes v2
        JOIN 
            Movies m2 ON v2.movie_id = m2.id
        WHERE 
            m2.original_language = m.original_language
    )
ORDER BY 
    m.original_language;

-- 11 Classement des films par popularité par décennie  OK
SELECT 
    FLOOR(EXTRACT(YEAR FROM m.release_date) / 10) * 10 AS decade, 
    m.title, 
    v.popularity
FROM 
    Movies m
JOIN 
    Votes v ON m.id = v.movie_id
ORDER BY 
    decade, 
    v.popularity DESC;




-- 12 Trouver les films ayant des profits en dessous d’une valeur moyenne OK
WITH AverageProfit AS (
    SELECT 
        AVG(profit) AS avg_profit
    FROM 
        Financials
)
SELECT 
    m.title, 
    f.profit
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id, 
    AverageProfit
WHERE 
    f.profit < AverageProfit.avg_profit
ORDER BY 
    f.profit ASC
FETCH FIRST 15 ROWS ONLY;

SELECT 
    m.title, 
    f.profit
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
ORDER BY 
    f.profit ASC
FETCH FIRST 10 ROWS ONLY;







SELECT 
    FLOOR(EXTRACT(YEAR FROM m.release_date) / 10) * 10 AS decade, 
    AVG(v.vote_average) AS avg_vote,
    AVG(v.popularity) AS avg_popularity
FROM 
    Movies m
JOIN 
    Votes v ON m.id = v.movie_id
GROUP BY 
    FLOOR(EXTRACT(YEAR FROM m.release_date) / 10) * 10
ORDER BY 
    decade;
