-- Administrateur
CREATE USER admin_user IDENTIFIED BY AdminPassword123;
GRANT CONNECT, RESOURCE, DBA TO admin_user;

-- Gestionnaire
CREATE USER manager_user IDENTIFIED BY ManagerPassword123;
GRANT CONNECT TO manager_user;

-- Utilisateur standard
CREATE USER regular_user IDENTIFIED BY RegularPassword123;
GRANT CONNECT TO regular_user;





-- Admin 
GRANT ALL PRIVILEGES ON Movies TO admin_user;
GRANT ALL PRIVILEGES ON Financials TO admin_user;
GRANT ALL PRIVILEGES ON Votes TO admin_user;
GRANT ALL PRIVILEGES ON Production TO admin_user;
GRANT ALL PRIVILEGES ON People TO admin_user;
-- Gestionnaire
GRANT SELECT, INSERT, UPDATE ON Movies TO manager_user;
GRANT SELECT, INSERT, UPDATE ON Financials TO manager_user;
GRANT SELECT, INSERT, UPDATE ON Votes TO manager_user;
GRANT SELECT, INSERT, UPDATE ON Production TO manager_user;
GRANT SELECT, INSERT, UPDATE ON People TO manager_user;
-- utilisateur standard
GRANT SELECT ON Movies TO regular_user;
GRANT SELECT ON Financials TO regular_user;
GRANT SELECT ON Votes TO regular_user;
GRANT SELECT ON Production TO regular_user;
GRANT SELECT ON People TO regular_user;



-- Sécurilsation des données 
ALTER PROFILE DEFAULT LIMIT
    PASSWORD_LIFE_TIME 90
    PASSWORD_REUSE_TIME 180
    PASSWORD_REUSE_MAX 5
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1;




-- On a un audit 
AUDIT ALL BY admin_user;
AUDIT SELECT, INSERT, UPDATE, DELETE ON Movies BY SESSION;



-- on limite l'acces aux données sensibles
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'your_schema',
        object_name     => 'Financials',
        policy_name     => 'mask_sensitive_data',
        function_schema => 'your_schema',
        policy_function => 'your_function',
        statement_types => 'SELECT',
        update_check    => TRUE
    );
END;

GRANT SELECT, INSERT, UPDATE, DELETE ON Movies TO admin_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON Financials TO admin_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON Votes TO admin_user;

SELECT * FROM Movies;
SELECT * FROM Financials;
SELECT * FROM Votes;

SELECT table_name, owner
FROM all_tables
WHERE table_name IN ('MOVIES', 'FINANCIALS', 'VOTES');


GRANT SELECT, INSERT, UPDATE, DELETE ON admin_user.Movies TO admin_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_user.Financials TO admin_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_user.Votes TO admin_user;

SELECT table_name, owner
FROM all_tables
WHERE owner = 'ADMIN_USER';

SELECT owner, table_name
FROM all_tables
WHERE table_name IN ('MOVIES', 'FINANCIALS', 'VOTES', 'PRODUCTION', 'PEOPLE');



CONNECT admin_user/AdminPassword123;


