DELIMITER $$
DROP PROCEDURE IF EXISTS roverGroupReport;
CREATE PROCEDURE roverGroupReport(IN in_group_name text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Group Report
--
-- DB:		MARIADB
--
-- Purpose	Produce the group report
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverGroupReport';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
DECLARE v_compid text;
DECLARE v_core_system text;
DECLARE v_sample_trade text;

DECLARE v_group_report text;
DECLARE v_group_report_line text;

DECLARE v_index int;
DECLARE v_delim text;
DECLARE v_delim2 text;

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
SET v_sql_command = concat('select core_key from results tbl_resl where compid = ''',v_compid,''' LIMIT 1 into @_sample_trade');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_sample_trade = @_sample_trade;

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
-- Build the column string SQL and execute
-- -----------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','...building report');

set v_group_report = '';
set v_group_report_line = '';

-- Line 1
SET v_sql_command = concat('select concat('' Report Date : '', cast(now() as char(250))) into @_group_report_line');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_group_report_line = @_group_report_line;
set v_group_report = concat(v_group_report,v_group_report_line,'<br><br>');

-- Line 2
SET v_sql_command = concat('select concat('' Rover Group : '',name) from classifications tbl_class where name = ''',in_group_name,''' into @_group_report_line');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_group_report_line = @_group_report_line;
set v_group_report = concat(v_group_report,v_group_report_line,'<br><br>');

-- Line 3
set v_group_report_line = ' List of Differences : ';
set v_group_report = concat(v_group_report,v_group_report_line);
SET v_group_report_line = @column_string;
set v_group_report = concat(v_group_report,v_group_report_line,'<br><br>');

-- Line 4
set v_group_report_line = ' First Appeared : ';
set v_group_report = concat(v_group_report,v_group_report_line);

SET v_sql_command = concat('Select cast(min(date_time) AS CHAR(250)) from results where compid = ''',v_compid,''' and core_system = ''',v_core_system,''' into @_group_report_line');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_group_report_line = @_group_report_line;
set v_group_report = concat(v_group_report,v_group_report_line,'<br><br>');

-- Line 5
set v_group_report_line = ' Last Appeared : ';
set v_group_report = concat(v_group_report,v_group_report_line);
SET v_sql_command = concat('Select cast(max(date_time) AS CHAR(250)) from results where compid = ''',v_compid,''' and core_system = ''',v_core_system,''' into @_group_report_line');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_group_report_line = @_group_report_line;
set v_group_report = concat(v_group_report,v_group_report_line,'<br><br>');

-- Line 6
set v_group_report_line = ' Number of messages affected : ';
set v_group_report = concat(v_group_report,v_group_report_line);
SET v_sql_command = concat('select cast(count(*) as char(250)) from results where compid = ''',v_compid,''' and core_system = ''',v_core_system,''' into @_group_report_line');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_group_report_line = @_group_report_line;
set v_group_report = concat(v_group_report,v_group_report_line,'<br><br>');

-- Line 7
set v_group_report_line = ' Sample Trade : ';
set v_group_report = concat(v_group_report,v_group_report_line);
set v_group_report_line = v_sample_trade;
set v_group_report = concat(v_group_report,v_group_report_line,'<br><br>');

CALL roverLogging(4, v_logging_process,'UI',v_group_report);

select v_group_report;
-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
