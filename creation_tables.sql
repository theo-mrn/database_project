-- Table Movies
CREATE TABLE Movies (
    id INT PRIMARY KEY NOT NULL,
    title VARCHAR(255) NOT NULL,
    original_title VARCHAR(255),
    release_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    overview CLOB,
    tagline CLOB,
    homepage VARCHAR(255),
    original_language VARCHAR(10) NOT NULL,
    runtime NUMBER(5, 2),
    genres CLOB
);

-- Table Financials
CREATE TABLE Financials (
    movie_id INT PRIMARY KEY NOT NULL,
    budget NUMBER(15, 2) NOT NULL,
    revenue NUMBER(15, 2) NOT NULL,
    profit NUMBER(15, 2) GENERATED ALWAYS AS (revenue - budget) VIRTUAL,
    CONSTRAINT fk_financials_movie FOREIGN KEY (movie_id) REFERENCES Movies(id)
);

-- Table Votes
CREATE TABLE Votes (
    movie_id INT PRIMARY KEY NOT NULL,
    vote_count INT NOT NULL,
    vote_average NUMBER(3, 1) NOT NULL CHECK (vote_average BETWEEN 0 AND 10),
    popularity NUMBER(10, 6),
    CONSTRAINT fk_votes_movie FOREIGN KEY (movie_id) REFERENCES Movies(id)
);

-- Table Production
CREATE TABLE Production (
    production_id INT PRIMARY KEY,
    movie_id INT NOT NULL,
    production_company VARCHAR(255) NOT NULL,
    production_country VARCHAR(100) NOT NULL,
    CONSTRAINT fk_production_movie FOREIGN KEY (movie_id) REFERENCES Movies(id)
);

-- Table People
CREATE TABLE People (
    person_id INT PRIMARY KEY,
    movie_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100) NOT NULL,
    CONSTRAINT fk_people_movie FOREIGN KEY (movie_id) REFERENCES Movies(id)
);





ALTER TABLE admin_user.Votes
DROP CONSTRAINT FK_VOTES_MOVIE;

ALTER TABLE admin_user.Votes
ADD CONSTRAINT FK_VOTES_MOVIE
FOREIGN KEY (movie_id) REFERENCES admin_user.Movies(id) ON DELETE CASCADE;

ALTER TABLE admin_user.Financials
DROP CONSTRAINT FK_FINANCIALS_MOVIE;

ALTER TABLE admin_user.Financials
ADD CONSTRAINT FK_FINANCIALS_MOVIE
FOREIGN KEY (movie_id) REFERENCES admin_user.Movies(id) ON DELETE CASCADE;

ALTER TABLE admin_user.Production
DROP CONSTRAINT FK_PRODUCTION_MOVIE;

ALTER TABLE admin_user.Production
ADD CONSTRAINT FK_PRODUCTION_MOVIE
FOREIGN KEY (movie_id) REFERENCES admin_user.Movies(id) ON DELETE CASCADE;

ALTER TABLE admin_user.People
DROP CONSTRAINT FK_PEOPLE_MOVIE;

ALTER TABLE admin_user.People
ADD CONSTRAINT FK_PEOPLE_MOVIE
FOREIGN KEY (movie_id) REFERENCES admin_user.Movies(id) ON DELETE CASCADE;
