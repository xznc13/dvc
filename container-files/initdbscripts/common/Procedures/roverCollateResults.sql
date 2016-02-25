DELIMITER $$
DROP PROCEDURE IF EXISTS roverCollateResults;
CREATE PROCEDURE roverCollateResults(IN in_core_system text, in_process_date date)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Collate the Results
--
-- DB:		MARIADB
--
-- Purpose	Collate the Venn and duplicate counts for this system for this process date
--
-- Version	V0.2 - move to prepared statements
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverCollateResults';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_core_prod_table text;
DECLARE v_core_uat_table text;
DECLARE v_sql_command text;

declare v_num_prod int;

declare v_core_system text;
declare v_process_date date;

declare v_result decimal(5,2);
declare v_message_coverage text;
declare v_group_coverage text;


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

CALL roverLogging(2, v_logging_process,in_core_system,'Started');

set v_core_system = in_core_system;
set v_process_date = in_process_date;

-- -----------------------------------------------------
-- Pull the core_system details
-- -----------------------------------------------------
SET v_sql_command = concat('SELECT core_prod_table, core_uat_table FROM core_systems WHERE core_system = ''',in_core_system,''' into @_core_prod_table, @_core_uat_table');
CALL roverLogging(3, v_logging_process,in_core_system,REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_core_prod_table = @_core_prod_table;
set v_core_uat_table = @_core_uat_table;

-- -----------------------------------------------------
-- Retrieve the current dashboard counts
-- -----------------------------------------------------

Set v_sql_command = '';
SET v_sql_command = concat(v_sql_command,'SELECT prod_total, prod_unique, in_both, uat_unique, uat_total ');
set v_sql_command = concat(v_sql_command,' from dashboard_counts tbl1');
set v_sql_command = concat(v_sql_command,' where tbl1.date_time = (select max(tbl2.date_time)');
set v_sql_command = concat(v_sql_command,'                           from dashboard_counts tbl2');
set v_sql_command = concat(v_sql_command,'                           WHERE tbl1.core_system = tbl2.core_system limit 1)');
set v_sql_command = concat(v_sql_command,'  AND tbl1.process_date = ''',v_process_date,'''');
set v_sql_command = concat(v_sql_command,'  AND tbl1.core_system = ''',v_core_system,'''');
set v_sql_command = concat(v_sql_command,'  into @prod_total, @prod_unique, @in_both, @uat_unique, @uat_total');
CALL roverLogging(3, v_logging_process,in_core_system,REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Grab the System Counts
-- -----------------------------------------------------
call roverResultsNumRecsNoDiff(v_core_system,@NumRecsNoDiff);

call roverResultsNumRecsDiff(v_core_system,@NumRecsDiff);
call roverResultsNumRecsDiffUncat(v_core_system,@NumRecsDiffUncat);
call roverResultsNumRecsDiffCat(v_core_system,@NumRecsDiffCat);

call roverResultsNumGroups(v_core_system,@NumGroups);
call roverResultsNumGroupsUncat(v_core_system,@NumGroupsUncat);
call roverResultsNumGroupsCat(v_core_system,@NumGroupsCat);

-- -----------------------------------------------------
-- Coverage calculations
-- -----------------------------------------------------
set v_result = @NumRecsDiffCat/@NumRecsDiff * 100; 
set v_message_coverage = ifnull(concat(v_result,'%'),'0.00%');

set v_result = @NumGroupsCat/@NumGroups * 100; 
set v_group_coverage = ifnull(concat(v_result,'%'),'0.00%');


-- -----------------------------------------------------
-- Build and execute the SQL
-- -----------------------------------------------------
SET v_sql_command = '';

SET v_sql_command = concat(v_sql_command, ' INSERT INTO collated_results ');
SET v_sql_command = concat(v_sql_command, ' (');
SET v_sql_command = concat(v_sql_command, '  core_system');
SET v_sql_command = concat(v_sql_command, ' ,process_date');
SET v_sql_command = concat(v_sql_command, ' ,prod_total');
SET v_sql_command = concat(v_sql_command, ' ,prod_unique');
SET v_sql_command = concat(v_sql_command, ' ,in_both');
SET v_sql_command = concat(v_sql_command, ' ,uat_unique');
SET v_sql_command = concat(v_sql_command, ' ,uat_total');

SET v_sql_command = concat(v_sql_command, ' ,msgs_no_diff');
SET v_sql_command = concat(v_sql_command, ' ,msgs_diff');
SET v_sql_command = concat(v_sql_command, ' ,msgs_diff_uncat');
SET v_sql_command = concat(v_sql_command, ' ,msgs_diff_cat');
SET v_sql_command = concat(v_sql_command, ' ,groups');
SET v_sql_command = concat(v_sql_command, ' ,groups_uncat');
SET v_sql_command = concat(v_sql_command, ' ,groups_cat');
SET v_sql_command = concat(v_sql_command, ' ,msgs_coverage');
SET v_sql_command = concat(v_sql_command, ' ,group_coverage');


SET v_sql_command = concat(v_sql_command, ' )');
SET v_sql_command = concat(v_sql_command,' values (');
SET v_sql_command = concat(v_sql_command,'  ''',in_core_system,'''');
SET v_sql_command = concat(v_sql_command,' ,''',in_process_date,'''');


SET v_sql_command = concat(v_sql_command,' ,',@prod_total);
SET v_sql_command = concat(v_sql_command,' ,',@prod_unique);
SET v_sql_command = concat(v_sql_command,' ,',@in_both);
SET v_sql_command = concat(v_sql_command,' ,',@uat_unique);
SET v_sql_command = concat(v_sql_command,' ,',@uat_total);

SET v_sql_command = concat(v_sql_command,' ,',@NumRecsNoDiff);
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsDiff);
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsDiffUncat);
SET v_sql_command = concat(v_sql_command,' ,',@NumRecsDiffCat);
SET v_sql_command = concat(v_sql_command,' ,',@NumGroups);
SET v_sql_command = concat(v_sql_command,' ,',@NumGroupsUncat);
SET v_sql_command = concat(v_sql_command,' ,',@NumGroupsCat);

SET v_sql_command = concat(v_sql_command,' ,''',v_message_coverage,'''');
SET v_sql_command = concat(v_sql_command,' ,''',v_group_coverage,'''');

-- Close Values Bracket
SET v_sql_command = concat(v_sql_command,')');

CALL roverLogging(3, v_logging_process,in_core_system,REPLACE(v_sql_command,char(39),"''"));

SET @returned_var = NULL;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_num_prod = ifnull(@returned_result,0);

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(2,v_logging_process,in_core_system,'Ended');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
