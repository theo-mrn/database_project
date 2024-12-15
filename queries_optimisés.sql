SELECT 
    decade, 
    avg_profit
FROM 
    mv_avg_profit_by_decade
WHERE 
    avg_profit > 0
ORDER BY 
    avg_profit DESC;



--2 
SELECT 
    director, 
    total_profit
FROM 
    mv_director_activity
ORDER BY 
    total_profit DESC
FETCH FIRST 10 ROWS ONLY;



--3
SELECT 
    CASE 
        WHEN f.budget < 1000000 THEN 'Low Budget (<1M)'
        WHEN f.budget BETWEEN 1000000 AND 10000000 THEN 'Mid Budget (1M-10M)'
        ELSE 'High Budget (>10M)'
    END AS budget_range,
    AVG(v.vote_average) AS avg_vote,
    COUNT(*) AS movie_count
FROM 
    Financials f
JOIN 
    Votes v ON f.movie_id = v.movie_id
GROUP BY 
    CASE 
        WHEN f.budget < 1000000 THEN 'Low Budget (<1M)'
        WHEN f.budget BETWEEN 1000000 AND 10000000 THEN 'Mid Budget (1M-10M)'
        ELSE 'High Budget (>10M)'
    END
ORDER BY 
    avg_vote DESC;


--4
WITH avg_runtime_per_language AS (
    SELECT 
        original_language, 
        AVG(runtime) AS avg_runtime
    FROM 
        Movies
    GROUP BY 
        original_language
)
SELECT 
    m.original_language,
    m.title,
    m.runtime
FROM 
    Movies m
JOIN 
    avg_runtime_per_language lang_avg 
    ON m.original_language = lang_avg.original_language
WHERE 
    m.runtime > lang_avg.avg_runtime;


--5
SELECT 
    m.title, 
    f.profit, 
    RANK() OVER (ORDER BY f.profit DESC) AS profit_rank
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
FETCH FIRST 15 ROWS ONLY;


--6
SELECT 
    m.title, 
    f.budget, 
    f.revenue, 
    (f.revenue / NULLIF(f.budget, 0)) AS revenue_to_budget_ratio
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
WHERE 
    f.budget > 0
ORDER BY 
    revenue_to_budget_ratio DESC
FETCH FIRST 10 ROWS ONLY;



--7
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


--8
SELECT 
    original_language, 
    movie_count, 
    total_revenue, 
    avg_revenue
FROM 
    mv_revenue_by_language
ORDER BY 
    total_revenue DESC;


--9
SELECT 
    director, 
    movie_count
FROM 
    mv_director_activity
ORDER BY 
    movie_count DESC
FETCH FIRST 5 ROWS ONLY;



--10
WITH max_votes_per_language AS (
    SELECT 
        m.original_language, 
        MAX(v.vote_average) AS max_vote
    FROM 
        Movies m
    JOIN 
        Votes v ON m.id = v.movie_id
    GROUP BY 
        m.original_language
)
SELECT 
    m.original_language, 
    m.title, 
    v.vote_average
FROM 
    Movies m
JOIN 
    Votes v ON m.id = v.movie_id
JOIN 
    max_votes_per_language mv 
    ON m.original_language = mv.original_language 
    AND v.vote_average = mv.max_vote
ORDER BY 
    m.original_language;



--11
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


--12
WITH avg_profit AS (
    SELECT AVG(profit) AS avg_profit FROM Financials
)
SELECT 
    m.title, 
    f.profit
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
JOIN 
    avg_profit ap 
    ON f.profit < ap.avg_profit
ORDER BY 
    f.profit ASC
FETCH FIRST 15 ROWS ONLY;

