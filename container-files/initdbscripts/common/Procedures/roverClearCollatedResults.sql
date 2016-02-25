DELIMITER $$
DROP PROCEDURE IF EXISTS roverClearCollatedResults;
CREATE PROCEDURE roverClearCollatedResults(IN in_core_system text, in_all_or_one text, in_process_date date)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Clear out the colalted results
--
-- DB:		MARIADB
--
-- Purpose	Clear out the collated results to make way for the latest set
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverClearCollatedResults';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
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

call roverLogging (2,v_logging_process, in_core_system, 'Started');

-- -----------------------------------------------------
-- Remove the collated_results entries
-- -----------------------------------------------------
set v_sql_command = '';

set v_sql_command = concat(v_sql_command,' DELETE ');
set v_sql_command = concat(v_sql_command,' FROM collated_results ');
set v_sql_command = concat(v_sql_command,' WHERE core_system = ''',in_core_system,'''');
if upper(in_all_or_one) = 'ONE' then
 set v_sql_command = concat(v_sql_command,'   AND process_date = ''', in_process_date, '''');
end if;
Call roverLogging (3,v_logging_process, in_core_system,REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Remove the collated_groups entries
-- -----------------------------------------------------
set v_sql_command = '';

set v_sql_command = concat(v_sql_command,' DELETE ');
set v_sql_command = concat(v_sql_command,' FROM collated_groups ');
set v_sql_command = concat(v_sql_command,' WHERE core_system = ''',in_core_system,'''');
if upper(in_all_or_one) = 'ONE' then
 set v_sql_command = concat(v_sql_command,'   AND process_date = ''', in_process_date, '''');
end if;
Call roverLogging (3,v_logging_process, in_core_system,REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Remove the collated_group_reports entries
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Remove the collated_comparison_rules entries
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Remove the collated_filter_rules entries
-- -----------------------------------------------------


-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(2,v_logging_process,in_core_system,'End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
