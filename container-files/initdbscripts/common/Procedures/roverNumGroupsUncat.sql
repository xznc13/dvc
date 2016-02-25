DELIMITER $$
DROP PROCEDURE IF EXISTS roverNumGroupsUncat;
CREATE PROCEDURE roverNumGroupsUncat(out out_result int)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Number of Uncategorised Groups
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the number of uncategorised groups for systems that are switched on
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverNumGroupsUncat';


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

CALL roverLogging(4, v_logging_process,'UI','Starting...');

SET v_sql_command = '';
SET v_sql_command = ' SELECT count(*) ';
SET v_sql_command = concat(v_sql_command,' into @returned_result ');
SET v_sql_command = concat(v_sql_command,'  FROM classifications tbl_class ');
SET v_sql_command = concat(v_sql_command,' WHERE LOCATE(''1'',tbl_class.compid) <> 0');
SET v_sql_command = concat(v_sql_command,'   AND NOT EXISTS	(SELECT 1 FROM categorisation_rules tbl_rules WHERE tbl_rules.classification_name = tbl_class.name) ');
SET v_sql_command = concat(v_sql_command,'   AND EXISTS		(SELECT 1 FROM core_systems tbl_core WHERE tbl_core.core_system = tbl_class.core_system AND tbl_core.core_system_status = ''ON'')');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @returned_var = NULL;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Return the result
-- -----------------------------------------------------
set out_result = ifnull(@returned_result,0);

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
