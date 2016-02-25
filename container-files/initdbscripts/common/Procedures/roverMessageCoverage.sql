DELIMITER $$
DROP PROCEDURE IF EXISTS roverMessageCoverage;
CREATE PROCEDURE roverMessageCoverage(IN in_core_system text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Message Coverage
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the Message Coverage percentage
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverMessageCoverage';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
declare v_result decimal(4,2);

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

-- Number of categorised messages
SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' select count(*) ');
SET v_sql_command = concat(v_sql_command,'  FROM results tbl_resu');
SET v_sql_command = concat(v_sql_command,'  inner join classifications tbl_class on tbl_class.compid = tbl_resu.compid');
SET v_sql_command = concat(v_sql_command,'  WHERE LOCATE(''1'',tbl_resu.compid) <> 0');
SET v_sql_command = concat(v_sql_command,'  and tbl_resu.core_system = ''',in_core_system,'''');
SET v_sql_command = concat(v_sql_command,'   and exists (select 1 from categorisation_rules tbl_cat where tbl_cat.classification_name = tbl_class.name)');
SET v_sql_command = concat(v_sql_command,' into @messages_categorised ');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @messages_categorised = NULL;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Total number of differences
SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' select count(*) ');
SET v_sql_command = concat(v_sql_command,'  FROM results tbl_resu');
SET v_sql_command = concat(v_sql_command,'  WHERE LOCATE(''1'',tbl_resu.compid) <> 0');
SET v_sql_command = concat(v_sql_command,'  and tbl_resu.core_system = ''',in_core_system,'''');
SET v_sql_command = concat(v_sql_command,' into @messages_differences ');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @messages_differences = NULL;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Return the result
-- -----------------------------------------------------
set v_result = @messages_categorised/@messages_differences * 100;
select ifnull(concat(v_result,'%'),'0.00%') as 'NumberOfDiffPercentages';

CALL roverLogging(4,v_logging_process,'UI',concat('Result:',v_result));

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
