-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	comparison_rules
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the comparison_rules Tablex
-- -----------------------------------------------
DROP TABLE IF EXISTS comparison_rules;
CREATE TABLE comparison_rules
 ( 
   id               		INT NOT NULL AUTO_INCREMENT
  ,core_system				TEXT NULL
  ,data_order				DECIMAL(20) NULL
  ,data_item				TEXT NULL
  ,operator					TEXT NULL
  ,PRIMARY KEY (id)
 );
 
 -- -----------------------------------------------------------------------------------------------------
 