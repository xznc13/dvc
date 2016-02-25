-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	collated_groups
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the collated_groups table
-- -----------------------------------------------
DROP TABLE IF EXISTS collated_groups;
CREATE TABLE collated_groups
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,process_date				TEXT NULL
  ,core_system				TEXT
  ,compid					TEXT
  ,classification_name		TEXT
  ,category					TEXT
  ,comment					TEXT
  ,who						TEXT
  ,total_messages			INT
  ,PRIMARY KEY (id) 
 );

 -- -----------------------------------------------------------------------------------------------------
 