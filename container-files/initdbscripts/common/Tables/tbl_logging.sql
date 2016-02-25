-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	logging
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the log table
-- -----------------------------------------------
DROP TABLE IF EXISTS logging;
CREATE TABLE logging
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,PROCESS					TEXT NULL
  ,core_system				TEXT NULL 
  ,log_details				TEXT NULL
  ,PRIMARY KEY (id)
 );

 -- -----------------------------------------------------------------------------------------------------
 