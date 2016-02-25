-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	classifications
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the Classification table
-- -----------------------------------------------
DROP TABLE IF EXISTS classifications;
CREATE TABLE classifications
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,process_date				TEXT NULL
  ,core_system				TEXT
  ,compid					TEXT
  ,NAME						TEXT
  ,PRIMARY KEY (id) 
 );

 -- -----------------------------------------------------------------------------------------------------
 