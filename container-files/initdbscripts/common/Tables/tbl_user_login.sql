-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	user_login
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the User Table
-- -----------------------------------------------
DROP TABLE IF EXISTS user_login;
CREATE TABLE user_login
 ( 
   id             			INT NOT NULL AUTO_INCREMENT
  ,userid					INT NULL
  ,username					TEXT NULL
  ,PASSWORD					TEXT NULL
  ,role						TEXT NULL
  ,tenantid					INT NULL
  ,PRIMARY KEY (id)
 );

 -- -----------------------------------------------------------------------------------------------------
 