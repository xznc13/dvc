DELIMITER $$
DROP PROCEDURE IF EXISTS roverDashboardCounts;
CREATE PROCEDURE roverDashboardCounts()
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Collate the Dashboard Counts
--
-- DB:		MARIADB
--
-- Purpose	Collate the Dashboard counts
--
-- Version	V0.2 - move to prepared statements
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverDashboardCounts';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_all_or_one text;
DECLARE v_process_date date;


DECLARE v_sql_command text;


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
CALL roverLogging(4, v_logging_process,'UI','Starting...');




-- -----------------------------------------------------
-- Pull the process date
-- -----------------------------------------------------
SET v_sql_command = concat('SELECT engine_all_or_one, process_date FROM control into @_all_or_one, @_process_date');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_all_or_one = @_all_or_one;
set v_process_date = @_process_date;


-- -----------------------------------------------------
-- Set the process_date
-- -----------------------------------------------------
if upper(v_all_or_one) = 'ALL' then
  set v_process_date = '0000-00-00';
end if;
-- -----------------------------------------------------
-- Grab the Counts
-- -----------------------------------------------------
call roverNumSystems(@NumSystems);
call roverNumRecsinProd('', v_process_date, @NumRecsInProd);
call roverNumRecsinUAT('', v_process_date, @NumRecsInUAT);
call roverNumGroupsUncat(@NumGroupsUncat);

-- -----------------------------------------------------
-- Build and execute the SQL
-- -----------------------------------------------------
SET v_sql_command = '';
set v_sql_command = concat(v_sql_command,' Select ');

-- Process Date
SET v_sql_command = concat(v_sql_command,'''',v_process_date,''' as ProcessDate');

-- number of systems
SET v_sql_command = concat(v_sql_command,' ,',@NumSystems,' AS NumberOfSystems');

-- number of records in PROD
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsInProd,' AS RecordsInProd');

-- number of records in UAT
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsInUAT,' AS RecordsInUAT');

-- number of Uncat Groups
SET v_sql_command = concat(v_sql_command,' ,',@NumGroupsUncat,' AS GroupsUncat');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @returned_var = NULL;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
