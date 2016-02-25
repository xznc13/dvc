DELIMITER $$
DROP PROCEDURE IF EXISTS roverColumnString;
CREATE PROCEDURE roverColumnString(IN in_group_name text)
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
-- Version	V0.2 - move to prepared statements
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverColumnString';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
DECLARE v_compid text;
DECLARE v_core_system text;
DECLARE v_delim text;
DECLARE v_delim2 text;
DECLARE v_index int;

CALL roverLogging(1, v_logging_process,'UI','Starting...');



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
-- Build the column string
-- -----------------------------------------------------
SET v_sql_command = 'SELECT (';

set v_index = 0;
loop_compid: LOOP 

  SET v_index = v_index + 1;

  if v_index > char_length(v_compid) then leave loop_compid; end if;

  IF SUBSTRING(v_compid,v_index,1) = '1' then

	  SET v_sql_command = concat(v_sql_command,v_delim,v_delim2,v_delim,' (Select data_item from comparison_rules where core_system = ''',v_core_system,''' and data_order = ''',rtrim(CAST(v_index AS CHAR(250))),''')');
      set v_delim = ' + ';
      set v_delim2 = ''', ''';
  END if;

end loop loop_compid;

SET v_sql_command = concat(v_sql_command,') into @column_string');

call roverLogging(3,v_logging_process, 'UI',REPLACE(v_sql_command,char(39),"''"));

set @column_string = null;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

call roverLogging(3,v_logging_process, 'UI',concat('Result: ',@columnn_string));

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(1,v_logging_process,'UI','End');
end $$
DELIMITER ;

