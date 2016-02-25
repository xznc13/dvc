-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	dashboard_counts
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
DROP TABLE IF EXISTS dashboard_counts;
CREATE TABLE dashboard_counts
 (
  id 				Int AUTO_INCREMENT NOT NULL
 ,date_time 		DateTime default now()
 ,process_date 		Text NULL
 ,core_system 		VarChar(250) NULL
 ,process	 		VarChar(250) NULL 
 ,prod_total 		INT
 ,prod_dups			int as (prod_total - prod_unique)	
 ,prod_unique		INT
 ,prod_only			INT as (prod_unique - in_both)
 ,in_both			INT
 ,uat_only			int as (uat_unique - in_both)
 ,uat_unique		INT
 ,uat_dups			INT as (uat_total - uat_unique)
 ,uat_total			int
  ,PRIMARY KEY (id)
 );
 
 -- -----------------------------------------------------------------------------------------------------
 