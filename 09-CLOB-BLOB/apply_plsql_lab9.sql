/*
   Name:   apply_plsql_lab9.sql
   Author: Calvin Milliron
   Date:   09-NOV-2017
*/

/* Set environment variables. */
SET ECHO ON
SET FEEDBACK ON
SET PAGESIZE 49999
SET SERVEROUTPUT ON SIZE UNLIMITED
 
/* Run the library files. */
@/home/student/Data/cit325/oracle/lib/cleanup_oracle.sql
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open your log file and make sure the extension is ".log".
SPOOL apply_plsql_lab9.log

-- Drop avenger table.
DROP TABLE avenger;

-- Create an avenger table.
CREATE TABLE avenger
( avenger_id      NUMBER
, first_name      VARCHAR2(20)
, last_name       VARCHAR2(20)
, character_name  VARCHAR2(20))
 ORGANIZATION EXTERNAL
 ( TYPE oracle_loader
   DEFAULT DIRECTORY uploadtext
   ACCESS PARAMETERS
   ( RECORDS DELIMITED BY NEWLINE CHARACTERSET US7ASCII
     BADFILE     'UPLOAD':'avenger.bad'
     DISCARDFILE 'UPLOAD':'avenger.dis'
     LOGFILE     'UPLOAD':'avenger.log'
     FIELDS TERMINATED BY ','
     OPTIONALLY ENCLOSED BY "'"
     MISSING FIELD VALUES ARE NULL )
   LOCATION ('avenger.csv'))
REJECT LIMIT 0;
-- '

-- Verify avenger.csv was read in
SELECT * FROM avenger;

-- Drop file_list table.
DROP TABLE file_list;

-- Create an file_list table.
CREATE TABLE file_list
( file_name VARCHAR2(60))
ORGANIZATION EXTERNAL
  ( TYPE oracle_loader
    DEFAULT DIRECTORY uploadtext
    ACCESS PARAMETERS
    ( RECORDS DELIMITED BY NEWLINE CHARACTERSET US7ASCII
      PREPROCESSOR uploadtext:'dir_list.sh'
      BADFILE     'UPLOADTEXT':'dir_list.bad'
      DISCARDFILE 'UPLOADTEXT':'dir_list.dis'
      LOGFILE     'UPLOADTEXT':'dir_list.log'
      FIELDS TERMINATED BY ','
      OPTIONALLY ENCLOSED BY "'"
      MISSING FIELD VALUES ARE NULL)
    LOCATION ('dir_list.sh'))
  REJECT LIMIT UNLIMITED;
-- '

-- Describe file_list table
desc file_list;

-- Verify directory contents were read in
SELECT * FROM file_list;

-- Create load_clob_from_file procedure
CREATE OR REPLACE PROCEDURE load_clob_from_file
( src_file_name     IN VARCHAR2
, table_name        IN VARCHAR2
, column_name       IN VARCHAR2
, primary_key_name  IN VARCHAR2
, primary_key_value IN VARCHAR2 ) IS
 
  -- Define local variables for DBMS_LOB.LOADCLOBFROMFILE procedure.
  des_clob   CLOB;
  src_clob   BFILE := BFILENAME('UPLOADTEXT',src_file_name);
  des_offset NUMBER := 1;
  src_offset NUMBER := 1;
  ctx_lang   NUMBER := dbms_lob.default_lang_ctx;
  warning    NUMBER;
 
  -- Define a pre-reading size.
  src_clob_size NUMBER;
 
  -- Define local variable for Native Dynamic SQL.
  stmt VARCHAR2(2000);
 
BEGIN
 
  -- Opening source file is a mandatory operation.
  IF dbms_lob.fileexists(src_clob) = 1 AND NOT dbms_lob.isopen(src_clob) = 1 THEN
    src_clob_size := dbms_lob.getlength(src_clob);
    dbms_lob.OPEN(src_clob,DBMS_LOB.LOB_READONLY);
  END IF;
 
  -- Assign dynamic string to statement.
  stmt := 'UPDATE '||table_name||' '
       || 'SET    '||column_name||' = empty_clob() '
       || 'WHERE  '||primary_key_name||' = '||''''||primary_key_value||''' '
       || 'RETURNING '||column_name||' INTO :locator';
 
  -- Run dynamic statement.       
  EXECUTE IMMEDIATE stmt USING OUT des_clob;
 
  -- Read and write file to CLOB, close source file and commit.
  dbms_lob.loadclobfromfile( dest_lob     => des_clob
                           , src_bfile    => src_clob
                           , amount       => dbms_lob.getlength(src_clob)
                           , dest_offset  => des_offset
                           , src_offset   => src_offset
                           , bfile_csid   => dbms_lob.default_csid
                           , lang_context => ctx_lang
                           , warning      => warning );
 
  -- Close open source file.
  dbms_lob.CLOSE(src_clob);
 
  -- Commit write and conditionally acknowledge it.
  IF src_clob_size = dbms_lob.getlength(des_clob) THEN
    $IF $$DEBUG = 1 $THEN
      dbms_output.put_line('Success!');
    $END
    COMMIT;
  ELSE
    $IF $$DEBUG = 1 $THEN
      dbms_output.put_line('Failure.');
    $END
    RAISE dbms_lob.operation_failed;
  END IF;
 
END load_clob_from_file;
/

-- Describe load_clob_from_file
desc load_clob_from_file;

-- Verify load_clob_from_file
DECLARE
 /* Declare a cursor to find a single row from the item table. */
 CURSOR c IS
   SELECT i.item_id
   ,      i.item_title
   FROM   item i INNER JOIN common_lookup cl
   ON     i.item_type = cl.common_lookup_id
   WHERE  UPPER(i.item_title) LIKE '%GOBLET%'
   AND    UPPER(cl.common_lookup_meaning) = 'DVD: WIDE SCREEN';
BEGIN
  /* Read the cursor and load one large text file to the row. */
  FOR i IN c LOOP
    load_clob_from_file( src_file_name     => 'HarryPotter4.txt'
                       , table_name        => 'ITEM'
                       , column_name       => 'ITEM_DESC'
                       , primary_key_name  => 'ITEM_ID'
                       , primary_key_value => TO_CHAR(i.item_id) );
  END LOOP;
END;
/

-- Verify anonymous block
SELECT i.item_id
,      i.item_title
,      LENGTH(i.item_desc)
FROM   item i INNER JOIN common_lookup cl
ON     i.item_type = cl.common_lookup_id
WHERE  UPPER(i.item_title) LIKE '%GOBLET%'
AND    UPPER(cl.common_lookup_meaning) = 'DVD: WIDE SCREEN';

-- Fix titles
UPDATE item
SET    item_title = 'Harry Potter and the Sorcerer''s Stone'
WHERE  item_title = 'Harry Potter and the Sorcer''s Stone';

-- Add column
ALTER TABLE item
ADD text_file_name VARCHAR(30);

-- Verify altered table
COL text_file_name  FORMAT A16
COL item_title      FORMAT A42
SELECT   DISTINCT
         text_file_name
,        item_title
FROM     item i INNER JOIN common_lookup cl
ON       i.item_type = cl.common_lookup_id
WHERE    REGEXP_LIKE(i.item_title,'^.*'||'Harry'||'.*$')
AND      cl.common_lookup_table = 'ITEM'
AND      cl.common_lookup_column = 'ITEM_TYPE'
AND      REGEXP_LIKE(cl.common_lookup_type,'^(dvd|vhs).*$','i')
ORDER BY i.item_title;

-- Update titles with file names
UPDATE item i
SET    i.text_file_name = 'HarryPotter1.txt'
WHERE  i.item_title LIKE '%Sorcerer''s Stone%';

UPDATE item i
SET    i.text_file_name = 'HarryPotter2.txt'
WHERE  i.item_title LIKE '%Chamber of Secrets%';

UPDATE item i
SET    i.text_file_name = 'HarryPotter3.txt'
WHERE  i.item_title LIKE '%Prisoner of Azkaban%';

UPDATE item i
SET    i.text_file_name = 'HarryPotter4.txt'
WHERE  i.item_title LIKE '%Goblet of Fire%';

UPDATE item i
SET    i.text_file_name = 'HarryPotter5.txt'
WHERE  i.item_title LIKE '%Order of the Phoenix%';


-- Verify updated file names
COL text_file_name  FORMAT A16
COL item_title      FORMAT A42
SELECT   DISTINCT
         text_file_name
,        item_title
FROM     item i INNER JOIN common_lookup cl
ON       i.item_type = cl.common_lookup_id
WHERE    REGEXP_LIKE(i.item_title,'^.*'||'Harry'||'.*$')
AND      cl.common_lookup_table = 'ITEM'
AND      cl.common_lookup_column = 'ITEM_TYPE'
AND      REGEXP_LIKE(cl.common_lookup_type,'^(dvd|vhs).*$','i')
ORDER BY i.text_file_name;

-- Create upload_item_description procedure
CREATE OR REPLACE PROCEDURE upload_item_description
( pv_item_title     IN VARCHAR2 ) IS
 
 -- Declare a cursor to find a all titles from the item table. 
 CURSOR c IS
   SELECT item_id
   ,      text_file_name
   FROM   item
   WHERE  UPPER(item_title) LIKE '%'||UPPER(pv_item_title)||'%';

BEGIN
  -- Read the cursor and load one large text file to each row.
  FOR i IN c LOOP
    load_clob_from_file( src_file_name     => i.text_file_name
                       , table_name        => 'ITEM'
                       , column_name       => 'ITEM_DESC'
                       , primary_key_name  => 'ITEM_ID'
                       , primary_key_value => TO_CHAR(i.item_id) );
  END LOOP;

END upload_item_description;
/

-- Run procedure
EXECUTE upload_item_description('Harry Potter');

-- Verify Procedure
COL item_id     FORMAT 9999
COL item_title  FORMAT A44
COL text_size   FORMAT 999,999
SET PAGESIZE 99
SELECT   item_id
,        item_title
,        LENGTH(item_desc) AS text_size
FROM     item
WHERE    REGEXP_LIKE(item_title,'^Harry Potter.*$')
AND      item_type IN
          (SELECT common_lookup_id 
           FROM   common_lookup 
           WHERE  common_lookup_table = 'ITEM' 
           AND    common_lookup_column = 'ITEM_TYPE'
           AND    REGEXP_LIKE(common_lookup_type,'^(dvd|vhs).*$','i'))
ORDER BY item_id;

-- Close log file.
SPOOL OFF
