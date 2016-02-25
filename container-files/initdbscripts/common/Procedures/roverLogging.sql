DELIMITER $$
DROP PROCEDURE IF EXISTS roverLogging;
CREATE PROCEDURE roverLogging(IN in_level INT, in_process TEXT, in_core_system TEXT, in_log_details TEXT)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Logging
--
-- DB:		MARIADB
--
-- Purpose	Controls the writing of procedures
--
-- Version	V0.2 - move to prepared statements
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------
-- TEST
-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command TEXT;
DECLARE v_logging_level INT;

-- -----------------------------------------------------
-- End of declares
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Retrieve the logging level - Default to full logging until control table is implemented
-- -----------------------------------------------------
SET v_logging_level = 5;
select logging_level from control into v_logging_level;

SET v_sql_command = concat('select logging_level from control into @_logging_level');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_logging_level = @_logging_level;


-- -----------------------------------------------------
-- Write to the log
-- -----------------------------------------------------
IF in_level <= v_logging_level THEN

  SET v_sql_command = '';
  SET v_sql_command = concat(v_sql_command,'INSERT INTO logging (date_time, process, core_system, log_details) ');    
  SET v_sql_command = concat(v_sql_command,'             VALUES (now() ');
  SET v_sql_command = concat(v_sql_command,'                    ,''',in_process,'''');
  SET v_sql_command = concat(v_sql_command,'                    ,''',in_core_system,'''');
  SET v_sql_command = concat(v_sql_command,'                    ,''',in_log_details,''')');

  SET @s = v_sql_command;
  PREPARE stmt FROM @s;
  EXECUTE stmt;
  DEALLOCATE PREPARE stmt;
 
  END IF;

-- -----------------------------------------------------------------------------------------------------
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
