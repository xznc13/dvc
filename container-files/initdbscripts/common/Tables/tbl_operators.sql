-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	operators
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the Operators table
-- -----------------------------------------------
DROP TABLE IF EXISTS operators;
CREATE TABLE operators
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,operator					TEXT
  ,command					TEXT	 
  ,PRIMARY KEY (id) 
 );

 -- -----------------------------------------------------------------------------------------------------
 