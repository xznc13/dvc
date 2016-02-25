DELIMITER $$
DROP PROCEDURE IF EXISTS roverReportHealthCheck;
CREATE PROCEDURE roverReportHealthCheck(IN in_process_Date date)
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
DECLARE v_logging_process TEXT DEFAULT 'roverReportHealthCheck';

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
SET v_sql_command = concat(v_sql_command,' select ifnull(sum(prod_only) + sum(uat_only),0) ');
SET v_sql_command = concat(v_sql_command,'       ,ifnull(sum(prod_dups) + sum(uat_dups),0) ');
SET v_sql_command = concat(v_sql_command,' 	     ,ifnull(sum(prod_unique),0) ');
SET v_sql_command = concat(v_sql_command,'       ,ifnull(sum(prod_only),0) ');
SET v_sql_command = concat(v_sql_command,' 	     ,ifnull(sum(in_both),0) ');
SET v_sql_command = concat(v_sql_command,' 	     ,ifnull(sum(uat_only),0) ');
SET v_sql_command = concat(v_sql_command,' 	     ,ifnull(sum(uat_unique),0) ');
SET v_sql_command = concat(v_sql_command,' 	     ,ifnull(sum(prod_dups),0) ');
SET v_sql_command = concat(v_sql_command,'       ,ifnull(sum(uat_dups),0) ');
SET v_sql_command = concat(v_sql_command,'   from collated_results ');
SET v_sql_command = concat(v_sql_command,'  WHERE process_date = ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'   INTO @HealthCheckRouting ');
SET v_sql_command = concat(v_sql_command,'       ,@HealthCheckDuplication ');
SET v_sql_command = concat(v_sql_command,'       ,@RoutingProdUnique ');
SET v_sql_command = concat(v_sql_command,'       ,@RoutingProdOnly ');
SET v_sql_command = concat(v_sql_command,'       ,@RoutingInBoth ');
SET v_sql_command = concat(v_sql_command,'       ,@RoutingUATOnly ');
SET v_sql_command = concat(v_sql_command,'       ,@RoutingUATUnique ');
SET v_sql_command = concat(v_sql_command,'       ,@DuplicationProdDups ');
SET v_sql_command = concat(v_sql_command,'       ,@DuplicationUATDups ');
CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Collate the Report Regression status
-- -----------------------------------------------------
SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' select ifnull(sum(total_messages),0) ');
SET v_sql_command = concat(v_sql_command,'   from collated_groups ');
SET v_sql_command = concat(v_sql_command,'  WHERE process_date = ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'    AND upper(category) <> ''EXPECTED''');
SET v_sql_command = concat(v_sql_command,'   INTO @HealthCheckRegression ');
CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Count the number of Expected differences
-- -----------------------------------------------------
SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' select ifnull(sum(total_messages),0) ');
SET v_sql_command = concat(v_sql_command,'   from collated_groups ');
SET v_sql_command = concat(v_sql_command,'  WHERE process_date = ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'    AND upper(category) = ''EXPECTED''');
SET v_sql_command = concat(v_sql_command,'   INTO @HealthCheckRegressionExpected ');
CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- -----------------------------------------------------
-- Collate the Regression Total Categorised
-- -----------------------------------------------------
SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' select ifnull(sum(total_messages),0) ');
SET v_sql_command = concat(v_sql_command,'   from collated_groups ');
SET v_sql_command = concat(v_sql_command,'  WHERE process_date = ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'    AND category is not null ');
SET v_sql_command = concat(v_sql_command,'   INTO @RegressionTotalCategorised ');
CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
set @RegressionTotalCategorised = @RegressionTotalCategorised - @HealthCheckRegressionExpected;

-- -----------------------------------------------------
-- Collate the Regression Total Uncategorised
-- -----------------------------------------------------
SET v_sql_command = '';
SET v_sql_command = concat(v_sql_command,' select ifnull(sum(total_messages),0) ');
SET v_sql_command = concat(v_sql_command,'   from collated_groups ');
SET v_sql_command = concat(v_sql_command,'  WHERE process_date = ''',v_process_date,'''');
SET v_sql_command = concat(v_sql_command,'    AND category is null ');
SET v_sql_command = concat(v_sql_command,'   INTO @RegressionTotalUncategorised ');
CALL roverLogging(4, v_logging_process,'UI',REPLACE(v_sql_command,char(39),"''"));
SET @s = v_sql_command;
PREPARE stmt FROM @s;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- -----------------------------------------------------
-- Calculate Regression Total Without Regression 
-- -----------------------------------------------------

set @RegressionWithoutRegression = @RoutingInBoth - @HealthCheckRegression - @HealthCheckRegressionExpected - @RegressionTotalUncategorised;

set @HealthCheckRoutingImage =  case (@HealthCheckRouting)
								  WHEN 0 THEN 'resources/images/imagelists/Pass.png'
								  ELSe 'resources/images/imagelists/Fail.png' 
								end;

set @HealthCheckDuplicationImage =  case (@HealthCheckDuplication)
								      WHEN 0 THEN 'resources/images/imagelists/Pass.png'
								      ELSe 'resources/images/imagelists/Fail.png' 
									end;

set @HealthCheckRegressionImage =  case (@HealthCheckRegression + @RegressionTotalUncategorised)
								     WHEN 0 THEN 'resources/images/imagelists/Pass.png'
								     ELSe 'resources/images/imagelists/Fail.png' 
								   end;

-- -----------------------------------------------------
-- Return the results
-- -----------------------------------------------------
select @HealthCheckRoutingImage
	  ,@HealthCheckDuplicationImage
	  ,@HealthCheckRegressionImage
	  ,@HealthCheckRouting
	  ,@HealthCheckDuplication
	  ,@HealthCheckRegression
	  ,@HealthCheckRegressionExpected
	  ,@RoutingProdUnique
	  ,@RoutingProdOnly
	  ,@RoutingInBoth
	  ,@RoutingUATOnly
	  ,@RoutingUATUnique
	  ,@DuplicationProdDups
	  ,@DuplicationUATDups
	  ,@RegressionTotalCategorised
	  ,@RegressionTotalUncategorised
	  ,@RegressionWithoutRegression;

-- -----------------------------------------------------------------------------------------------------
CALL roverLogging(4,v_logging_process,'UI','End');
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
