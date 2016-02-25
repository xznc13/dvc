DELIMITER $$
DROP PROCEDURE IF EXISTS roverUncategorisedGroups;
CREATE PROCEDURE roverUncategorisedGroups(IN in_core_system text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Uncategorised Groups
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the list of uncategorised groups
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverUncategorisedGroups';

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
SET v_sql_command = concat(v_sql_command,' SELECT tbl_class.name as ''Group'', count(*) as ''Messages'' ');
SET v_sql_command = concat(v_sql_command,'   FROM classifications tbl_class ');
SET v_sql_command = concat(v_sql_command,'   left join results tbl_resu on tbl_resu.compid = tbl_class.compid ');
SET v_sql_command = concat(v_sql_command,'                             and tbl_resu.core_system = ''',in_core_system,'''');	  
SET v_sql_command = concat(v_sql_command,'  WHERE LOCATE(''1'',tbl_resu.compid) <> 0');
SET v_sql_command = concat(v_sql_command,'   and tbl_class.core_system = ''',in_core_system,'''');
SET v_sql_command = concat(v_sql_command,'   and not exists (SELECT 1 FROM categorisation_rules tbl_cats where tbl_cats.classification_name = tbl_class.name) ');
SET v_sql_command = concat(v_sql_command,' group by  tbl_class.name ');
SET v_sql_command = concat(v_sql_command,' order by count(*) desc');

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
