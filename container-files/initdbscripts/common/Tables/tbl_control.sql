-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	control
--
-- DB:		MARIADB
--
-- Purpose:	Build the control table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the log table
-- -----------------------------------------------
DROP TABLE IF EXISTS control;
CREATE TABLE control
 (
   id               		INT NOT NULL AUTO_INCREMENT
  ,date_time				DATETIME DEFAULT now()
  ,control_status			TEXT NULL
  ,engine_status			TEXT NULL
  ,reset_status				TEXT NULL
  ,collation_status			TEXT NULL
  ,logging_level			INT default 0
  ,engine_all_or_one		TEXT
  ,process_date				DATE NULL
  ,PRIMARY KEY (id)
 );

 -- -----------------------------------------------------------------------------------------------------
 