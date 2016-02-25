DELIMITER $$
DROP PROCEDURE IF EXISTS roverShowDataDifferences;
CREATE PROCEDURE roverShowDataDifferences(IN in_group_name text)
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
DECLARE v_logging_process TEXT DEFAULT 'roverShowDataDifferences';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
DECLARE v_compid text;
DECLARE v_core_system text;
DECLARE v_delim text;
DECLARE v_delim2 text;
DECLARE v_index int;

DECLARE v_core_prod_table text;
DECLARE v_core_uat_table text;

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
-- Build the column string SQL and execute
-- -----------------------------------------------------
SET v_sql_command = 'SELECT concat(';

set v_index = 0;
set v_delim = '';
set v_delim2 = '';

loop_compid: LOOP 

  SET v_index = v_index + 1;

  if v_index > char_length(v_compid) then leave loop_compid; end if;

  IF SUBSTRING(v_compid,v_index,1) = '1' then
    SET v_sql_command = concat(v_sql_command,v_delim,v_delim2,v_delim,' (Select data_item from comparison_rules where core_system = ''',v_core_system,''' and data_order = ''',rtrim(CAST(v_index AS CHAR(250))),''')');
    set v_delim = ' , ';
    set v_delim2 = ''', ''';
  END if;

end loop loop_compid;

SET v_sql_command = concat(v_sql_command,') into @column_string');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CALL roverLogging(4, v_logging_process,'UI',@column_string);

-- -----------------------------------------------------
-- Pull the core_system details
-- -----------------------------------------------------
SET v_sql_command = concat('SELECT core_prod_table, core_uat_table FROM core_systems WHERE core_system = ''',v_core_system,''' into @_core_prod_table, @_core_uat_table');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_core_prod_table = @_core_prod_table;
set v_core_uat_table = @_core_uat_table;

-- -----------------------------------------------------
-- Build the SQL and execute
-- -----------------------------------------------------
SET v_sql_command = ' select  * from (';
SET v_sql_command = concat(v_sql_command,' select  core_key ');
SET v_sql_command = concat(v_sql_command,'        ,core_system ');
SET v_sql_command = concat(v_sql_command,'        ,''PROD'' as core_source ');
SET v_sql_command = concat(v_sql_command,'        ,',@column_string);
SET v_sql_command = concat(v_sql_command,'   from ',v_core_prod_table,' tbl_prod ');
SET v_sql_command = concat(v_sql_command,'  where exists (select 1 from results tbl_resl where tbl_resl.core_key = tbl_prod.core_key and  tbl_resl.core_system = ''',v_core_system,''' AND tbl_resl.compid = ''',v_compid,''') ');
SET v_sql_command = concat(v_sql_command,'  UNION ALL');
SET v_sql_command = concat(v_sql_command,' select  core_key ');
SET v_sql_command = concat(v_sql_command,'        ,core_system ');
SET v_sql_command = concat(v_sql_command,'        ,''UAT'' as core_source ');
SET v_sql_command = concat(v_sql_command,'        ,',@column_string);
SET v_sql_command = concat(v_sql_command,'   from ',v_core_uat_table,' tbl_uat ');
SET v_sql_command = concat(v_sql_command,'  where exists (select 1 from results tbl_resl where tbl_resl.core_key = tbl_uat.core_key and  tbl_resl.core_system = ''',v_core_system,''' AND tbl_resl.compid = ''',v_compid,''') ');
SET v_sql_command = concat(v_sql_command,') t');
SET v_sql_command = concat(v_sql_command,'  order by core_key, core_system, core_source ');
SET v_sql_command = concat(v_sql_command,'  limit 40');

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
