DELIMITER $$
DROP PROCEDURE IF EXISTS roverRemoveCategorisationRule;
CREATE PROCEDURE roverRemoveCategorisationRule(IN in_group_name text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Remove a group categorisation rule
--
-- DB:		MARIADB
--
-- Purpose	Remove the categorisation entry for the given group name
--
-- Version  V0.1 - Initial build
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverRemoveCategorisationRule';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;

-- -----------------------------------------------------
-- Handlers
-- -----------------------------------------------------
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
call roverErrorHandler(v_logging_process);
END;

-- -----------------------------------------------------
-- End of declares
-- -----------------------------------------------------

CALL roverLogging(1, v_logging_process,'UI','Starting...');

-- -----------------------------------------------------
-- Build the Sql and execute
-- -----------------------------------------------------

SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' DELETE FROM categorisation_rules ');
SET v_sql_command = concat(v_sql_command,'   WHERE classification_name = ''',in_group_name,'''');

call roverLogging(3,v_logging_process, 'UI',REPLACE(v_sql_command,char(39),"''"));

SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(1,v_logging_process,'UI','End');
end $$
DELIMITER ;

