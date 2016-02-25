DELIMITER $$
DROP PROCEDURE IF EXISTS roverColumnList;
CREATE PROCEDURE roverColumnList(IN in_group_name text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Lits of column differences
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the list of columns that differ for this group
--
-- Version	V0.2 - Moved to prepared statments
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverColumnList';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
DECLARE v_delim text;
DECLARE v_compid text;
DECLARE v_core_system text;
DECLARE v_index INT;

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
-- Pull required reference data
-- -----------------------------------------------------
set v_compid = '';
set v_core_system = '';

SET v_sql_command = concat('SELECT compid, core_system FROM classifications WHERE name = ''',in_group_name,'''into @_compid, @_core_system');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_compid = @_compid;
set v_core_system = @_core_system;

-- -----------------------------------------------------
-- Build the SQL
-- -----------------------------------------------------
SET v_sql_command = ' Select data_item from comparison_rules where data_order in (';

set v_index = 0;
set v_delim = '';

loop_compid: LOOP 

  SET v_index = v_index + 1;

  if v_index > char_length(v_compid) then leave loop_compid; end if;

  IF SUBSTRING(v_compid,v_index,1) = '1' then
      SET v_sql_command = concat(v_sql_command,v_delim,'''',rtrim(CAST(v_index AS CHAR(250))),'''');
      SET v_delim = ', ';
  END if;

end loop loop_compid;

SET v_sql_command = concat(v_sql_command,')');
SET v_sql_command = concat(v_sql_command,' and core_system = ''',v_core_system,'''');

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
