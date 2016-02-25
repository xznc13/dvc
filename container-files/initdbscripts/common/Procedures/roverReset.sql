DELIMITER $$
DROP PROCEDURE IF EXISTS roverReset;
CREATE PROCEDURE roverReset(IN in_core_system text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Reset the output of the system
--
-- DB:		MARIADB
--
-- Purpose	Clear the results down ready for a new run
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverReset';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_core_system TEXT;
DECLARE v_sql_command TEXT;

DECLARE v_cursor_finished INTEGER DEFAULT 0;

DECLARE db_cursor_core_systems CURSOR FOR  
 SELECT core_system
   FROM core_systems
  WHERE UPPER(core_system_status) = 'ON'
  ORDER BY core_system;

-- -----------------------------------------------------
-- Handlers
-- -----------------------------------------------------
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_cursor_finished = 1;

DECLARE EXIT HANDLER FOR SQLEXCEPTIOn
BEGIN
GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE, @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
SET @full_error = CONCAT("ERROR ", @errno, " (", @sqlstate, "): ", @text);

if @full_error is NULl then
  set @full_error = 'It has not been possible to retrieve the SQL error';
end if;

call roverErrorHandler(v_logging_process, @full_error);
END;

-- -----------------------------------------------------
-- End of declares
-- -----------------------------------------------------
CALL roverLogging(2, v_logging_process,in_core_system,'Starting...');

-- -----------------------------------------------------
-- Build the SQL
-- -----------------------------------------------------
OPEN db_cursor_core_systems;
loop_core_systems: LOOP 

  FETCH db_cursor_core_systems INTO v_core_system ;
	  
    IF v_cursor_finished = 1 THEN LEAVE loop_core_systems; END IF;

	 IF in_core_system = '' or
       (in_core_system <> '' and v_core_system = in_core_system)  then

		-- Clear rover results
      SET v_sql_command = '';
	  SET v_sql_command = concat(v_sql_command,' DELETE FROM results WHERE core_system = ''',v_core_system,'''');
	  CALL roverLogging(3, v_logging_process,v_core_system,REPLACE(v_sql_command,char(39),"''"));
	  SET @s = v_sql_command;
	  PREPARE stmt FROM @s;
 	  EXECUTE stmt;
	  DEALLOCATE PREPARE stmt;      
      
	  -- Clear rover classifications
	  SET v_sql_command = '';
      SET v_sql_command = concat(v_sql_command,' DELETE FROM classifications WHERE core_system = ''',v_core_system,'''');
	  CALL roverLogging(3, v_logging_process,v_core_system,REPLACE(v_sql_command,char(39),"''"));
	  SET @s = v_sql_command;
	  PREPARE stmt FROM @s;
 	  EXECUTE stmt;
	  DEALLOCATE PREPARE stmt;      
		
	  -- Clear rover categories
	  SET v_sql_command = '';
      SET v_sql_command = concat(v_sql_command,' DELETE FROM categorisation_rules WHERE core_system = ''',v_core_system,'''');
	  CALL roverLogging(3, v_logging_process,v_core_system,REPLACE(v_sql_command,char(39),"''"));
	  SET @s = v_sql_command;
	  PREPARE stmt FROM @s;
 	  EXECUTE stmt;
	  DEALLOCATE PREPARE stmt;      
		
	end if;

END LOOP loop_core_systems;
CLOSE db_cursor_core_systems;

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(2,v_logging_process,in_core_system,'End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
