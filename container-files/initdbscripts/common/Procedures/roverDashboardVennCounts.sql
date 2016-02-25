DELIMITER $$
DROP PROCEDURE IF EXISTS roverDashboardVennCounts;
CREATE PROCEDURE roverDashboardVennCounts()
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Venn dsahboard counts
--
-- DB:		MARIADB
--
-- Purpose	Retrieve the number of rows in each Venn recordset for systems that are switched on
--
-- Version	V0.2 - move to prepared statements
--			V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverDashboardVennCounts';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_core_system text;
DECLARE v_core_prod_table text;
DECLARE v_core_uat_table text;
DECLARE v_sql_command text;
DECLARE v_sql_union text;
DECLARE v_all_or_one text;
DECLARE v_process_date date;


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
-- Pull the process date
-- -----------------------------------------------------
SET v_sql_command = concat('SELECT engine_all_or_one, process_date FROM control into @_all_or_one, @_process_date');
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set v_all_or_one = @_all_or_one;
set v_process_date = @_process_date;

-- -----------------------------------------------------
-- Set the process_date
-- -----------------------------------------------------
if upper(v_all_or_one) = 'ALL' then
  set v_process_date = '0000-00-00';
end if;


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

    SET v_sql_command = ' INSERT into dashboard_counts (core_system, process_date, process, prod_total, prod_unique, in_both, uat_unique, uat_total)'; 
    SET v_sql_command = concat(v_sql_command,' VALUES (');

	-- core_system     
    SET v_sql_command = concat(v_sql_command,'  ''',v_core_system,'''');
    
	-- process_date
	SET v_sql_command = concat(v_sql_command,', ''',v_process_date,'''');

	-- process
	SET v_sql_command = concat(v_sql_command,', ''UI''');
	
    -- prod_total
	SET v_sql_command = concat(v_sql_command,', (SELECT COUNT(*) FROM ',v_core_prod_table,' WHERE core_process_date = ''',v_process_date,''')');

	-- prod_dups - calculated by the table as prod_total - prod_unique

	-- prod_unique
	SET v_sql_command = concat(v_sql_command,', (Select count(Distinct(core_key)) from ',v_core_prod_table,' WHERE core_process_date = ''',v_process_date,''')');

	-- prod_only - calculated by the table as prod_unique - both

	-- both
	SET v_sql_command = concat(v_sql_command,', (select count(distinct(core_key)) from ',v_core_prod_table,' prod WHERE prod.core_process_date = ''',v_process_date,''' ');
    SET v_sql_command = concat(v_sql_command,'     and exists (select 1 from ',v_core_uat_table,' uat WHERE uat.core_process_date = prod.core_process_date AND uat.core_key = prod.core_key))');

	-- uat_only - calculated by the table as uat_unique - both

	-- uat_unique
	SET v_sql_command = concat(v_sql_command,', (Select count(Distinct(core_key)) from ',v_core_uat_table,' WHERE core_process_date = ''',v_process_date,''')');

	-- uat_dups - calculated by the table as uat_total - uat_unique

	-- uat_total
	SET v_sql_command = concat(v_sql_command,', (SELECT COUNT(*) FROM ',v_core_uat_table,' WHERE core_process_date = ''',v_process_date,''')');

	-- end brackets
	SET v_sql_command = concat(v_sql_command,');');


	CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));

	SET @s = v_sql_command;
	PREPARE stmt FROM @s;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END LOOP loop_core_systems;
CLOSE db_cursor_core_systems;

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
