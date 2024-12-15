CREATE INDEX idx_movies_id ON Movies(id);
CREATE INDEX idx_financials_movie_id ON Financials(movie_id);
CREATE INDEX idx_votes_movie_id ON Votes(movie_id);
CREATE INDEX idx_people_movie_id_role ON People(movie_id, role);

CREATE INDEX idx_movies_release_date ON Movies(release_date);
CREATE INDEX idx_financials_profit ON Financials(profit);
CREATE INDEX idx_votes_vote_average ON Votes(vote_average);
CREATE INDEX idx_votes_vote_count ON Votes(vote_count);
CREATE INDEX idx_movies_original_language ON Movies(original_language);

CREATE INDEX idx_movies_id_original_language ON Movies(id, original_language);
CREATE INDEX idx_movies_id_release_date ON Movies(id, release_date);
CREATE INDEX idx_financials_budget_revenue ON Financials(budget, revenue);
CREATE INDEX idx_votes_movie_id_vote_average ON Votes(movie_id, vote_average);

CREATE MATERIALIZED VIEW mv_avg_profit_by_decade AS
SELECT 
    FLOOR(EXTRACT(YEAR FROM release_date) / 10) * 10 AS decade,
    AVG(profit) AS avg_profit
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
GROUP BY 
    FLOOR(EXTRACT(YEAR FROM release_date) / 10) * 10;





    

CREATE MATERIALIZED VIEW mv_global_vote_stats AS
SELECT 
    AVG(vote_average) AS global_avg_vote
FROM 
    Votes;







CREATE MATERIALIZED VIEW mv_revenue_by_language AS
SELECT 
    original_language,
    COUNT(*) AS movie_count,
    SUM(revenue) AS total_revenue,
    AVG(revenue) AS avg_revenue
FROM 
    Movies m
JOIN 
    Financials f ON m.id = f.movie_id
GROUP BY 
    original_language;






CREATE MATERIALIZED VIEW mv_director_activity AS
SELECT 
    name AS director, 
    COUNT(*) AS movie_count, 
    SUM(f.profit) AS total_profit
FROM 
    People p
JOIN 
    Financials f ON p.movie_id = f.movie_id
WHERE 
    p.role = 'Director'
GROUP BY 
    name;
