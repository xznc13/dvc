DELIMITER $$
DROP PROCEDURE IF EXISTS roverBuildCategorisationRule;
CREATE PROCEDURE roverBuildCategorisationRule(IN in_group_name text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Build a group categorisation rule
--
-- DB:		MARIADB
--
-- Purpose	Build the categorisation entry for the given group name
--
-- Version  V0.1 - Initial build
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverBuildCategorisationRule';

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

-- -----------------------------------------------------
-- Build the Sql and execute
-- -----------------------------------------------------

SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' INSERT INTO categorisation_rules (core_system, classification_name, category, who, comment) ');    
SET v_sql_command = concat(v_sql_command,' (SELECT tbl_class.core_system, tbl_class.name, ''To Be Determined'', ''admin'', ''Rule created'' ');
SET v_sql_command = concat(v_sql_command,'    FROM classifications tbl_class ');
SET v_sql_command = concat(v_sql_command,'   WHERE tbl_class.name = ''',in_group_name,'''');
SET v_sql_command = concat(v_sql_command,'     AND not exists (Select 1 from categorisation_rules tbl_cat where tbl_cat.classification_name = ''',+ in_group_name,''')) ');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
