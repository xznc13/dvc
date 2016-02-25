-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	Collated Results
--
-- DB:		MARIADB
--
-- Purpose:	Build the collated_results table`
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the log table
-- -----------------------------------------------
DROP TABLE IF EXISTS collated_results;
CREATE TABLE collated_results
 (
   id               			INT NOT NULL AUTO_INCREMENT
  ,date_time					DATETIME DEFAULT now()
  ,process_date					DATE
  ,core_system					TEXT 

  ,prod_total					INT
  ,prod_dups					int as (prod_total - prod_unique)	
  ,prod_unique					INT
  ,prod_only					INT as (prod_unique - in_both)

  ,in_both						INT

  ,uat_only						int as (uat_unique - in_both)
  ,uat_unique					INT
  ,uat_dups						INT as (uat_total - uat_unique)
  ,uat_total					INT

  ,msgs_no_diff					INT
  ,msgs_diff					INT	
  ,msgs_diff_uncat				INT
  ,msgs_diff_cat				INT
 
  ,groups						INT
  ,groups_uncat					INT
  ,groups_cat					INT
  ,msgs_coverage				decimal(5,2)
  ,group_coverage				decimal(5,2)

 

 

  ,PRIMARY KEY (id)
 );

 -- -----------------------------------------------------------------------------------------------------
 