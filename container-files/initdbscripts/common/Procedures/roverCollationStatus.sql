DELIMITER $$
DROP PROCEDURE IF EXISTS roverCollationStatus;
CREATE PROCEDURE roverCollationStatus()
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Present the collation status
--
-- DB:		MARIADB
--
-- Purpose	Pull the collation status from the logging table
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverCollationStatus';

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
SET v_sql_command = concat (v_sql_command,' select *  ');
SET v_sql_command = concat (v_sql_command,'   from logging ');
SET v_sql_command = concat (v_sql_command,'  where id >= (select max(id) from logging where process = ''roverCollationControl'' and log_details = ''Started'') ');
SET v_sql_command = concat (v_sql_command,'    and process in (''roverCollationControl'',''roverCollateResults'') ');
SET v_sql_command = concat (v_sql_command,'    and (    (core_system = '''' and log_details in (''Started'',''Ended'')) ');
SET v_sql_command = concat (v_sql_command,'          or (core_system = ''Errorhandler'' and log_details = ''Starting'')');
SET v_sql_command = concat (v_sql_command,'          or (core_system <> '''' and log_details in (''Started'')) ');
SET v_sql_command = concat (v_sql_command,'         )');

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

