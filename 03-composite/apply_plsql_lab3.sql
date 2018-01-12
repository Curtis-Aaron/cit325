/*
   Name:   apply_plsql_lab3.sql
   Author: Calvin Milliron
   Date:   23-SEP-2017
*/

-- Open your log file and make sure the extension is ".log".
SPOOL apply_plsql_lab3.log

-- Add an environment command to allow PL/SQL to print to console.
SET SERVEROUTPUT ON SIZE UNLIMITED
SET VERIFY OFF
SET DEFINE ON

CREATE OR REPLACE
  FUNCTION verify_date
  ( pv_date_in  VARCHAR2) RETURN DATE IS
  /* Local return variable. */
  lv_date  DATE;
BEGIN
  /* Check for a DD-MON-RR or DD-MON-YYYY string. */
  IF REGEXP_LIKE(pv_date_in,'^[0-9]{2,2}-[ADFJMNOS][ACEOPU][BCGLNPRTVY]-([0-9]{2,2}|[0-9]{4,4})$') THEN
    /* Case statement checks for 28 or 29, 30, or 31 day month. */
    CASE
      /* Valid 31 day month date value. */
      WHEN SUBSTR(pv_date_in,4,3) IN ('JAN','MAR','MAY','JUL','AUG','OCT','DEC') AND
           TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 31 THEN 
        lv_date := pv_date_in;
      /* Valid 30 day month date value. */
      WHEN SUBSTR(pv_date_in,4,3) IN ('APR','JUN','SEP','NOV') AND
           TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 30 THEN 
        lv_date := pv_date_in;
      /* Valid 28 or 29 day month date value. */
      WHEN SUBSTR(pv_date_in,4,3) = 'FEB' THEN
        /* Verify 2-digit or 4-digit year. */
        IF (LENGTH(pv_date_in) = 9 AND MOD(TO_NUMBER(SUBSTR(pv_date_in,8,2)) + 2000,4) = 0 OR
            LENGTH(pv_date_in) = 11 AND MOD(TO_NUMBER(SUBSTR(pv_date_in,8,4)),4) = 0) AND
            TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 29 THEN
          lv_date := pv_date_in;
        ELSE /* Not a leap year. */
          IF TO_NUMBER(SUBSTR(pv_date_in,1,2)) BETWEEN 1 AND 28 THEN
            lv_date := pv_date_in;
          ELSE
            lv_date := '';
          END IF;
        END IF;
      ELSE
        /* Assign a default date. */
        lv_date := '';
    END CASE;
  ELSE
    /* Assign a default date. */
    lv_date := '';
  END IF;
  /* Return date. */
  RETURN lv_date;
END;
/

-- Put your code here, like this "Hello Whom!" program.
DECLARE
  /* Declare a collection of strings. */
  TYPE list IS TABLE OF VARCHAR2(100);
  lv_strings LIST := list('','','');
  TYPE three_type IS RECORD
(  xnum     NUMBER
,  xdate    DATE
,  xstring  VARCHAR2(30));
  lv_struct THREE_TYPE;
BEGIN
  lv_strings(1) := '&1';
  lv_strings(2) := '&2';
  lv_strings(3) := '&3';
  /* Loop through list of values to find only the numbers. */
  FOR i IN 1..lv_strings.COUNT LOOP
    IF verify_date(lv_strings(i)) IS NOT NULL THEN
       lv_struct.xdate := lv_strings(i);
    ELSIF REGEXP_LIKE(lv_strings(i),'^[[:digit:]]*$') THEN
       lv_struct.xnum := lv_strings(i);
    ELSIF REGEXP_LIKE(lv_strings(i),'^[[:alnum:]]*$') THEN
       lv_struct.xstring := lv_strings(i);
    END IF;
  END LOOP;
  dbms_output.put_line('Record ['||lv_struct.xnum||'] ['||lv_struct.xstring||'] ['||lv_struct.xdate||']');
END;
/

-- Close your log file.
SPOOL OFF
QUIT;