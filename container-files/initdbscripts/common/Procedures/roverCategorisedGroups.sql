DELIMITER $$
DROP PROCEDURE IF EXISTS roverCategorisedGroups;
CREATE PROCEDURE roverCategorisedGroups(IN in_core_system text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Categorised Groups
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the list of categorised groups
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverCategorisedGroups';

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

SET v_sql_command = concat(v_sql_command,' SELECT tbl_class.name as ''Classification'', count(*) as ''Messages'', tbl_catr.category as ''Category'', tbl_catr.comment as ''Comment'', tbl_catr.who as ''Who'' ' );
SET v_sql_command = concat(v_sql_command,'  FROM classifications tbl_class ');
SET v_sql_command = concat(v_sql_command,'  left join results tbl_resul on tbl_resul.compid = tbl_class.compid ');
SET v_sql_command = concat(v_sql_command,'                             and tbl_resul.core_system = ''',in_core_system,'''');	  
SET v_sql_command = concat(v_sql_command,'  left join categorisation_rules tbl_catr on tbl_catr.classification_name = tbl_class.name');
SET v_sql_command = concat(v_sql_command,'                                         and tbl_catr.core_system = ''',in_core_system,'''');	  
SET v_sql_command = concat(v_sql_command,'  WHERE LOCATE(''1'',tbl_resul.compid) <> 0');
SET v_sql_command = concat(v_sql_command,'   and tbl_class.core_system = ''',in_core_system,'''');
SET v_sql_command = concat(v_sql_command,'   and exists (SELECT 1 FROM categorisation_rules tbl_cats where tbl_cats.classification_name = tbl_class.name) ');
SET v_sql_command = concat(v_sql_command,' group by  tbl_class.name, tbl_catr.category, tbl_catr.comment, tbl_catr.who ');

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
