-- On créer les roles
CREATE ROLE admin_role;
CREATE ROLE manager_role;
CREATE ROLE regular_role;

-- Privileges

-- Admin : all access
GRANT ALL PRIVILEGES ON admin_user.Movies TO admin_role;
GRANT ALL PRIVILEGES ON admin_user.Financials TO admin_role;
GRANT ALL PRIVILEGES ON admin_user.Votes TO admin_role;
GRANT ALL PRIVILEGES ON admin_user.Production TO admin_role;
GRANT ALL PRIVILEGES ON admin_user.People TO admin_role;
GRANT ALL PRIVILEGES ON admin_user.audit_log TO admin_role;

-- Manager Role: Read, Insert, Update
GRANT SELECT, INSERT, UPDATE ON admin_user.Movies TO manager_role;
GRANT SELECT, INSERT, UPDATE ON admin_user.Financials TO manager_role;
GRANT SELECT, INSERT, UPDATE ON admin_user.Votes TO manager_role;
GRANT SELECT, INSERT, UPDATE ON admin_user.Production TO manager_role;
GRANT SELECT, INSERT, UPDATE ON admin_user.People TO manager_role;

-- Regular Role: Read-Only Access
GRANT SELECT ON admin_user.Movies TO regular_role;
GRANT SELECT ON admin_user.Financials TO regular_role;
GRANT SELECT ON admin_user.Votes TO regular_role;
GRANT SELECT ON admin_user.Production TO regular_role;
GRANT SELECT ON admin_user.People TO regular_role;

-- Creation des users 
CREATE USER user1 IDENTIFIED BY user1;
CREATE USER user2 IDENTIFIED BY user2;
CREATE USER user3 IDENTIFIED BY user3;

-- On associe les roles aux users
GRANT regular_role TO user1;
GRANT manager_role TO user2;
GRANT admin_role TO user3;

-- Sécurité 

-- Relges de Password 
ALTER PROFILE DEFAULT LIMIT
    PASSWORD_LIFE_TIME 90
    PASSWORD_REUSE_TIME 180
    PASSWORD_REUSE_MAX 5
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LOCK_TIME 1;


-- Affiche des roles des 
SELECT grantee AS username, granted_role AS role
FROM dba_role_privs
WHERE grantee IN ('USER1', 'USER2', 'USER3');



GRANT CREATE SESSION TO user1;
GRANT CREATE SESSION TO user2;
GRANT CREATE SESSION TO user3;

GRANT SELECT ON admin_user.Movies TO user1;
GRANT SELECT ON admin_user.Movies TO user2;
GRANT SELECT ON admin_user.Movies TO user3;




