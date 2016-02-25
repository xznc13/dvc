DELIMITER $$
DROP PROCEDURE IF EXISTS roverSystemDetailCounts;
CREATE PROCEDURE roverSystemDetailCounts(IN in_core_system text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Collate the System Deatil Counts
--
-- DB:		MARIADB
--
-- Purpose	Collate the System Detail counts for this Core System
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverSystemDetailCounts';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
declare v_result decimal(5,2);
declare v_message_coverage text;
declare v_group_coverage text;

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
-- Grab the Counts
-- -----------------------------------------------------
call roverResultsNumRecsNoDiff(in_core_system,@NumRecsNoDiff);

call roverResultsNumRecsDiff(in_core_system,@NumRecsDiff);
call roverResultsNumRecsDiffUncat(in_core_system,@NumRecsDiffUncat);
call roverResultsNumRecsDiffCat(in_core_system,@NumRecsDiffCat);

call roverResultsNumGroups(in_core_system,@NumGroups);
call roverResultsNumGroupsUncat(in_core_system,@NumGroupsUncat);
call roverResultsNumGroupsCat(in_core_system,@NumGroupsCat);

-- -----------------------------------------------------
-- Coverage calculations
-- -----------------------------------------------------
set v_result = @NumRecsDiffCat/@NumRecsDiff * 100; 
set v_message_coverage = ifnull(concat(v_result,'%'),'0.00%');

set v_result = @NumGroupsCat/@NumGroups * 100; 
set v_group_coverage = ifnull(concat(v_result,'%'),'0.00%');

-- -----------------------------------------------------
-- Build and execute the SQL
-- -----------------------------------------------------
SET v_sql_command = '';
set v_sql_command = concat(v_sql_command,' Select ');

-- Messages with No Differences
SET v_sql_command = concat(v_sql_command,'  ',@NumRecsNoDiff,' AS NumRecsNoDiff');

-- Total number of Messages with Differences
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsDiff,' AS NumRecsDiff');

-- Messages with Differences that have NOT been categorised
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsDiffUncat,' AS NumRecsDiffUncat');

-- Messages with Differences that HAVE been categorised
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsDiffCat,' AS NumRecsDiffCat');

-- Total number of Groups
SET v_sql_command = concat(v_sql_command,' ,',@NumGroups,' AS NumGroups');

-- Grops that have NOT been categorised
SET v_sql_command = concat(v_sql_command,' ,',@NumGroupsUncat,' AS NumGroupsUncat');

-- Groups that HAVE been categorised
SET v_sql_command = concat(v_sql_command,' ,',@NumGroupsCat,' AS NumGroupsCat');

-- Coverage by Messages
SET v_sql_command = concat(v_sql_command,' ,''',v_message_coverage,''' AS MessageCoverage');

-- Coverage by Groups
SET v_sql_command = concat(v_sql_command,' ,''',v_group_coverage,''' AS GroupCoverage');

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
