-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title:	core_systems
--
-- DB:		MARIADB
--
-- Purpose:	Build the table
--
-- Version:	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------
-- Build the system table
-- -----------------------------------------------
DROP TABLE IF EXISTS core_systems;
CREATE TABLE core_systems
 (
   id               				INT NOT NULL AUTO_INCREMENT
  ,date_time						DATETIME DEFAULT now()
  ,core_system						TEXT NULL 
  ,core_system_rover_name			TEXT NULL 
  ,core_prod_table					TEXT NULL
  ,core_prod_connectivity			TEXT NULL
  ,core_uat_table					TEXT NULL
  ,core_uat_connectivity			TEXT NULL
  ,core_system_status				TEXT NULL
  ,core_system_logging				TEXT NULL
  ,core_system_alert				TEXT NULL
  ,core_system_alert_target			TEXT NULL
  ,core_connect_system_rdbms		TEXT NULL
  ,core_connect_block_size			text null
  ,core_connect_connection_string	text null
  ,PRIMARY KEY (id)
 );

 -- -----------------------------------------------------------------------------------------------------
 