-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	categorisation_rules
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the Categorisation_Rules table
-- -----------------------------------------------
DROP TABLE IF EXISTS categorisation_rules;
CREATE TABLE categorisation_rules
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,process_date				Date
  ,core_system				TEXT
  ,classification_name		TEXT
  ,category					TEXT
  , COMMENT					TEXT
  ,who						TEXT
  ,updated_timestamp		DATETIME
  ,PRIMARY KEY (id) 
 );

 -- -----------------------------------------------------------------------------------------------------
 