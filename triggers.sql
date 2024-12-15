CREATE TABLE admin_user.audit_log (
    log_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    table_name VARCHAR2(50),
    action_type VARCHAR2(10),
    action_time DATE DEFAULT SYSDATE,
    user_id VARCHAR2(30),
    details CLOB
);



CREATE OR REPLACE TRIGGER set_default_schema
AFTER LOGON ON DATABASE
BEGIN
    IF USER IN ('USER1', 'USER2', 'USER3') THEN
        EXECUTE IMMEDIATE 'ALTER SESSION SET CURRENT_SCHEMA = admin_user';
    END IF;
END;
/


-- Enregistre dans une table de logs (audit_log) toutes les actions (INSERT, UPDATE, DELETE) effectuées sur la table Movies.

CREATE OR REPLACE TRIGGER admin_user.trg_people_audit
AFTER INSERT OR UPDATE OR DELETE
ON admin_user.People
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('People', 'INSERT', SYSDATE, USER, :NEW.name || ' was added.');
    ELSIF UPDATING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('People', 'UPDATE', SYSDATE, USER, :OLD.name || ' updated to ' || :NEW.name);
    ELSIF DELETING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('People', 'DELETE', SYSDATE, USER, :OLD.name || ' was deleted.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER admin_user.trg_movies_audit
AFTER INSERT OR UPDATE OR DELETE
ON admin_user.Movies
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Movies', 'INSERT', SYSDATE, USER, :NEW.title || ' was added.');
    ELSIF UPDATING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Movies', 'UPDATE', SYSDATE, USER, :OLD.title || ' updated to ' || :NEW.title);
    ELSIF DELETING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Movies', 'DELETE', SYSDATE, USER, :OLD.title || ' was deleted.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER admin_user.trg_financials_audit
AFTER INSERT OR UPDATE OR DELETE
ON admin_user.Financials
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Financials', 'INSERT', SYSDATE, USER, 'Record was added.');
    ELSIF UPDATING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Financials', 'UPDATE', SYSDATE, USER, 'Record was updated.');
    ELSIF DELETING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Financials', 'DELETE', SYSDATE, USER, 'Record was deleted.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER admin_user.trg_votes_audit
AFTER INSERT OR UPDATE OR DELETE
ON admin_user.Votes
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Votes', 'INSERT', SYSDATE, USER, 'Vote was added.');
    ELSIF UPDATING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Votes', 'UPDATE', SYSDATE, USER, 'Vote was updated.');
    ELSIF DELETING THEN
        INSERT INTO admin_user.audit_log (table_name, action_type, action_time, user_id, details)
        VALUES ('Votes', 'DELETE', SYSDATE, USER, 'Vote was deleted.');
    END IF;
END;
/

-- Met à jour la moyenne des votes (vote_average) dans la table Movies après toute modification dans la table Votes

CREATE OR REPLACE TRIGGER admin_user.trg_update_vote_stats
AFTER INSERT OR UPDATE ON admin_user.Votes
FOR EACH ROW
BEGIN
    UPDATE admin_user.Movies
    SET vote_average = (
        SELECT AVG(vote_average)
        FROM admin_user.Votes
        WHERE movie_id = :NEW.movie_id
    )
    WHERE id = :NEW.movie_id;
END;
/



-- Supprime automatiquement les entrées associées dans la table People lorsqu'un film est supprimé de la table Movies

CREATE OR REPLACE TRIGGER admin_user.trg_cascade_people_delete
AFTER DELETE ON admin_user.Movies
FOR EACH ROW
BEGIN
    DELETE FROM admin_user.People WHERE movie_id = :OLD.id;
     DELETE FROM admin_user.Financials WHERE movie_id = :OLD.id;
      DELETE FROM admin_user.People WHERE movie_id = :OLD.id;
      DELETE FROM admin_user.Production WHERE movie_id = :OLD.id;
END;
/





-- Fonctions
SELECT 
    p.name AS director, 
    ROUND(AVG(m.runtime), 2) AS avg_runtime, 
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
    COUNT(m.id) > 2 -- Facultatif : Limiter aux réalisateurs ayant dirigé plus de 2 films
ORDER BY 
    avg_runtime DESC;





-- Calcule la somme totale des revenus dans la table Financials
CREATE OR REPLACE FUNCTION calculate_total_revenue
RETURN NUMBER
IS
    total_revenue NUMBER;
BEGIN
    SELECT SUM(revenue) INTO total_revenue FROM Financials;
    RETURN NVL(total_revenue, 0);
END;
/



-- Compte le nombre de films sortis pour une année donnée.

CREATE OR REPLACE FUNCTION count_movies_by_year(year IN NUMBER)
RETURN NUMBER
IS
    movie_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO movie_count
    FROM Movies
    WHERE EXTRACT(YEAR FROM release_date) = year;
    RETURN movie_count;
END;
/



-- Calcule le profit moyen pour tous les enregistrements dans Financials
CREATE OR REPLACE FUNCTION average_profit
RETURN NUMBER
IS
    avg_profit NUMBER;
BEGIN
    SELECT AVG(profit) INTO avg_profit FROM Financials;
    RETURN NVL(avg_profit, 0);
END;
/

-- Calcule le total des votes pour un film donné
CREATE OR REPLACE FUNCTION total_votes_for_movie(movie_id IN NUMBER)
RETURN NUMBER
IS
    total_votes NUMBER;
BEGIN
    SELECT SUM(vote_count) INTO total_votes FROM Votes WHERE movie_id = movie_id;
    RETURN NVL(total_votes, 0);
END;
/


-- Renvoie le titre du film avec le revenu le plus élevé
CREATE OR REPLACE FUNCTION highest_revenue_movie
RETURN VARCHAR2
IS
    movie_title VARCHAR2(255);
BEGIN
    SELECT title INTO movie_title
    FROM Movies m
    JOIN Financials f ON m.id = f.movie_id
    WHERE f.revenue = (SELECT MAX(revenue) FROM Financials);
    RETURN movie_title;
END;
/




--Procedures 




-- Génère un rapport pour tous les films sortis dans le mois en cour
CREATE OR REPLACE PROCEDURE generate_monthly_movie_report
IS
    CURSOR c_movies IS
        SELECT m.title, f.budget, f.revenue, (f.revenue - f.budget) AS profit
        FROM Movies m
        JOIN Financials f ON m.id = f.movie_id
        WHERE EXTRACT(MONTH FROM m.release_date) = EXTRACT(MONTH FROM SYSDATE)
          AND EXTRACT(YEAR FROM m.release_date) = EXTRACT(YEAR FROM SYSDATE);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Monthly Movie Report:');
    FOR r IN c_movies LOOP
        DBMS_OUTPUT.PUT_LINE('Title: ' || r.title || 
                             ', Budget: ' || r.budget || 
                             ', Revenue: ' || r.revenue || 
                             ', Profit: ' || r.profit);
    END LOOP;
END;
/


--  Supprime les logs anciens selon un seuil en jours.
CREATE OR REPLACE PROCEDURE clean_old_logs(days_threshold IN NUMBER)
IS
    deleted_count NUMBER; 
BEGIN
    DELETE FROM audit_log
    WHERE action_time < SYSDATE - days_threshold
    RETURNING COUNT(*) INTO deleted_count;
    DBMS_OUTPUT.PUT_LINE(deleted_count || ' logs older than ' || days_threshold || ' days have been deleted.');
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No logs found older than ' || days_threshold || ' days.');
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
END;
/



--   Met à jour la popularité d’un film dans la table Votes
CREATE OR REPLACE PROCEDURE update_movie_popularity(movie_id IN NUMBER, new_popularity IN NUMBER)
IS
BEGIN
    UPDATE Votes
    SET popularity = new_popularity
    WHERE movie_id = movie_id;

    DBMS_OUTPUT.PUT_LINE('Popularity for movie ID ' || movie_id || ' has been updated to ' || new_popularity || '.');
    COMMIT;
END;
/




