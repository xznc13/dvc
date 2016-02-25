DELIMITER $$
DROP PROCEDURE IF EXISTS roverDuplicateCountsForAllSystems;
CREATE PROCEDURE roverDuplicateCountsForAllSystems()
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Count the duplicates
--
-- DB:		MARIADB
--
-- Purpose	Determine the number of duplicates on each system across both PROD and UAT
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverDuplicateCountsForAllSystems';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_core_system text;
DECLARE v_core_prod_table text;
DECLARE v_core_uat_table text;
DECLARE v_sql_command text;
DECLARE v_sql_union text;

DECLARE v_cursor_finished INTEGER DEFAULT 0;

DECLARE db_cursor_core_systems CURSOR FOR  
SELECT core_system
      ,core_prod_table
      ,core_uat_table
  FROM core_systems
 WHERE UPPER(core_system_status) = 'ON'
 order by core_system;

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
-- Build the and execute the SQL
-- -----------------------------------------------------
SET v_sql_command = '';
SET v_sql_union = '';


OpEN db_cursor_core_systems;
loop_core_systems: LOOP 

  FETCH db_cursor_core_systems INTO v_core_system, v_core_prod_table, v_core_uat_table;
	  
    IF v_cursor_finished = 1 THEN LEAVE loop_core_systems; END IF;

    CALL roverLogging(4, v_logging_process,'UI',v_core_system);

    SET v_sql_command = concat(v_sql_command,v_sql_union); 
    SET v_sql_command = concat(v_sql_command,' Select ');
     
    SET v_sql_command = concat(v_sql_command,char(39),v_core_system,char(39),' as ''System''');
    
	-- PROD Count
    SET v_sql_command = concat(v_sql_command,',(select (ifnull((Select COUNT(*) ');
    SET v_sql_command = concat(v_sql_command,'    from ',v_core_prod_table);
    SET v_sql_command = concat(v_sql_command,'   group by core_key  ');	
    SET v_sql_command = concat(v_sql_command,'   having count(*) > 1 ),0)))');		
    SET v_sql_command = concat(v_sql_command,'    as ''PROD''');
 
 	-- UAT Count
    SET v_sql_command = concat(v_sql_command,',(select (ifnull((Select COUNT(*) ');
    SET v_sql_command = concat(v_sql_command,'    from ',v_core_uat_table);
    SET v_sql_command = concat(v_sql_command,'   group by core_key  ');	
    SET v_sql_command = concat(v_sql_command,'   having count(*) > 1 ),0)))');		
    SET v_sql_command = concat(v_sql_command,'    as ''UAT''');
 
    SET v_sql_union = ' UNION ';

END LOOP loop_core_systems;
CLOSE db_cursor_core_systems;


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
