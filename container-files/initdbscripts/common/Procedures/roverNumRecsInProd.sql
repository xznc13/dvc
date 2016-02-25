DELIMITER $$
DROP PROCEDURE IF EXISTS roverNumRecsInProd;
CREATE PROCEDURE roverNumRecsInProd(IN in_core_system text, in_process_date date, out out_result int)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Number of records in Prod
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the number of records in the Prod tables for systems that are switched on
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverNumRecsInProd';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_core_table TEXT;
DECLARE v_core_system TEXT;
DECLARE v_sql_command TEXT;
DECLARE v_sql_delim TEXT;

DECLARE v_cursor_finished INTEGER DEFAULT 0;

DECLARE db_cursor_core_systems CURSOR FOR  
 SELECT core_prod_table, core_system
   FROM core_systems
  WHERE UPPER(core_system_status) = 'ON'
  ORDER BY core_system;

-- -----------------------------------------------------
-- Handlers
-- -----------------------------------------------------
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_cursor_finished = 1;

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
-- Build the SQL
-- -----------------------------------------------------
SET v_sql_command = '';
SET v_sql_delim = '';

SET v_sql_command = concat(v_sql_command,' Select ');

OpEN db_cursor_core_systems;
loop_core_systems: LOOP 

  FETCH db_cursor_core_systems INTO v_core_table, v_core_system;
	  
    IF v_cursor_finished = 1 THEN LEAVE loop_core_systems; END IF;

	if in_core_system = '' or
       (in_core_system <> '' and v_core_system = in_core_system)  then
      SET v_sql_command = concat(v_sql_command,v_sql_delim);
     
      SET v_sql_command = concat(v_sql_command,'(Select COUNT(*) from ',v_core_table,'');
  	  if in_process_date <> '0000-00-00' then
        set v_sql_command = concat(v_sql_command,'   where core_process_date = ''', in_process_date, '''');
      end if;
      SET v_sql_command = concat(v_sql_command,')');

	  SET v_sql_delim = ' + ';
	end if;

END LOOP loop_core_systems;
CLOSE db_cursor_core_systems;

SET v_sql_command = concat(v_sql_command,' into @returned_result ');

CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

SET @returned_result = NULL;
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Return the result
-- -----------------------------------------------------
set out_result = ifnull(@returned_result,0);

CALL roverLogging(4,v_logging_process,'UI',concat('Result:',out_result));

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
