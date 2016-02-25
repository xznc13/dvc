DELIMITER $$
DROP PROCEDURE IF EXISTS roverBuildFilter;
CREATE PROCEDURE roverBuildFilter(IN in_core_system text, out out_exclusion_rules text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Build the filter SQL
--
-- DB:		MARIADB
--
-- Purpose	Build the filter rules for this system
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverBuildFilter';

-- -----------------------------------------------------
-- Declare statements
-- -----------------------------------------------------
DECLARE v_sql_command text;
DECLARE v_sql_line text;
DECLARE v_delim text;

-- This is the function library
Declare v_function_library_right 		text default 'RIGHT(table_item_side.table_item_column,data_item_length)';
DEclare v_function_library_left  		text default 'LEFT(table_item_side.table_item_column,data_item_length)';
declare v_function_library_substring	text default 'SUBSTRING(table_item_side.table_item_column,data_item_start,data_item_length)';

declare v_ls_value text;
declare v_ls_side text;
declare v_ls_field text;
declare v_ls_string text;
declare v_ls_start text;
declare v_ls_length text;

declare v_operator text;

declare v_rs_value text;
declare v_rs_side text;
declare v_rs_field text;
declare v_rs_string text;
declare v_rs_start text;
declare v_rs_length text;

DECLARE v_cursor_finished INTEGER DEFAULT 0;

DECLARE db_cursor_filter_rules CURSOR FOR  
		SELECT ls_value, ls_side, ls_field, ls_string, ls_start, ls_length
              ,operator
			  ,rs_value, rs_side, rs_field, rs_string, rs_start, rs_length
		  FROM filter_rules
		 WHERE core_system = in_core_system
		 ORDER BY id;

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

call roverLogging (2,v_logging_process, in_core_system, 'Started');

-- -----------------------------------------------------
-- Loop through the filter rules for this core_system and build the sql
-- -----------------------------------------------------
set v_sql_command = '';
set v_sql_line = '';
set v_delim = '';

OPEN db_cursor_filter_rules;
loop_filter_rules: LOOP

  FETCH db_cursor_filter_rules INTO  v_ls_value, v_ls_side, v_ls_field, v_ls_string, v_ls_start, v_ls_length
									,v_operator
									,v_rs_value, v_rs_side, v_rs_field, v_rs_string, v_rs_start, v_rs_length;
  
	IF v_cursor_finished = 1 THEN LEAVE loop_filter_rules; END IF;

    set v_ls_string = 	case upper(v_ls_string) 
						  when 'RIGHT'						Then replace(v_function_library_right,'item','item1')
						  when 'LEFT'						Then replace(v_function_library_left,'item','item1')
						  when 'MIDDLE'						Then replace(v_function_library_substring,'item','item1')
															else concat('''',v_ls_value,'''')
						End;

    set v_operator = 	case upper(v_operator) 
						  when 'EQUAL TO'					Then '='
						  when 'LESS THAN'					Then '<'
						  when 'GREATER THAN'				Then '>'
						  when 'LESS THAN OR EQUAL TO'		Then '<='
						  when 'GREATER THAN OR EQUAL TO'	Then '>='
						  when 'NOT EQUAL TO'				Then '>='
                        end;

    set v_rs_string =	case upper(v_rs_string) 
						  when 'RIGHT'						Then replace(v_function_library_right,'item','item2')
						  when 'LEFT'						Then replace(v_function_library_left,'item','item2')
						  when 'MIDDLE'						Then replace(v_function_library_substring,'item','item2')
															else concat('''',v_rs_value,'''')
						End;

    set v_sql_line = concat(v_ls_string,' ',v_operator,' ',v_rs_string);
	
    set v_sql_line = replace(v_sql_line,'table_item1_side',v_ls_side);
	set v_sql_line = replace(v_sql_line,'table_item1_column',v_ls_field);
	set v_sql_line = replace(v_sql_line,'data_item1_start',v_ls_start);
    set v_sql_line = replace(v_sql_line,'data_item1_length',v_ls_length);

    set v_sql_line = replace(v_sql_line,'table_item2_side',v_rs_side);
	set v_sql_line = replace(v_sql_line,'table_item2_column',v_rs_field);
	set v_sql_line = replace(v_sql_line,'data_item2_start',v_rs_start);
    set v_sql_line = replace(v_sql_line,'data_item2_length',v_rs_length);

    set v_sql_command = concat(v_sql_command,v_delim,v_sql_line);
	set v_delim = ' OR ';

END LOOP loop_filter_rules;
CLOSE db_cursor_filter_rules;

-- Make these criterion EXCLUSIONS
if v_sql_command <> '' then
   set v_sql_command = concat(' NOT (',v_sql_command,') ');
   call roverLogging (3,v_logging_process, in_core_system,REPLACE(v_sql_command,char(39),"''"));
else
   call roverLogging (3,v_logging_process, in_core_system,'No Exclusion Rules Exist');
end if;

-- Return the result
set out_exclusion_rules = v_sql_command;

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(2,v_logging_process,in_core_system,'End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
