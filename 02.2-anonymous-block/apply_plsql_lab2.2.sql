-- This is a sample file, and you should display a multiple-line comment
-- identifying the file, author, and date. Here's the format:
/*
   Name:   apply_plsql_lab2.sql
   Author: Calvin Milliron
   Date:   23-SEP-2017
*/
 
-- Put code that you call from other scripts here because they may create
-- their own log files. For example, you call other program scripts by
-- putting an "@" symbol before the name of a relative file name or a 
-- fully qualified file name. 
 
 
-- Open your log file and make sure the extension is ".txt".
SPOOL apply_plsql_lab2.2.log
 
-- Add an environment command to allow PL/SQL to print to console.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET DEFINE ON
 
-- Put your code here, like this "Hello Whom!" program.
DECLARE
  pv_whom VARCHAR2(100);
BEGIN
  pv_whom := '&1';
  IF pv_whom IS NULL THEN
    dbms_output.put_line('Hello World!');
  ELSE
    dbms_output.put_line('Hello '||SUBSTR(pv_whom,1,10)||'!');
  END IF;
END;
/
 
-- Close your log file.
SPOOL OFF
 
-- Instruct the program to exit SQL*Plus, which you need when you call a
-- a program from the command line. Please make sure you comment the 
-- following command when you want to remain inside the interactive
-- SQL*Plus connection.
QUIT;