DELIMITER $$
DROP PROCEDURE IF EXISTS roverComparisonEngine;
CREATE PROCEDURE roverComparisonEngine(IN in_all_or_one text, in_process_date date)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Comparison Engine
--
-- DB:		MARIADB
--
-- Purpose	Loop through the system records and run the comparsion for each if required 
--
-- Version  V0.3 - Include error handler
--			V0.2 - Include exclusion rules
--			V0.1 - From V0.3 of SQL SERVER version
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variable
-- -----------------------------------------------------
DECLARE v_logging_process TEXT default 'roverComparisonEngine';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_core_system TEXT;
DECLARE v_core_prod_table TEXT;
DECLARE v_core_uat_table TEXT;
DECLARE v_sql_command TEXT;
DECLARE v_command TEXT;
DECLARE v_data_item TEXT;
DECLARE v_exclusion_rules TEXT;

DECLARE v_cursor_finished INTEGER DEFAULT 0;

DECLARE db_cursor_core_systems CURSOR FOR  
		SELECT core_system
			  ,core_prod_table
			  ,core_uat_table
		  FROM core_systems
		 WHERE UPPER(core_system_status) = 'ON'
		 ORDER BY core_system;

DECLARE db_cursor_comparison_rules CURSOR FOR  
		SELECT ops.command
			  ,rules.data_item
		  FROM comparison_rules rules
         INNER JOIN operators ops ON ops.operator = rules.operator
         WHERE ops.command <> ''
           AND rules.core_system = v_core_system
         ORDER BY rules.data_order, rules.data_item;

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


-- -----------------------------------------------------
-- MASSIVE HACK TO CLEAR OUT THE RESULTS BEFORE RUNNING
-- -----------------------------------------------------
-- DELETE FROM results; 
-- DELETE FROM classifications;
-- DELETE FROM categorisation_rules;
-- DELETE FROM logging;
-- -----------------------------------------------------
-- MASSIVE HACK TO CLEAR OUT THE RESULTS BEFORE RUNNING
-- -----------------------------------------------------

call roverLogging (2,v_logging_process, '', 'Started');

-- -----------------------------------------------------
-- Open the cursor and loop through core_systems
-- -----------------------------------------------------
OPEN db_cursor_core_systems;
loop_core_systems: LOOP

  FETCH db_cursor_core_systems INTO v_core_system, v_core_prod_table, v_core_uat_table;
  
	IF v_cursor_finished = 1 THEN LEAVE loop_core_systems; END IF;

	call roverLogging (3,v_logging_process, v_core_system, 'Started');

    -- Caching can go in here
    -- Build the sql to grab the prod TABLE
	-- Put the filtering here

    -- Build the comparison statement
	SET v_sql_command = ' INSERT INTO results (core_system, compid, process_date, core_key) ';
	SET v_sql_command = CONCAT (v_sql_command, ' SELECT ');
	SET v_sql_command = CONCAT (v_sql_command,' ',CHAR(39),v_core_system,CHAR(39),' ,'	);
    SET v_sql_command = CONCAT (v_sql_command,' CONCAT(',CHAR(39),CHAR(39));

    OPEN db_cursor_comparison_rules;
    loop_comparison_rules: LOOP 

      FETCH db_cursor_comparison_rules INTO v_command, v_data_item;
	  
	  IF v_cursor_finished = 1 THEN LEAVE loop_comparison_rules; END IF;

 	  SET v_sql_command = concat(v_sql_command,REPLACE(v_command,'column_name',v_data_item));

	END LOOP loop_comparison_rules;
    CLOSE db_cursor_comparison_rules;

    set v_cursor_finished = 0;

    SET v_sql_command = concat(v_sql_command,')');
	SET v_sql_command = concat(v_sql_command,' AS compid');
	SET v_sql_command = concat(v_sql_command,' ,base.core_process_date');
    SET v_sql_command = concat(v_sql_command,' ,base.core_key');
    SET v_sql_command = concat(v_sql_command,' FROM     ',v_core_prod_table,' base');
    SET v_sql_command = concat(v_sql_command,' INNER JOIN ',v_core_uat_table,' cand ON cand.core_key = base.core_key');
    SET v_sql_command = concat(v_sql_command,' WHERE not exists (Select 1 from results tbl_resu where tbl_resu.core_key = base.core_key and tbl_resu.core_system = ''', v_core_system,''')');


	-- V0.3 - All or One
    if upper(in_all_or_one) = 'ONE' then
	   SET v_sql_command = concat(v_sql_command,'   AND base.core_process_date = ''',in_process_date,'''');
    end if;
	-- ...V0.3

    -- V0.2 - Exclusion Rules
    call roverbuildfilter(v_core_system,v_exclusion_rules);
    if v_exclusion_rules <> '' then
       SET v_sql_command = concat(v_sql_command,' AND ',v_exclusion_rules);
    end if;

	call roverLogging (3,v_logging_process, v_core_system,REPLACE(v_sql_command,char(39),"''"));
	-- ...V0.2 

    SET @s = v_sql_command;
    PREPARE stmt FROM @s;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

	call roverLogging (3,v_logging_process, v_core_system, 'Completed');
	
END LOOP loop_core_systems;
CLOSE db_cursor_core_systems;


-- -----------------------------------------------------
-- Build Group Names
-- -----------------------------------------------------

-- Copy new groups into the classifications table
call roverLogging (3,v_logging_process, '','Copying new groups over');

INSERT INTO classifications (core_system, compid, process_date) 
      (SELECT tbl_res.core_system, tbl_res.compid, tbl_res.process_date 
         FROM results tbl_res 
        WHERE not exists (SELECT 1 FROM classifications tbl_class WHERE tbl_class.compid = tbl_res.compid and tbl_class.core_system = tbl_res.core_system)
        GROUP BY tbl_res.core_system, tbl_res.compid);


-- Name any classifications that have not already been
call roverLogging (3,v_logging_process, '','Applying group names');
DROP TABle if exists group_id_name;
CREATE TEMPORARY TABLE group_id_name AS
   (SELECT id, concat(core_system,':',CAST(MAX(ID) as CHAR(250))) AS 'name'
      FROM classifications tbl_class2
     WHERE cast(date_time as date) = cast(now() as date)
       AND tbl_class2.name is null
     GROUP BY compid, core_system);

UPDATE classifications tbl_class
   SET tbl_class.name = (select name 
                           from group_id_name tbl_gin
						  where tbl_gin.id = tbl_class.id)
 WHERE tbl_class.name is null;

drop table if exists group_id_name;

-- -----------------------------------------------------------------------------------------------------

call roverLogging (2,v_logging_process, '','Ended');
-- -----------------------------------------------------------------------------------------------------
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
