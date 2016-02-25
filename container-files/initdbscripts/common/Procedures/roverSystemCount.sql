DELIMITER $$
DROP PROCEDURE IF EXISTS roverSystemCount;
CREATE PROCEDURE roverSystemCount()
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - NSystem Count
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the number of systems that are switched on
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverSystemCount';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
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

CALL roverLogging(4, v_logging_process,'UI','Starting...');

-- -----------------------------------------------------
-- Build and run the query
-- -----------------------------------------------------
SET v_sql_command = '';

SET v_sql_command = concat (v_sql_command,' SELECT COUNT(*) ');
SET v_sql_command = concat (v_sql_command,' INTO @returned_result');
SET v_sql_command = concat (v_sql_command,' FROM core_systems ');
SET v_sql_command = concat (v_sql_command,' WHERE UPPER(Core_System_Status) = ''ON'' ');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @returned_var = NULL;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Return the result
-- -----------------------------------------------------
select ifnull(@returned_result,0) as 'SystemCount';

CALL roverLogging(4,v_logging_process,'UI',concat('Result:',@returned_result));


-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
