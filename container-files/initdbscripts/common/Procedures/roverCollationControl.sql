DELIMITER $$
DROP PROCEDURE IF EXISTS roverCollationControl;
CREATE PROCEDURE roverCollationControl()
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Collation Control
--
-- DB:		MARIADB
--
-- Purpose	Orchestrates the collation of results for each of the active systems
--
-- Version	V0.2 - move to prepared statements
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverCollationControl';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_collation_status text;
DECLARE v_core_system text;
DECLARE v_all_or_one text;
DECLARE v_process_date date;
DECLARE v_sql_command text;

DECLARE v_cursor_finished INTEGER DEFAULT 0;

DECLARE db_cursor_core_systems CURSOR FOR  
SELECT core_system
  FROM core_systems
 WHERE UPPER(core_system_status) = 'ON'
 order by core_system;

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

call roverLogging (1,v_logging_process, '', 'Started');

-- -----------------------------------------------------
-- Retrieve the control variables
-- -----------------------------------------------------
SET v_sql_command = concat('SELECT collation_status, engine_all_or_one, process_date FROM control order by id desc limit 1 into @_collation_status, @_all_or_one, @_process_date');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_collation_status = @_collation_status;
set v_all_or_one = @_all_or_one;
set v_process_date = @_process_date;

call roverLogging (1,v_logging_process, '', concat('Collation_Status: ', v_collation_status));  
call roverLogging (1,v_logging_process, '', concat('Engine_All_Or_One: ', v_all_or_one));  
call roverLogging (1,v_logging_process, '', concat('Process_date: ', v_process_date));  

  -- ---------------------------------------------------------------
  -- Single pass through the loop 
  -- ---------------------------------------------------------------
 loop_through_steps: LOOP
 
  -- ---------------------------------------------------------------
  -- 1) Is Collation Control allowed to run
  -- ---------------------------------------------------------------
  if upper(v_collation_status) = 'ON' then
    call roverLogging (1,v_logging_process, '', 'Collation Control is On: RUNNING');  
  ELSE
    call roverLogging (1,v_logging_process, '', 'Collation Control is Off: LEAVING');  
    LEAVE loop_through_steps;
  end if;
 
  -- ---------------------------------------------------------------
  -- 2) Calculate the current Venn Counts
  -- ---------------------------------------------------------------	
  call roverLogging (1,v_logging_process, '', 'Calculate current VENN Counts: RUNNING');  
  call roverDashboardVennCounts();
  call roverLogging (1,v_logging_process, '', 'Calculate current VENN Counts: FINISHED');  	

  -- ---------------------------------------------------------------
  -- Loop through the core systems
  -- ---------------------------------------------------------------
  OPEN db_cursor_core_systems;
  loop_core_systems: LOOP

    FETCH db_cursor_core_systems INTO v_core_system;
	  
    IF v_cursor_finished = 1 THEN LEAVE loop_core_systems; END IF;

    -- ---------------------------------------------------------------
    -- 1) Clear out collation results if they already exist
    -- ---------------------------------------------------------------
    call roverLogging (1,v_logging_process, v_core_system, 'Clear Collated Results: RUNNING');  
    call roverClearCollatedResults(v_core_system, v_all_or_one, v_process_date);
    call roverLogging (1,v_logging_process, v_core_system, 'Clear Collated Results: FINISHED');  	 

    -- ---------------------------------------------------------------
    -- 2) Collate the Venn Results
    -- ---------------------------------------------------------------
    call roverLogging (1,v_logging_process, v_core_system, 'Collate Results: RUNNING');  
    call roverCollateResults(v_core_system, v_process_date);
    call roverLogging (1,v_logging_process, v_core_system, 'Collate Results: FINISHED');  	 

    -- ---------------------------------------------------------------
    -- 3) Pull the Groups
    -- ---------------------------------------------------------------
    call roverLogging (1,v_logging_process, v_core_system, 'Collate Groups: RUNNING');  
    call roverCollateGroups(v_core_system, v_process_date);
    call roverLogging (1,v_logging_process, v_core_system, 'Collate Groups: FINISHED');  	 

    -- ---------------------------------------------------------------
    -- 4) Pull the Group Reports
    -- ---------------------------------------------------------------
    -- call roverLogging (1,v_logging_process, v_core_system, 'Collate Group Reports: RUNNING');  
    -- call roverCollateGroupReports(v_core_system, v_process_date);
    -- call roverLogging (1,v_logging_process, v_core_system, 'Collate Group Reports: FINISHED');  	 
   
    -- ---------------------------------------------------------------
    -- 5) Pull the Comparison Rules
    -- ---------------------------------------------------------------
    -- call roverLogging (1,v_logging_process, v_core_system, 'Collate Comparison Rules: RUNNING');  
    -- call roverCollateComparisonRules(v_core_system, v_process_date);
    -- call roverLogging (1,v_logging_process, v_core_system, 'Collate Comparison Rules: FINISHED');  	 

    -- ---------------------------------------------------------------
    -- 6) Pull the Filter Rules
    -- ---------------------------------------------------------------
    -- call roverLogging (1,v_logging_process, v_core_system, 'Collate Filter Rules: RUNNING');  
    -- call roverCollateFilterRules(v_core_system, v_process_date);
    -- call roverLogging (1,v_logging_process, v_core_system, 'Collate Filter Rules: FINISHED');  	

    -- ---------------------------------------------------------------
    -- 7) Clear down the results, classificatoins & categorisation rules
    -- ---------------------------------------------------------------
    call roverLogging (1,v_logging_process, v_core_system, 'Clear Rover Down: RUNNING');  
	call roverReset(v_core_system); 
    call roverLogging (1,v_logging_process, v_core_system, 'Clear Rover Down: FINISHED');  	

  END LOOP loop_core_systems;

  call roverLogging (1,v_logging_process, '', 'Collation Control is On: FINISHED');    
  
  LEAVE loop_through_steps;
  
END LOOP loop_through_steps;

call roverLogging (1,v_logging_process, '', 'Ended');
-- -----------------------------------------------------------------------------------------------------
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
