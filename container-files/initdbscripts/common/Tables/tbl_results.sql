-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	results
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the results table
-- -----------------------------------------------
DROP TABLE IF EXISTS results;
CREATE TABLE results
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,process_date				TEXT NULL
  ,core_system				varchar(250) NULL 
  ,compid					TEXT NULL
  ,core_key					varchar(250) NULL
  ,PRIMARY KEY (id)
 );
 
 -- -----------------------------------------------------------------------------------------------------
 
 
DROP INDEX if exists IDX_results_core_key on results;
CREATE INDEX IDX_results_core_key ON results (core_key);

DROP INDEX if exists IDX_results_combined_key on results;
CREATE INDEX IDX_results_combined_key ON results (core_key, core_system);
