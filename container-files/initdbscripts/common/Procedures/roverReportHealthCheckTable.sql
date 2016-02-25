DELIMITER $$
DROP PROCEDURE IF EXISTS roverReportHealthCheckTable;
CREATE PROCEDURE roverReportHealthCheckTable(IN in_process_Date date)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Health Check Report
--
-- DB:		MARIADB
--
-- Purpose	Produce the data for the Health Check Report
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverReportHealthCheckTable';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
declare v_process_date date;

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

set v_process_date = in_process_date;

-- -----------------------------------------------------
-- Collate the Report Counts
-- -----------------------------------------------------
SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' select category							as ''Category'' ');
SET v_sql_command = concat(v_sql_command,'  	  ,sum(total_messages)				as ''Total'' ');
SET v_sql_command = concat(v_sql_command,'   from collated_groups ');
SET v_sql_command = concat(v_sql_command,'  where process_date = ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'    and category is not null ');
SET v_sql_command = concat(v_sql_command,'  group by category;');
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
