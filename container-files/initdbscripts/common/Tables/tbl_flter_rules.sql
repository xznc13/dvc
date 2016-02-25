-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	filter_rules
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the filter_rules table
-- -----------------------------------------------
DROP TABLE IF EXISTS filter_rules;
CREATE TABLE filter_rules
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,core_system				TEXT
  ,ls_value					TEXT
  ,ls_side					TEXT
  ,ls_field					TEXT
  ,ls_string				TEXT
  ,ls_start					TEXT
  ,ls_length				TEXT
  ,operator					TEXT
  ,rs_value					TEXT
  ,rs_side					TEXT
  ,rs_field					TEXT
  ,rs_string				TEXT
  ,rs_start					TEXT
  ,rs_length				TEXT 
  ,comment					TEXT
  ,who						TEXT
  ,updated_timestamp		DATETIME
  ,PRIMARY KEY (id) 
 );

 -- -----------------------------------------------------------------------------------------------------
 