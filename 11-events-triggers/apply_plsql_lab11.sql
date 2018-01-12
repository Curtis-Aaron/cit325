/*
   Name:   apply_plsql_lab11.sql
   Author: Calvin Milliron
   Date:   22-NOV-2017
*/

/* Run the library files. */
@/home/student/Data/cit325/oracle/lib/cleanup_oracle.sql
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open your log file and make sure the extension is ".log".
SPOOL apply_plsql_lab11.log

-- ------------------------------------------------------------------
-- Step 1
-- ------------------------------------------------------------------
-- Add text_file_name
ALTER TABLE item ADD text_file_name VARCHAR2(30);

-- Verify text_file_name
COLUMN table_name   FORMAT A14
COLUMN column_id    FORMAT 9999
COLUMN column_name  FORMAT A22
COLUMN data_type    FORMAT A12
SELECT   table_name
,        column_id
,        column_name
,        CASE
           WHEN nullable = 'N' THEN 'NOT NULL'
           ELSE ''
         END AS nullable
,        CASE
           WHEN data_type IN ('CHAR','VARCHAR2','NUMBER') THEN
             data_type||'('||data_length||')'
           ELSE
             data_type
         END AS data_type
FROM     user_tab_columns
WHERE    table_name = 'ITEM'
ORDER BY 2;

/* Create logger table. */
CREATE TABLE logger
( LOGGER_ID                 NUMBER
, OLD_ITEM_ID               NUMBER
, OLD_ITEM_BARCODE          VARCHAR2(20)
, OLD_ITEM_TYPE             NUMBER
, OLD_ITEM_TITLE            VARCHAR2(60)
, OLD_ITEM_SUBTITLE         VARCHAR2(60)
, OLD_ITEM_RATING           VARCHAR2(8)
, OLD_ITEM_RATING_AGENCY    VARCHAR2(4)
, OLD_ITEM_RELEASE_DATE	    DATE
, OLD_CREATED_BY            NUMBER
, OLD_CREATION_DATE         DATE
, OLD_LAST_UPDATED_BY       NUMBER
, OLD_LAST_UPDATE_DATE      DATE
, OLD_TEXT_FILE_NAME        VARCHAR2(40)
, NEW_ITEM_ID               NUMBER
, NEW_ITEM_BARCODE          VARCHAR2(20)
, NEW_ITEM_TYPE	            NUMBER
, NEW_ITEM_TITLE            VARCHAR2(60)
, NEW_ITEM_SUBTITLE         VARCHAR2(60)
, NEW_ITEM_RATING           VARCHAR2(8)
, NEW_ITEM_RATING_AGENCY    VARCHAR2(4)
, NEW_ITEM_RELEASE_DATE     DATE
, NEW_CREATED_BY            NUMBER
, NEW_CREATION_DATE         DATE
, NEW_LAST_UPDATED_BY       NUMBER
, NEW_LAST_UPDATE_DATE      DATE
, NEW_TEXT_FILE_NAME        VARCHAR2(40)
, CONSTRAINT logger_pk PRIMARY KEY (logger_id));

/* Create logger_s sequence. */
CREATE SEQUENCE logger_s;

/* Verify logger table */
desc logger

/* Test logger table */
DECLARE
  /* Dynamic cursor. */
  CURSOR get_row IS
    SELECT * FROM item WHERE item_title = 'Brave Heart';
BEGIN
  /* Read the dynamic cursor. */
  FOR i IN get_row LOOP
 
    INSERT INTO logger
    ( LOGGER_ID
    , OLD_ITEM_ID
    , OLD_ITEM_BARCODE
    , OLD_ITEM_TYPE
    , OLD_ITEM_TITLE
    , OLD_ITEM_SUBTITLE
    , OLD_ITEM_RATING
    , OLD_ITEM_RATING_AGENCY
    , OLD_ITEM_RELEASE_DATE
    , OLD_CREATED_BY
    , OLD_CREATION_DATE
    , OLD_LAST_UPDATED_BY
    , OLD_LAST_UPDATE_DATE
    , OLD_TEXT_FILE_NAME
    , NEW_ITEM_ID
    , NEW_ITEM_BARCODE
    , NEW_ITEM_TYPE
    , NEW_ITEM_TITLE
    , NEW_ITEM_SUBTITLE
    , NEW_ITEM_RATING
    , NEW_ITEM_RATING_AGENCY
    , NEW_ITEM_RELEASE_DATE
    , NEW_CREATED_BY
    , NEW_CREATION_DATE
    , NEW_LAST_UPDATED_BY
    , NEW_LAST_UPDATE_DATE
    , NEW_TEXT_FILE_NAME)
    VALUES
    ( logger_s.NEXTVAL
    , i.ITEM_ID
    , i.ITEM_BARCODE
    , i.ITEM_TYPE
    , i.ITEM_TITLE
    , i.ITEM_SUBTITLE
    , i.ITEM_RATING
    , i.ITEM_RATING_AGENCY
    , i.ITEM_RELEASE_DATE
    , i.CREATED_BY
    , i.CREATION_DATE
    , i.LAST_UPDATED_BY
    , i.LAST_UPDATE_DATE
    , i.TEXT_FILE_NAME
    , i.ITEM_ID
    , i.ITEM_BARCODE
    , i.ITEM_TYPE
    , i.ITEM_TITLE
    , i.ITEM_SUBTITLE
    , i.ITEM_RATING
    , i.ITEM_RATING_AGENCY
    , i.ITEM_RELEASE_DATE
    , i.CREATED_BY
    , i.CREATION_DATE
    , i.LAST_UPDATED_BY
    , i.LAST_UPDATE_DATE
    , i.TEXT_FILE_NAME);
 
  END LOOP;
END;
/

/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- ------------------------------------------------------------------
-- Step 2
-- ------------------------------------------------------------------
/* Create package definition*/
CREATE OR REPLACE
  PACKAGE manage_item IS

  PROCEDURE item_insert
  ( PV_NEW_ITEM_ID              NUMBER
  , PV_NEW_ITEM_BARCODE         VARCHAR2
  , PV_NEW_ITEM_TYPE            NUMBER
  , PV_NEW_ITEM_TITLE           VARCHAR2
  , PV_NEW_ITEM_SUBTITLE        VARCHAR2
  , PV_NEW_ITEM_RATING          VARCHAR2
  , PV_NEW_ITEM_RATING_AGENCY   VARCHAR2
  , PV_NEW_ITEM_RELEASE_DATE    DATE
  , PV_NEW_CREATED_BY           NUMBER
  , PV_NEW_CREATION_DATE        DATE
  , PV_NEW_LAST_UPDATED_BY      NUMBER
  , PV_NEW_LAST_UPDATE_DATE     DATE
  , PV_NEW_TEXT_FILE_NAME       VARCHAR2 );

  PROCEDURE item_insert
  ( PV_OLD_ITEM_ID              NUMBER
  , PV_OLD_ITEM_BARCODE         VARCHAR2
  , PV_OLD_ITEM_TYPE            NUMBER
  , PV_OLD_ITEM_TITLE           VARCHAR2
  , PV_OLD_ITEM_SUBTITLE        VARCHAR2
  , PV_OLD_ITEM_RATING          VARCHAR2
  , PV_OLD_ITEM_RATING_AGENCY   VARCHAR2
  , PV_OLD_ITEM_RELEASE_DATE    DATE
  , PV_OLD_CREATED_BY           NUMBER
  , PV_OLD_CREATION_DATE        DATE
  , PV_OLD_LAST_UPDATED_BY      NUMBER
  , PV_OLD_LAST_UPDATE_DATE     DATE
  , PV_OLD_TEXT_FILE_NAME       VARCHAR2
  , PV_NEW_ITEM_ID              NUMBER
  , PV_NEW_ITEM_BARCODE         VARCHAR2
  , PV_NEW_ITEM_TYPE            NUMBER
  , PV_NEW_ITEM_TITLE           VARCHAR2
  , PV_NEW_ITEM_SUBTITLE        VARCHAR2
  , PV_NEW_ITEM_RATING          VARCHAR2
  , PV_NEW_ITEM_RATING_AGENCY   VARCHAR2
  , PV_NEW_ITEM_RELEASE_DATE    DATE
  , PV_NEW_CREATED_BY           NUMBER
  , PV_NEW_CREATION_DATE        DATE
  , PV_NEW_LAST_UPDATED_BY      NUMBER
  , PV_NEW_LAST_UPDATE_DATE     DATE
  , PV_NEW_TEXT_FILE_NAME       VARCHAR2 );

  PROCEDURE item_insert
  ( PV_OLD_ITEM_ID              NUMBER
  , PV_OLD_ITEM_BARCODE         VARCHAR2
  , PV_OLD_ITEM_TYPE            NUMBER
  , PV_OLD_ITEM_TITLE           VARCHAR2
  , PV_OLD_ITEM_SUBTITLE        VARCHAR2
  , PV_OLD_ITEM_RATING          VARCHAR2
  , PV_OLD_ITEM_RATING_AGENCY   VARCHAR2
  , PV_OLD_ITEM_RELEASE_DATE    DATE
  , PV_OLD_CREATED_BY           NUMBER
  , PV_OLD_CREATION_DATE        DATE
  , PV_OLD_LAST_UPDATED_BY      NUMBER
  , PV_OLD_LAST_UPDATE_DATE     DATE
  , PV_OLD_TEXT_FILE_NAME       VARCHAR2 );

END manage_item;
/

/* Verify package */
desc manage_item

/* Create package body */
CREATE OR REPLACE
  PACKAGE BODY manage_item IS

  PROCEDURE item_insert
  ( PV_NEW_ITEM_ID              NUMBER
  , PV_NEW_ITEM_BARCODE         VARCHAR2
  , PV_NEW_ITEM_TYPE            NUMBER
  , PV_NEW_ITEM_TITLE           VARCHAR2
  , PV_NEW_ITEM_SUBTITLE        VARCHAR2
  , PV_NEW_ITEM_RATING          VARCHAR2
  , PV_NEW_ITEM_RATING_AGENCY   VARCHAR2
  , PV_NEW_ITEM_RELEASE_DATE    DATE
  , PV_NEW_CREATED_BY           NUMBER
  , PV_NEW_CREATION_DATE        DATE
  , PV_NEW_LAST_UPDATED_BY      NUMBER
  , PV_NEW_LAST_UPDATE_DATE     DATE
  , PV_NEW_TEXT_FILE_NAME       VARCHAR2 ) IS

    /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Insert log entry for an avenger. */
    manage_item.item_insert(
        PV_OLD_ITEM_ID => null
      , PV_OLD_ITEM_BARCODE => null
      , PV_OLD_ITEM_TYPE => null
      , PV_OLD_ITEM_TITLE => null
      , PV_OLD_ITEM_SUBTITLE => null
      , PV_OLD_ITEM_RATING => null
      , PV_OLD_ITEM_RATING_AGENCY => null
      , PV_OLD_ITEM_RELEASE_DATE => null
      , PV_OLD_CREATED_BY => null
      , PV_OLD_CREATION_DATE => null
      , PV_OLD_LAST_UPDATED_BY => null
      , PV_OLD_LAST_UPDATE_DATE => null
      , PV_OLD_TEXT_FILE_NAME => null
      , PV_NEW_ITEM_ID => PV_NEW_ITEM_ID
      , PV_NEW_ITEM_BARCODE => PV_NEW_ITEM_BARCODE
      , PV_NEW_ITEM_TYPE => PV_NEW_ITEM_TYPE
      , PV_NEW_ITEM_TITLE => PV_NEW_ITEM_TITLE
      , PV_NEW_ITEM_SUBTITLE => PV_NEW_ITEM_SUBTITLE
      , PV_NEW_ITEM_RATING => PV_NEW_ITEM_RATING
      , PV_NEW_ITEM_RATING_AGENCY => PV_NEW_ITEM_RATING_AGENCY
      , PV_NEW_ITEM_RELEASE_DATE => PV_NEW_ITEM_RELEASE_DATE
      , PV_NEW_CREATED_BY => PV_NEW_CREATED_BY
      , PV_NEW_CREATION_DATE => PV_NEW_CREATION_DATE
      , PV_NEW_LAST_UPDATED_BY => PV_NEW_LAST_UPDATED_BY
      , PV_NEW_LAST_UPDATE_DATE => PV_NEW_LAST_UPDATE_DATE
      , PV_NEW_TEXT_FILE_NAME => PV_NEW_TEXT_FILE_NAME);
  EXCEPTION
    /* Exception handler. */
    WHEN OTHERS THEN
     RETURN;
  END item_insert;

  PROCEDURE item_insert
  ( PV_OLD_ITEM_ID              NUMBER
  , PV_OLD_ITEM_BARCODE         VARCHAR2
  , PV_OLD_ITEM_TYPE            NUMBER
  , PV_OLD_ITEM_TITLE           VARCHAR2
  , PV_OLD_ITEM_SUBTITLE        VARCHAR2
  , PV_OLD_ITEM_RATING          VARCHAR2
  , PV_OLD_ITEM_RATING_AGENCY   VARCHAR2
  , PV_OLD_ITEM_RELEASE_DATE    DATE
  , PV_OLD_CREATED_BY           NUMBER
  , PV_OLD_CREATION_DATE        DATE
  , PV_OLD_LAST_UPDATED_BY      NUMBER
  , PV_OLD_LAST_UPDATE_DATE     DATE
  , PV_OLD_TEXT_FILE_NAME       VARCHAR2
  , PV_NEW_ITEM_ID              NUMBER
  , PV_NEW_ITEM_BARCODE         VARCHAR2
  , PV_NEW_ITEM_TYPE            NUMBER
  , PV_NEW_ITEM_TITLE           VARCHAR2
  , PV_NEW_ITEM_SUBTITLE        VARCHAR2
  , PV_NEW_ITEM_RATING          VARCHAR2
  , PV_NEW_ITEM_RATING_AGENCY   VARCHAR2
  , PV_NEW_ITEM_RELEASE_DATE    DATE
  , PV_NEW_CREATED_BY           NUMBER
  , PV_NEW_CREATION_DATE        DATE
  , PV_NEW_LAST_UPDATED_BY      NUMBER
  , PV_NEW_LAST_UPDATE_DATE     DATE
  , PV_NEW_TEXT_FILE_NAME       VARCHAR2 ) IS

    /* Declare local logging value. */
    lv_logger_id  NUMBER;

    /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Get a sequence. */
    lv_logger_id := logger_s.NEXTVAL;

    /* Set a savepoint. */
    SAVEPOINT starting;

    /* Insert log entry for an item. */
    INSERT INTO logger
    ( LOGGER_ID
    , OLD_ITEM_ID
    , OLD_ITEM_BARCODE
    , OLD_ITEM_TYPE
    , OLD_ITEM_TITLE
    , OLD_ITEM_SUBTITLE
    , OLD_ITEM_RATING
    , OLD_ITEM_RATING_AGENCY
    , OLD_ITEM_RELEASE_DATE
    , OLD_CREATED_BY
    , OLD_CREATION_DATE
    , OLD_LAST_UPDATED_BY
    , OLD_LAST_UPDATE_DATE
    , OLD_TEXT_FILE_NAME
    , NEW_ITEM_ID
    , NEW_ITEM_BARCODE
    , NEW_ITEM_TYPE
    , NEW_ITEM_TITLE
    , NEW_ITEM_SUBTITLE
    , NEW_ITEM_RATING
    , NEW_ITEM_RATING_AGENCY
    , NEW_ITEM_RELEASE_DATE
    , NEW_CREATED_BY
    , NEW_CREATION_DATE
    , NEW_LAST_UPDATED_BY
    , NEW_LAST_UPDATE_DATE
    , NEW_TEXT_FILE_NAME )
    VALUES
    ( lv_logger_id
    , PV_OLD_ITEM_ID
    , PV_OLD_ITEM_BARCODE
    , PV_OLD_ITEM_TYPE
    , PV_OLD_ITEM_TITLE
    , PV_OLD_ITEM_SUBTITLE
    , PV_OLD_ITEM_RATING
    , PV_OLD_ITEM_RATING_AGENCY
    , PV_OLD_ITEM_RELEASE_DATE
    , PV_OLD_CREATED_BY
    , PV_OLD_CREATION_DATE
    , PV_OLD_LAST_UPDATED_BY
    , PV_OLD_LAST_UPDATE_DATE
    , PV_OLD_TEXT_FILE_NAME
    , PV_NEW_ITEM_ID
    , PV_NEW_ITEM_BARCODE
    , PV_NEW_ITEM_TYPE
    , PV_NEW_ITEM_TITLE
    , PV_NEW_ITEM_SUBTITLE
    , PV_NEW_ITEM_RATING
    , PV_NEW_ITEM_RATING_AGENCY
    , PV_NEW_ITEM_RELEASE_DATE
    , PV_NEW_CREATED_BY
    , PV_NEW_CREATION_DATE
    , PV_NEW_LAST_UPDATED_BY
    , PV_NEW_LAST_UPDATE_DATE
    , PV_NEW_TEXT_FILE_NAME );

    /* Commit the independent write. */
    COMMIT;
  EXCEPTION
    /* Exception handler. */
    WHEN OTHERS THEN
      ROLLBACK TO starting;
      RETURN;
  END item_insert;

  PROCEDURE item_insert
  ( PV_OLD_ITEM_ID              NUMBER
  , PV_OLD_ITEM_BARCODE         VARCHAR2
  , PV_OLD_ITEM_TYPE            NUMBER
  , PV_OLD_ITEM_TITLE           VARCHAR2
  , PV_OLD_ITEM_SUBTITLE        VARCHAR2
  , PV_OLD_ITEM_RATING          VARCHAR2
  , PV_OLD_ITEM_RATING_AGENCY   VARCHAR2
  , PV_OLD_ITEM_RELEASE_DATE    DATE
  , PV_OLD_CREATED_BY           NUMBER
  , PV_OLD_CREATION_DATE        DATE
  , PV_OLD_LAST_UPDATED_BY      NUMBER
  , PV_OLD_LAST_UPDATE_DATE     DATE
  , PV_OLD_TEXT_FILE_NAME       VARCHAR2 ) IS

    /* Set an autonomous transaction. */
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    /* Insert log entry for an avenger. */
    manage_item.item_insert(
        PV_OLD_ITEM_ID => PV_OLD_ITEM_ID
      , PV_OLD_ITEM_BARCODE => PV_OLD_ITEM_BARCODE
      , PV_OLD_ITEM_TYPE => PV_OLD_ITEM_TYPE
      , PV_OLD_ITEM_TITLE => PV_OLD_ITEM_TITLE
      , PV_OLD_ITEM_SUBTITLE => PV_OLD_ITEM_SUBTITLE
      , PV_OLD_ITEM_RATING => PV_OLD_ITEM_RATING
      , PV_OLD_ITEM_RATING_AGENCY => PV_OLD_ITEM_RATING_AGENCY
      , PV_OLD_ITEM_RELEASE_DATE => PV_OLD_ITEM_RELEASE_DATE
      , PV_OLD_CREATED_BY => PV_OLD_CREATED_BY
      , PV_OLD_CREATION_DATE => PV_OLD_CREATION_DATE
      , PV_OLD_LAST_UPDATED_BY => PV_OLD_LAST_UPDATED_BY
      , PV_OLD_LAST_UPDATE_DATE => PV_OLD_LAST_UPDATE_DATE
      , PV_OLD_TEXT_FILE_NAME => PV_OLD_TEXT_FILE_NAME
      , PV_NEW_ITEM_ID => null
      , PV_NEW_ITEM_BARCODE => null
      , PV_NEW_ITEM_TYPE => null
      , PV_NEW_ITEM_TITLE => null
      , PV_NEW_ITEM_SUBTITLE => null
      , PV_NEW_ITEM_RATING => null
      , PV_NEW_ITEM_RATING_AGENCY => null
      , PV_NEW_ITEM_RELEASE_DATE => null
      , PV_NEW_CREATED_BY => null
      , PV_NEW_CREATION_DATE => null
      , PV_NEW_LAST_UPDATED_BY => null
      , PV_NEW_LAST_UPDATE_DATE => null
      , PV_NEW_TEXT_FILE_NAME => null);
  EXCEPTION
    /* Exception handler. */
    WHEN OTHERS THEN
     RETURN;
  END item_insert;
END manage_item;
/

/* Test package */
DECLARE
  /* Dynamic cursor. */
  CURSOR get_row IS
    SELECT * FROM item WHERE item_title = 'King Arthur';
BEGIN
  /* Read the dynamic cursor. */
  FOR i IN get_row LOOP
    manage_item.item_insert(
        PV_NEW_ITEM_ID => i.ITEM_ID
      , PV_NEW_ITEM_BARCODE => i.ITEM_BARCODE
      , PV_NEW_ITEM_TYPE => i.ITEM_TYPE
      , PV_NEW_ITEM_TITLE => i.ITEM_TITLE || '-Inserted'
      , PV_NEW_ITEM_SUBTITLE => i.ITEM_SUBTITLE
      , PV_NEW_ITEM_RATING => i.ITEM_RATING
      , PV_NEW_ITEM_RATING_AGENCY => i.ITEM_RATING_AGENCY
      , PV_NEW_ITEM_RELEASE_DATE => i.ITEM_RELEASE_DATE
      , PV_NEW_CREATED_BY => i.CREATED_BY
      , PV_NEW_CREATION_DATE => i.CREATION_DATE
      , PV_NEW_LAST_UPDATED_BY => i.LAST_UPDATED_BY
      , PV_NEW_LAST_UPDATE_DATE => i.LAST_UPDATE_DATE
      , PV_NEW_TEXT_FILE_NAME => i.TEXT_FILE_NAME);
 
     manage_item.item_insert(
        PV_OLD_ITEM_ID => i.ITEM_ID
      , PV_OLD_ITEM_BARCODE => i.ITEM_BARCODE
      , PV_OLD_ITEM_TYPE => i.ITEM_TYPE
      , PV_OLD_ITEM_TITLE => i.ITEM_TITLE
      , PV_OLD_ITEM_SUBTITLE => i.ITEM_SUBTITLE
      , PV_OLD_ITEM_RATING => i.ITEM_RATING
      , PV_OLD_ITEM_RATING_AGENCY => i.ITEM_RATING_AGENCY
      , PV_OLD_ITEM_RELEASE_DATE => i.ITEM_RELEASE_DATE
      , PV_OLD_CREATED_BY => i.CREATED_BY
      , PV_OLD_CREATION_DATE => i.CREATION_DATE
      , PV_OLD_LAST_UPDATED_BY => i.LAST_UPDATED_BY
      , PV_OLD_LAST_UPDATE_DATE => i.LAST_UPDATE_DATE
      , PV_OLD_TEXT_FILE_NAME => i.TEXT_FILE_NAME
      , PV_NEW_ITEM_ID => i.ITEM_ID
      , PV_NEW_ITEM_BARCODE => i.ITEM_BARCODE
      , PV_NEW_ITEM_TYPE => i.ITEM_TYPE
      , PV_NEW_ITEM_TITLE => i.ITEM_TITLE || '-Changed'
      , PV_NEW_ITEM_SUBTITLE => i.ITEM_SUBTITLE
      , PV_NEW_ITEM_RATING => i.ITEM_RATING
      , PV_NEW_ITEM_RATING_AGENCY => i.ITEM_RATING_AGENCY
      , PV_NEW_ITEM_RELEASE_DATE => i.ITEM_RELEASE_DATE
      , PV_NEW_CREATED_BY => i.CREATED_BY
      , PV_NEW_CREATION_DATE => i.CREATION_DATE
      , PV_NEW_LAST_UPDATED_BY => i.LAST_UPDATED_BY
      , PV_NEW_LAST_UPDATE_DATE => i.LAST_UPDATE_DATE
      , PV_NEW_TEXT_FILE_NAME => i.TEXT_FILE_NAME);

     manage_item.item_insert(
        PV_OLD_ITEM_ID => i.ITEM_ID
      , PV_OLD_ITEM_BARCODE => i.ITEM_BARCODE
      , PV_OLD_ITEM_TYPE => i.ITEM_TYPE
      , PV_OLD_ITEM_TITLE => i.ITEM_TITLE || '-Deleted'
      , PV_OLD_ITEM_SUBTITLE => i.ITEM_SUBTITLE
      , PV_OLD_ITEM_RATING => i.ITEM_RATING
      , PV_OLD_ITEM_RATING_AGENCY => i.ITEM_RATING_AGENCY
      , PV_OLD_ITEM_RELEASE_DATE => i.ITEM_RELEASE_DATE
      , PV_OLD_CREATED_BY => i.CREATED_BY
      , PV_OLD_CREATION_DATE => i.CREATION_DATE
      , PV_OLD_LAST_UPDATED_BY => i.LAST_UPDATED_BY
      , PV_OLD_LAST_UPDATE_DATE => i.LAST_UPDATE_DATE
      , PV_OLD_TEXT_FILE_NAME => i.TEXT_FILE_NAME);
 
  END LOOP;
END;
/

/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- ------------------------------------------------------------------
-- Step 3
-- ------------------------------------------------------------------
/* Create a database trigger. */
CREATE OR REPLACE
  TRIGGER item_trig
  BEFORE INSERT OR UPDATE OF item_title ON item
  FOR EACH ROW
  DECLARE
    lv_input_title    VARCHAR2(40);
    lv_title          VARCHAR2(20);
    lv_subtitle       VARCHAR2(20);
    lv_update_needed  NUMBER;
    /* Declare exception. */
    e EXCEPTION;
    PRAGMA EXCEPTION_INIT(e,-20001);
  BEGIN
    /* Check for an event and log accordingly. */
    IF INSERTING THEN
      /* Log the ATTEMPTED insert change to the item table in the logger table. */
      manage_item.item_insert(
          PV_NEW_ITEM_ID => :new.ITEM_ID
        , PV_NEW_ITEM_BARCODE => :new.ITEM_BARCODE
        , PV_NEW_ITEM_TYPE => :new.ITEM_TYPE
        , PV_NEW_ITEM_TITLE => :new.ITEM_TITLE
        , PV_NEW_ITEM_SUBTITLE => :new.ITEM_SUBTITLE
        , PV_NEW_ITEM_RATING => :new.ITEM_RATING
        , PV_NEW_ITEM_RATING_AGENCY => :new.ITEM_RATING_AGENCY
        , PV_NEW_ITEM_RELEASE_DATE => :new.ITEM_RELEASE_DATE
        , PV_NEW_CREATED_BY => :new.CREATED_BY
        , PV_NEW_CREATION_DATE => :new.CREATION_DATE
        , PV_NEW_LAST_UPDATED_BY => :new.LAST_UPDATED_BY
        , PV_NEW_LAST_UPDATE_DATE => :new.LAST_UPDATE_DATE
        , PV_NEW_TEXT_FILE_NAME => :new.TEXT_FILE_NAME );

      /* Assign the title */
      lv_input_title := :new.ITEM_TITLE;
      lv_update_needed := 0;
 
      /* Check for a subtitle. */
      IF REGEXP_INSTR(lv_input_title,':') > 0 AND
         REGEXP_INSTR(lv_input_title,':') = LENGTH(lv_input_title) THEN
        /* Shave off the colon. */
        lv_title   := SUBSTR(lv_input_title, 1, REGEXP_INSTR(lv_input_title,':') - 1);
        lv_subtitle := '';
        lv_update_needed := 1;
      ELSIF REGEXP_INSTR(lv_input_title,':') > 0 THEN
        /* Split the string into two parts. */
        lv_title    := SUBSTR(lv_input_title, 1, REGEXP_INSTR(lv_input_title,':') - 1);
        lv_subtitle := LTRIM(SUBSTR(lv_input_title,REGEXP_INSTR(lv_input_title,':') + 1, LENGTH(lv_input_title)));
        lv_update_needed := 1;
      END IF;

      /* Update and report if needed */
      IF lv_update_needed = 1 THEN
          /* Log the FINAL insert change to the item table in the logger table. */
          manage_item.item_insert(
              PV_OLD_ITEM_ID => :new.ITEM_ID
            , PV_OLD_ITEM_BARCODE => :new.ITEM_BARCODE
            , PV_OLD_ITEM_TYPE => :new.ITEM_TYPE
            , PV_OLD_ITEM_TITLE => :new.ITEM_TITLE
            , PV_OLD_ITEM_SUBTITLE => :new.ITEM_SUBTITLE
            , PV_OLD_ITEM_RATING => :new.ITEM_RATING
            , PV_OLD_ITEM_RATING_AGENCY => :new.ITEM_RATING_AGENCY
            , PV_OLD_ITEM_RELEASE_DATE => :new.ITEM_RELEASE_DATE
            , PV_OLD_CREATED_BY => :new.CREATED_BY
            , PV_OLD_CREATION_DATE => :new.CREATION_DATE
            , PV_OLD_LAST_UPDATED_BY => :new.LAST_UPDATED_BY
            , PV_OLD_LAST_UPDATE_DATE => :new.LAST_UPDATE_DATE
            , PV_OLD_TEXT_FILE_NAME => :new.TEXT_FILE_NAME
            , PV_NEW_ITEM_ID => :new.ITEM_ID
            , PV_NEW_ITEM_BARCODE => :new.ITEM_BARCODE
            , PV_NEW_ITEM_TYPE => :new.ITEM_TYPE
            , PV_NEW_ITEM_TITLE => lv_title
            , PV_NEW_ITEM_SUBTITLE => lv_subtitle
            , PV_NEW_ITEM_RATING => :new.ITEM_RATING
            , PV_NEW_ITEM_RATING_AGENCY => :new.ITEM_RATING_AGENCY
            , PV_NEW_ITEM_RELEASE_DATE => :new.ITEM_RELEASE_DATE
            , PV_NEW_CREATED_BY => :new.CREATED_BY
            , PV_NEW_CREATION_DATE => :new.CREATION_DATE
            , PV_NEW_LAST_UPDATED_BY => :new.LAST_UPDATED_BY
            , PV_NEW_LAST_UPDATE_DATE => :new.LAST_UPDATE_DATE
            , PV_NEW_TEXT_FILE_NAME => :new.TEXT_FILE_NAME );

          /* Change values to be inserted */
          :new.ITEM_TITLE := lv_title;
          :new.ITEM_SUBTITLE := lv_subtitle;
      END IF;

      /* Check for an empty item_id primary key column value,
         and assign the next sequence value when it is missing. */
      IF :new.item_id IS NULL THEN
        SELECT item_s1.NEXTVAL
        INTO   :new.item_id
        FROM   dual;
      END IF;
    ELSIF UPDATING THEN
      /* Log the ATTEMPTED update change to the item table in the logging table. */
      manage_item.item_insert(
          PV_OLD_ITEM_ID => :old.ITEM_ID
        , PV_OLD_ITEM_BARCODE => :old.ITEM_BARCODE
        , PV_OLD_ITEM_TYPE => :old.ITEM_TYPE
        , PV_OLD_ITEM_TITLE => :old.ITEM_TITLE
        , PV_OLD_ITEM_SUBTITLE => :old.ITEM_SUBTITLE
        , PV_OLD_ITEM_RATING => :old.ITEM_RATING
        , PV_OLD_ITEM_RATING_AGENCY => :old.ITEM_RATING_AGENCY
        , PV_OLD_ITEM_RELEASE_DATE => :old.ITEM_RELEASE_DATE
        , PV_OLD_CREATED_BY => :old.CREATED_BY
        , PV_OLD_CREATION_DATE => :old.CREATION_DATE
        , PV_OLD_LAST_UPDATED_BY => :old.LAST_UPDATED_BY
        , PV_OLD_LAST_UPDATE_DATE => :old.LAST_UPDATE_DATE
        , PV_OLD_TEXT_FILE_NAME => :old.TEXT_FILE_NAME
        , PV_NEW_ITEM_ID => :new.ITEM_ID
        , PV_NEW_ITEM_BARCODE => :new.ITEM_BARCODE
        , PV_NEW_ITEM_TYPE => :new.ITEM_TYPE
        , PV_NEW_ITEM_TITLE => :new.ITEM_TITLE
        , PV_NEW_ITEM_SUBTITLE => :new.ITEM_SUBTITLE
        , PV_NEW_ITEM_RATING => :new.ITEM_RATING
        , PV_NEW_ITEM_RATING_AGENCY => :new.ITEM_RATING_AGENCY
        , PV_NEW_ITEM_RELEASE_DATE => :new.ITEM_RELEASE_DATE
        , PV_NEW_CREATED_BY => :new.CREATED_BY
        , PV_NEW_CREATION_DATE => :new.CREATION_DATE
        , PV_NEW_LAST_UPDATED_BY => :new.LAST_UPDATED_BY
        , PV_NEW_LAST_UPDATE_DATE => :new.LAST_UPDATE_DATE
        , PV_NEW_TEXT_FILE_NAME => :new.TEXT_FILE_NAME );

      /* Assign the title */
      lv_input_title := :new.ITEM_TITLE;
      lv_update_needed := 0;
 
      /* Check for a subtitle. */
      IF REGEXP_INSTR(lv_input_title,':') > 0 AND
         REGEXP_INSTR(lv_input_title,':') = LENGTH(lv_input_title) THEN
        /* Shave off the colon. */
        lv_title   := SUBSTR(lv_input_title, 1, REGEXP_INSTR(lv_input_title,':') - 1);
        lv_subtitle := '';
        lv_update_needed := 1;
      ELSIF REGEXP_INSTR(lv_input_title,':') > 0 THEN
        /* Split the string into two parts. */
        lv_title    := SUBSTR(lv_input_title, 1, REGEXP_INSTR(lv_input_title,':') - 1);
        lv_subtitle := LTRIM(SUBSTR(lv_input_title,REGEXP_INSTR(lv_input_title,':') + 1, LENGTH(lv_input_title)));
        lv_update_needed := 1;
      END IF;

      /* Update and report if needed */
      IF lv_update_needed = 1 THEN
          /* Log the FINAL update change to the item table in the logging table. */
          manage_item.item_insert(
              PV_OLD_ITEM_ID => :new.ITEM_ID
            , PV_OLD_ITEM_BARCODE => :new.ITEM_BARCODE
            , PV_OLD_ITEM_TYPE => :new.ITEM_TYPE
            , PV_OLD_ITEM_TITLE => :new.ITEM_TITLE
            , PV_OLD_ITEM_SUBTITLE => :new.ITEM_SUBTITLE
            , PV_OLD_ITEM_RATING => :new.ITEM_RATING
            , PV_OLD_ITEM_RATING_AGENCY => :new.ITEM_RATING_AGENCY
            , PV_OLD_ITEM_RELEASE_DATE => :new.ITEM_RELEASE_DATE
            , PV_OLD_CREATED_BY => :new.CREATED_BY
            , PV_OLD_CREATION_DATE => :new.CREATION_DATE
            , PV_OLD_LAST_UPDATED_BY => :new.LAST_UPDATED_BY
            , PV_OLD_LAST_UPDATE_DATE => :new.LAST_UPDATE_DATE
            , PV_OLD_TEXT_FILE_NAME => :new.TEXT_FILE_NAME
            , PV_NEW_ITEM_ID => :new.ITEM_ID
            , PV_NEW_ITEM_BARCODE => :new.ITEM_BARCODE
            , PV_NEW_ITEM_TYPE => :new.ITEM_TYPE
            , PV_NEW_ITEM_TITLE => lv_title
            , PV_NEW_ITEM_SUBTITLE => lv_subtitle
            , PV_NEW_ITEM_RATING => :new.ITEM_RATING
            , PV_NEW_ITEM_RATING_AGENCY => :new.ITEM_RATING_AGENCY
            , PV_NEW_ITEM_RELEASE_DATE => :new.ITEM_RELEASE_DATE
            , PV_NEW_CREATED_BY => :new.CREATED_BY
            , PV_NEW_CREATION_DATE => :new.CREATION_DATE
            , PV_NEW_LAST_UPDATED_BY => :new.LAST_UPDATED_BY
            , PV_NEW_LAST_UPDATE_DATE => :new.LAST_UPDATE_DATE
            , PV_NEW_TEXT_FILE_NAME => :new.TEXT_FILE_NAME );

          /* Change values to be updated */
          :new.ITEM_TITLE := lv_title;
          :new.ITEM_SUBTITLE := lv_subtitle;
      END IF;
    END IF;
  END item_trig;
/

/* Show errors and description. */
SHOW errors

/* Create delete trigger. */
CREATE OR REPLACE
  TRIGGER item_delete_trig
  BEFORE DELETE ON item
  FOR EACH ROW
  DECLARE
    /* Declare exception. */
    e EXCEPTION;
    PRAGMA EXCEPTION_INIT(e,-20001);
  BEGIN
    IF DELETING THEN
      /* Log the delete change to the item table in the logging table. */
      manage_item.item_insert(
          PV_OLD_ITEM_ID => :old.ITEM_ID
        , PV_OLD_ITEM_BARCODE => :old.ITEM_BARCODE
        , PV_OLD_ITEM_TYPE => :old.ITEM_TYPE
        , PV_OLD_ITEM_TITLE => :old.ITEM_TITLE
        , PV_OLD_ITEM_SUBTITLE => :old.ITEM_SUBTITLE
        , PV_OLD_ITEM_RATING => :old.ITEM_RATING
        , PV_OLD_ITEM_RATING_AGENCY => :old.ITEM_RATING_AGENCY
        , PV_OLD_ITEM_RELEASE_DATE => :old.ITEM_RELEASE_DATE
        , PV_OLD_CREATED_BY => :old.CREATED_BY
        , PV_OLD_CREATION_DATE => :old.CREATION_DATE
        , PV_OLD_LAST_UPDATED_BY => :old.LAST_UPDATED_BY
        , PV_OLD_LAST_UPDATE_DATE => :old.LAST_UPDATE_DATE
        , PV_OLD_TEXT_FILE_NAME => :old.TEXT_FILE_NAME );
    END IF;
  END item_delete_trig;
/

/* Show errors and description. */
SHOW errors


/* The lab instructs me to delete a row in the common_lookup table where common_lookup_type is 'BLU_RAY'
   with the ON DELETE CASCADE clause in effect, but there is no such row to begin with, so instead, I will create it*/
/* Create BLU_RAY row */
INSERT INTO common_lookup (
    COMMON_LOOKUP_ID
  , COMMON_LOOKUP_TABLE
  , COMMON_LOOKUP_COLUMN
  , COMMON_LOOKUP_TYPE
  , COMMON_LOOKUP_CODE
  , COMMON_LOOKUP_MEANING
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE)
VALUES (
    COMMON_LOOKUP_S1.NEXTVAL
  , 'ITEM'
  , 'ITEM_TYPE'
  , 'BLU-RAY'
  , ''
  , 'Blu-ray'
  , 3
  , SYSDATE
  , 3
  , SYSDATE);

/* Verify BLU_RAY row */
COL common_lookup_table   FORMAT A14 HEADING "Common Lookup|Table"
COL common_lookup_column  FORMAT A14 HEADING "Common Lookup|Column"
COL common_lookup_type    FORMAT A14 HEADING "Common Lookup|Type"
SELECT common_lookup_table
,      common_lookup_column
,      common_lookup_type
FROM   common_lookup
WHERE  common_lookup_table = 'ITEM'
AND    common_lookup_column = 'ITEM_TYPE'
AND    common_lookup_type = 'BLU-RAY';

/* Make item_desc nullable for next inserts */
ALTER TABLE item DROP CONSTRAINT nn_item_4;

/* Three insert statement that test the conditions of the event trigger */
INSERT INTO item (
    ITEM_ID
  , ITEM_BARCODE
  , ITEM_TYPE
  , ITEM_TITLE
  , ITEM_SUBTITLE
  , ITEM_RATING
  , ITEM_RATING_AGENCY
  , ITEM_RELEASE_DATE
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE)
VALUES (
    ITEM_S1.NEXTVAL
  , 'B01IHVPA8'
  , (SELECT common_lookup_id FROM common_lookup WHERE common_lookup_table = 'ITEM' AND common_lookup_column = 'ITEM_TYPE' AND common_lookup_type = 'BLU-RAY')
  , 'Bourne'
  , ''
  , 'PG-13'
  , 'MPAA'
  , TO_DATE('6-Dec-16')
  , 3
  , SYSDATE
  , 3
  , SYSDATE);

INSERT INTO item (
    ITEM_ID
  , ITEM_BARCODE
  , ITEM_TYPE
  , ITEM_TITLE
  , ITEM_SUBTITLE
  , ITEM_RATING
  , ITEM_RATING_AGENCY
  , ITEM_RELEASE_DATE
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE)
VALUES (
    ITEM_S1.NEXTVAL
  , 'B01AT251XY'
  , (SELECT common_lookup_id FROM common_lookup WHERE common_lookup_table = 'ITEM' AND common_lookup_column = 'ITEM_TYPE' AND common_lookup_type = 'BLU-RAY')
  , 'Bourne Legacy:'
  , ''
  , 'PG-13'
  , 'MPAA'
  , TO_DATE('5-Apr-16')
  , 3
  , SYSDATE
  , 3
  , SYSDATE);

INSERT INTO item (
    ITEM_ID
  , ITEM_BARCODE
  , ITEM_TYPE
  , ITEM_TITLE
  , ITEM_SUBTITLE
  , ITEM_RATING
  , ITEM_RATING_AGENCY
  , ITEM_RELEASE_DATE
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_DATE)
VALUES (
    ITEM_S1.NEXTVAL
  , 'B018FK66TU'
  , (SELECT common_lookup_id FROM common_lookup WHERE common_lookup_table = 'ITEM' AND common_lookup_column = 'ITEM_TYPE' AND common_lookup_type = 'BLU-RAY')
  , 'Star Wars: The Force Awakens'
  , ''
  , 'PG-13'
  , 'MPAA'
  , TO_DATE('5-Apr-16')
  , 3
  , SYSDATE
  , 3
  , SYSDATE);

/* Verify inserted entries */
COL item_id        FORMAT 9999 HEADING "Item|ID #"
COL item_title     FORMAT A20  HEADING "Item Title"
COL item_subtitle  FORMAT A20  HEADING "Item Subtitle"
COL item_rating    FORMAT A6   HEADING "Item|Rating"
COL item_type      FORMAT A18   HEADING "Item|Type"
SELECT i.item_id
,      i.item_title
,      i.item_subtitle
,      i.item_rating
,      cl.common_lookup_meaning AS item_type
FROM   item i INNER JOIN common_lookup cl
ON     i.item_type = cl.common_lookup_id
WHERE  cl.common_lookup_type = 'BLU-RAY';

/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

/* Update Star Wars: The Force Awakens */
/* Produces no error message because the title and subtitle were automatically updated appropriately by the trigger */
UPDATE item SET item_title = 'Star Wars: The Force Awakens' WHERE ITEM_BARCODE = 'B018FK66TU';

/* verify bad update request was corrected by trigger */
COL item_id        FORMAT 9999 HEADING "Item|ID #"
COL item_title     FORMAT A20  HEADING "Item Title"
COL item_subtitle  FORMAT A20  HEADING "Item Subtitle"
COL item_rating    FORMAT A6   HEADING "Item|Rating"
COL item_type      FORMAT A18   HEADING "Item|Type"
SELECT i.item_id
,      i.item_title
,      i.item_subtitle
,      i.item_rating
,      cl.common_lookup_meaning AS item_type
FROM   item i INNER JOIN common_lookup cl
ON     i.item_type = cl.common_lookup_id
WHERE  cl.common_lookup_type = 'BLU-RAY';

/* Query the logger table. */
/* Shows old title as the attempted modification and the new title the corrected modification */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

/* Delete the entry */
DELETE FROM item WHERE ITEM_BARCODE = 'B018FK66TU';

/* Verify delete */
COL item_id        FORMAT 9999 HEADING "Item|ID #"
COL item_title     FORMAT A20  HEADING "Item Title"
COL item_subtitle  FORMAT A20  HEADING "Item Subtitle"
COL item_rating    FORMAT A6   HEADING "Item|Rating"
COL item_type      FORMAT A18   HEADING "Item|Type"
SELECT i.item_id
,      i.item_title
,      i.item_subtitle
,      i.item_rating
,      cl.common_lookup_meaning AS item_type
FROM   item i INNER JOIN common_lookup cl
ON     i.item_type = cl.common_lookup_id
WHERE  cl.common_lookup_type = 'BLU-RAY';

/* Query the logger table. */
COL logger_id       FORMAT 9999 HEADING "Logger|ID #"
COL old_item_id     FORMAT 9999 HEADING "Old|Item|ID #"
COL old_item_title  FORMAT A20  HEADING "Old Item Title"
COL new_item_id     FORMAT 9999 HEADING "New|Item|ID #"
COL new_item_title  FORMAT A30  HEADING "New Item Title"
SELECT l.logger_id
,      l.old_item_id
,      l.old_item_title
,      l.new_item_id
,      l.new_item_title
FROM   logger l;

-- Close your log file.
SPOOL OFF
