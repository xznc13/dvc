DELIMITER $$
DROP PROCEDURE IF EXISTS roverCollateGroups;
CREATE PROCEDURE roverCollateGroups(IN in_core_system text, in_process_date date)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Collate the Groups
--
-- DB:		MARIADB
--
-- Purpose	Collate the Group details 
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverCollateGroups';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;

declare v_core_system text;
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

CALL roverLogging(2, v_logging_process,in_core_system,'Started');

set v_core_system = in_core_system;
set v_process_date = in_process_date;

-- -----------------------------------------------------
-- Insert the details to collated_groups
-- -----------------------------------------------------
Set v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' INSERT into collated_groups ');
SET v_sql_command = concat(v_sql_command,'          (process_date ');
SET v_sql_command = concat(v_sql_command,' 			,core_system ');
SET v_sql_command = concat(v_sql_command,' 			,compid ');
SET v_sql_command = concat(v_sql_command,' 			,classification_name ');
SET v_sql_command = concat(v_sql_command,' 			,category ');
SET v_sql_command = concat(v_sql_command,' 			,comment ');
SET v_sql_command = concat(v_sql_command,' 			,who ');
SET v_sql_command = concat(v_sql_command,' 			,total_messages) ');
SET v_sql_command = concat(v_sql_command,' 	 SELECT ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'          ,tbl_class.core_system ');
SET v_sql_command = concat(v_sql_command,'    		,tbl_class.compid ');
SET v_sql_command = concat(v_sql_command,' 			,tbl_class.name ');
SET v_sql_command = concat(v_sql_command,' 			,tbl_catr.category ');
SET v_sql_command = concat(v_sql_command,' 			,tbl_catr.comment ');
SET v_sql_command = concat(v_sql_command,' 			,tbl_catr.who ');
SET v_sql_command = concat(v_sql_command,' 			,count(*) ');
SET v_sql_command = concat(v_sql_command,' 	   FROM classifications tbl_class ');
SET v_sql_command = concat(v_sql_command,'        left join results tbl_resul on tbl_resul.compid = tbl_class.compid ');
SET v_sql_command = concat(v_sql_command,'                                   and tbl_resul.core_system = ''',v_core_system,'''');
SET v_sql_command = concat(v_sql_command,'        left join categorisation_rules tbl_catr on tbl_catr.classification_name = tbl_class.name ');
SET v_sql_command = concat(v_sql_command,'                                               and tbl_catr.core_system = ''',v_core_system,'''');
SET v_sql_command = concat(v_sql_command,'       WHERE LOCATE(''1'',tbl_resul.compid) <> 0 ');
SET v_sql_command = concat(v_sql_command,'         and tbl_class.core_system = ''',v_core_system,'''');
SET v_sql_command = concat(v_sql_command,' 	    and tbl_class.process_date = ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'     group by  tbl_class.name; ');


CALL roverLogging(3, v_logging_process,in_core_system,REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(2,v_logging_process,in_core_system,'Ended');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
