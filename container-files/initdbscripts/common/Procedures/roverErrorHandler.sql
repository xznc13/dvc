DELIMITER $$
DROP PROCEDURE IF EXISTS roverErrorHandler;
CREATE PROCEDURE roverErrorHandler(IN in_logging_process text, in_error_details text)
BEGIN
-- -----------------------------------------------------------------------------------------------------
-- (C) Red Hound Limited 2015
-- -----------------------------------------------------------------------------------------------------
--
-- Title	ROVER - Error Handler
--
-- DB:		MARIADB
--
-- Purpose	Output the error to the log
--
-- Version	V0.1 - Initial draft
--
-- -----------------------------------------------------------------------------------------------------

-- -----------------------------------------------------
-- Logging variables
-- -----------------------------------------------------
DECLARE v_logging_process TEXT DEFAULT 'roverErrorHandler';

-- -----------------------------------------------------
-- End of declares
-- -----------------------------------------------------

set v_logging_process = in_logging_process;

call roverLogging (1,v_logging_process, 'ErrorHandler', 'Starting');

call roverLogging (1,v_logging_process, 'ErrorHandler', REPLACE(in_error_details,char(39),"''"));

call roverLogging (1,v_logging_process, 'ErrorHandler', 'Leaving');
-- -----------------------------------------------------------------------------------------------------
end $$
DELIMITER ;
-- -----------------------------------------------------------------------------------------------------
