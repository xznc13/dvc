DELIMITER $$
DROP PROCEDURE IF EXISTS roverEngineControl;
CREATE PROCEDURE roverEngineControl()
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Engine Control
--
-- DB:		MARIADB
--
-- Purpose	Orchestrates the comparison run elements of Rover
--
-- Version	V0.2 - move to prepared statements
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverEngineControl';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_control_status text;
DECLARE v_reset_status text;
DECLARE v_engine_status text;
DECLARE v_engine_all_or_one text;
DECLARE v_process_date date;
DECLARE v_sql_command TEXT;

-- -----------------------------------------------------
-- Handlers
-- -----------------------------------------------------
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

call roverLogging (1,v_logging_process, '', 'Started');

-- -----------------------------------------------------
-- Retrieve the control variables
-- -----------------------------------------------------
SET v_sql_command = 'SELECT control_status, reset_status, engine_status, engine_all_or_one, process_date ';
SET v_sql_command = concat(v_sql_command,' FROM control order by id desc limit 1 ');
SET v_sql_command = concat(v_sql_command,' into @_control_status, @_reset_status, @_engine_status, @_engine_all_or_one, @_process_date');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_control_status = @_control_status;
set v_reset_status = @_reset_status;
set v_engine_status = @_engine_status;
set v_engine_all_or_one = @_engine_all_or_one;
set v_process_date = @_process_date;

call roverLogging (1,v_logging_process, '', concat('Control_Status   : ',v_control_status));  
call roverLogging (1,v_logging_process, '', concat('Reset_Status     : ',v_reset_status));  
call roverLogging (1,v_logging_process, '', concat('Engine_Status    : ',v_engine_status));  
call roverLogging (1,v_logging_process, '', concat('Engine_All_or_One: ',v_engine_all_or_one));  
call roverLogging (1,v_logging_process, '', concat('Process_Date     : ',v_process_date));  

-- -----------------------------------------------------
-- Step through the followoing steps in order to detemrine the actions that are required
-- -----------------------------------------------------

loop_through_steps: LOOP

  -- ---------------------------------------------------------------
  -- 1) Is Engine Control allowed to run
  -- ---------------------------------------------------------------
  IF upper(v_control_status) = 'ON' Then
    call roverLogging (1,v_logging_process, '', 'Control is On: RUNNING');  
  ELSE
    call roverLogging (1,v_logging_process, '', 'Control is Off: LEAVING');  
    LEAVE loop_through_steps;
  end if;

  -- --------------------------------------------------------------- 
  -- 2) Has a reset been requested
  -- ---------------------------------------------------------------
  IF upper(v_reset_status) = 'ON' Then
    call roverLogging (1,v_logging_process, '', 'Reset is On: RUNNING');  
  
--  call roverReset(); 

    DELETE FROM results; 
    DELETE FROM classifications;
    DELETE FROM categorisation_rules;

    call roverLogging (1,v_logging_process, '', 'Reset is On: FINISHED');  

  ELSE
    call roverLogging (1,v_logging_process, '', 'Reset is Off');  
  end if;

  -- ---------------------------------------------------------------
  -- 3) Is the Comparison Engine allowed to run
  -- ---------------------------------------------------------------
  IF upper(v_engine_status) = 'ON' Then
    call roverLogging (1,v_logging_process, '', 'Comparison is On: RUNNING');  
	
	-- NEED TO GRAB THE PROCESS DATE HERE AND PASS TO COMPARISON ENGINE
	-- OR LET THE COMPARISON ENGINE GRAB THE DATE?
	
	SET v_sql_command = concat('SELECT engine_all_or_one, process_date ');
	SET v_sql_command = concat(v_sql_command,' FROM control order by id desc limit 1 ');
	SET v_sql_command = concat(v_sql_command,' into @_engine_all_or_one, @_process_date');
	SET @s = v_sql_command;
	PREPARE stmt FROM @s;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	set v_engine_all_or_one = @_engine_all_or_one;
	set v_process_date = @_process_date;


    call roverComparisonEngine(v_engine_all_or_one, v_process_date);
    call roverLogging (1,v_logging_process, '', 'Comparison is On: FINISHED');  
	
  Else
    call roverLogging (1,v_logging_process, '', 'Comparison is Off: LEAVING');  
    LEAVE loop_through_steps;
  end if;

  call roverLogging (1,v_logging_process, '', 'Control is On: FINISHED');  

  LEAVE loop_through_steps;
  
END LOOP loop_through_steps;


call roverLogging (1,v_logging_process, '', 'Ended');
-- -----------------------------------------------------------------------------------------------------
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
