-- Lab 02.01
-- Openlog file.
SPOOL apply_plsql_lab2.1.log

@/home/student/Data/cit325/oracle/lib/cleanup_oracle.sql
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- ------------------------------------------------------------------
-- Verify Step 1
-- ------------------------------------------------------------------
/* Drop the types from most to least dependent. */
DROP TYPE table_list;
DROP TYPE table_struct;
 
/* Create the record type structure. */
CREATE OR REPLACE
  TYPE table_struct IS OBJECT
  ( table_name    VARCHAR2(30)
  , column_cnt    NUMBER
  , row_cnt       NUMBER );
/
 
/* Create the collection of a record type structure. */
CREATE OR REPLACE
  TYPE table_list IS TABLE OF table_struct;
/

-- ------------------------------------------------------------------
-- Verify Step 2
-- ------------------------------------------------------------------
/* Drop the function before attempting to create it. */
DROP FUNCTION listing;
 
/* Create the listing function. */
CREATE OR REPLACE
FUNCTION listing RETURN table_list IS
 
  /* Variable list. */
  lv_column_cnt  NUMBER;
  lv_row_cnt     NUMBER;
 
  /* Declare a statement variable. */
  stmt  VARCHAR2(200);
 
  /* Declare a system reference cursor variable. */
  lv_refcursor  SYS_REFCURSOR;
  lv_table_cnt  NUMBER;
 
  /* Declare an output variable.  */
  lv_list  TABLE_LIST := table_list();
 
  /* Declare a table list cursor that excludes APEX tables. */
  CURSOR c IS
    SELECT table_name
    FROM   user_tables
    WHERE  table_name NOT IN
            ('DEPT','EMP','APEX$_ACL','APEX$_WS_WEBPG_SECTIONS','APEX$_WS_ROWS'
            ,'APEX$_WS_HISTORY','APEX$_WS_NOTES','APEX$_WS_LINKS'
            ,'APEX$_WS_TAGS','APEX$_WS_FILES','APEX$_WS_WEBPG_SECTION_HISTORY'
            ,'DEMO_USERS','DEMO_CUSTOMERS','DEMO_ORDERS','DEMO_PRODUCT_INFO'
            ,'DEMO_ORDER_ITEMS','DEMO_STATES');
 
  /* Declare a column count. */
  CURSOR cnt
  ( cv_table_name  VARCHAR2 ) IS
    SELECT   table_name
    ,        COUNT(column_id) AS cnt_columns
    FROM     user_tab_columns
    WHERE    table_name = cv_table_name
    GROUP BY table_name;
 
BEGIN
  /* Read through the data set of non-environment variables. */
  FOR i IN c LOOP
 
    /* Count the columns of a table. */
    FOR j IN cnt(i.table_name) LOOP
      lv_column_cnt := j.cnt_columns;
    END LOOP;
 
    /* Declare a statement. */
    stmt := 'SELECT COUNT(*) AS column_cnt FROM '||i.table_name;
 
    /* Open the cursor and write set to collection. */
    OPEN lv_refcursor FOR stmt;
    LOOP
      FETCH lv_refcursor INTO lv_table_cnt;
      EXIT WHEN lv_refcursor%NOTFOUND; 
      lv_list.EXTEND;
      lv_list(lv_list.COUNT) := table_struct(
                                    table_name => i.table_name
                                  , column_cnt => lv_column_cnt
                                  , row_cnt    => lv_table_cnt );
    END LOOP;
  END LOOP;
 
  RETURN lv_list;
END;
/

-- ------------------------------------------------------------------
-- Verify Step 3
-- ------------------------------------------------------------------
COL table_name   FORMAT A20     HEADING "Table Name"
COL column_cnt   FORMAT 9,999  HEADING "Column #"
COL row_cnt      FORMAT 9,999  HEADING "Row #"
SELECT table_name
,      column_cnt
,      row_cnt
FROM   TABLE(listing);

-- Commit inserted records.
COMMIT;

-- Close log file.
SPOOL OFF