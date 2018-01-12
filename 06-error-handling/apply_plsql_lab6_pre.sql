/*
   Name:   apply_plsql_lab6_prep.sql
   Author: Calvin Milliron
   Date:   21-OCT-2017
*/

/* Set environment variables. */
SET ECHO ON
SET FEEDBACK ON
SET PAGESIZE 49999
SET SERVEROUTPUT ON SIZE UNLIMITED
 
/* Run the library files. */
@/home/student/Data/cit325/oracle/lib/cleanup_oracle.sql
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql
 
/* Display common_lookup_tab collection and common_lookup_obj type, which should be none
   because of the cleanup.sql script. */
COL object_name FORMAT A30 HEADING "Object Name"
COL object_type FORMAT A30 HEADING "Object Type"
SELECT   object_name
,        object_type
FROM     user_objects
WHERE    REGEXP_LIKE(object_name,'^common_lookup.*$','i')
AND      object_type = 'TYPE'
ORDER BY 2 DESC;
 
/* Conditionally drop the common lookup types, table and then objectWHERE. */
BEGIN
  FOR i IN (SELECT   type_name
            FROM     user_types
            WHERE    REGEXP_LIKE(type_name,'^common_lookup.*$','i')
            ORDER BY 1 DESC) LOOP
    EXECUTE IMMEDIATE 'DROP TYPE '||i.type_name;
  END LOOP;
END;
/
 
/* Create object type. */
CREATE OR REPLACE 
  TYPE common_lookup_obj IS OBJECT
  ( common_lookup_table    VARCHAR2(30)
  , common_lookup_column   VARCHAR2(30)
  , common_lookup_type     VARCHAR2(30)
  , common_lookup_code     VARCHAR2(8)
  , common_lookup_meaning  VARCHAR2(255));
/
 
-- Create collection of object type.
CREATE OR REPLACE
  TYPE common_lookup_tab IS TABLE OF common_lookup_obj;
/
 
-- Create lookup type.
CREATE OR REPLACE
  TYPE common_lookup_type IS OBJECT
  ( TYPE     VARCHAR2(30)
  , meaning  VARCHAR2(255));
/
 
-- Create collection of lookup type.
CREATE OR REPLACE
  TYPE common_lookup_type_tab IS TABLE OF common_lookup_type;
/
 
/* Display common_lookup_tab collection and common_lookup_obj type. */
COL object_name FORMAT A30 HEADING "Object Name"
COL object_type FORMAT A30 HEADING "Object Type"
SELECT   object_name
,        object_type
FROM     user_objects
WHERE    REGEXP_LIKE(object_name,'^common_lookup.*$','i')
AND      object_type = 'TYPE'
ORDER BY 2 DESC;
 
-- Declare anonymous block.
DECLARE
  /* Declare input values. */
  lv_common_lookup_table    VARCHAR2(30) := 'ITEM';
  lv_common_lookup_column   VARCHAR2(30) := 'ITEM_TYPE';
  lv_common_lookup_code     VARCHAR2(8);
 
  /* Declare collections of types. */
  lv_common_lookup_type_tab  COMMON_LOOKUP_TYPE_TAB :=
    common_lookup_type_tab( common_lookup_type('BLU-RAY','Blu-ray')
                          , common_lookup_type('HD','Digital HD')
                          , common_lookup_type('SD','Digital SD')
                          , common_lookup_type('DVD','DVD'));
 
  /* Declare empty collection. */
  lv_common_lookup_tab  COMMON_LOOKUP_TAB := common_lookup_tab();
BEGIN
  /* Implement assignment of variables inside a loop, which mimics
     how you would handle them if they were read from a cursor loop. */
  FOR i IN 1..lv_common_lookup_type_tab.COUNT LOOP
    lv_common_lookup_tab.EXTEND;
    lv_common_lookup_tab(lv_common_lookup_tab.COUNT) := 
       common_lookup_obj( lv_common_lookup_table
                        , lv_common_lookup_column
                        , lv_common_lookup_type_tab(i).TYPE
                        , lv_common_lookup_code
                        , lv_common_lookup_type_tab(i).meaning );
  END LOOP;
 
  /* Insert the values from the collection into a table. */
  FOR i IN 1..lv_common_lookup_tab.COUNT LOOP
    INSERT INTO common_lookup
    VALUES
    ( common_lookup_s1.NEXTVAL
    , lv_common_lookup_table
    , lv_common_lookup_column
    , lv_common_lookup_tab(i).common_lookup_type
    , lv_common_lookup_code
    , lv_common_lookup_tab(i).common_lookup_meaning
    , 1
    , SYSDATE
    , 1
    , SYSDATE );
  END LOOP;
  /* Make insert permanent. */
  COMMIT;
END;
/
 
/* Query table for insert. */
COL common_lookup_table   FORMAT A12
COL common_lookup_column  FORMAT A12
COL common_lookup_type    FORMAT A12
SELECT  common_lookup_table
,       common_lookup_column
,       common_lookup_type
FROM    common_lookup
WHERE   common_lookup_type IN ('BLU-RAY','HD','SD','DVD');
 
/* Update NR to PG-13 ratings. */
UPDATE item
SET    item_rating = 'PG-13'
WHERE  item_rating = 'NR';
 
/* Update an incorrect title. */
UPDATE item
SET    item_title = 'Harry Potter and the Sorcerer''s Stone'
WHERE  item_title = 'Harry Potter and the Sorcer''s Stone';
 
/* Remove database trigger to reoranize item ratings. */
DROP TRIGGER item_t1;
 
/* Conditionally drop the common lookup types, table and then objectWHERE. */
BEGIN
  FOR i IN (SELECT   type_name
            FROM     user_types
            WHERE    REGEXP_LIKE(type_name,'^item_title.*$','i')
            ORDER BY 1 DESC) LOOP
    EXECUTE IMMEDIATE 'DROP TYPE '||i.type_name;
  END LOOP;
END;
/
 
CREATE OR REPLACE
  TYPE item_title_obj IS OBJECT
  ( title     VARCHAR2(60)
  , subtitle  VARCHAR2(60)
  , rating    VARCHAR2(8));
/
 
CREATE OR REPLACE
  TYPE item_title_tab IS TABLE OF item_title_obj;
/
 
DESC item
 
/* Remove case descriptors from the subtitle. */
UPDATE item i
SET    i.item_subtitle = NULL
WHERE  REGEXP_LIKE(item_subtitle,'^Two-Disc Special Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^2-Disc Special Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Three-Disc Special Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Special Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Special Collector''s Edition.*$','i') -- '
OR     REGEXP_LIKE(item_subtitle,'^Two-Disc Collector''s Edition.*$','i') -- '
OR     REGEXP_LIKE(item_subtitle,'^Full Screen Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^2-Disc Full Screen Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Widescreen Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Wide Screen Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Fullscreen Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Platinum Series Special Extended Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Fullscreen Special Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Widescreen Special Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Unrated Extended Cut Special Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Unrated Extended Cut Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^2-Disc Ultimate Version.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^PG-13 Full Screen Edition.*$','i')
OR     REGEXP_LIKE(item_subtitle,'^Unrated Extended Cut.*$','i');
 
SET SERVEROUTPUT ON SIZE UNLIMITED
 
/* Add Blu-ray, HD, and SD. */
DECLARE
  /* Declare local variable. */
  lv_item_barcode  VARCHAR2(20);
  lv_item_type     NUMBER;
  lv_release_date  DATE;
 
  /* Declare who-audit constants. */
  lv_user_id        NUMBER := 1;
  lv_creation_date  DATE := TRUNC(SYSDATE);
 
  /* Declare a collection of titles. */  
  lv_item_title_tab  ITEM_TITLE_TAB := item_title_tab();
 
  /* Declare new barcode cursor. */
  CURSOR update_barcode
  ( cv_title        VARCHAR2
  , cv_subtitle  VARCHAR2 ) IS
    SELECT DISTINCT
           REGEXP_REPLACE(i.item_barcode,'B0','B1',1,1) AS barcode
    ,      i.item_type
    ,      i.item_release_date
    FROM   item i
    WHERE  i.item_title = cv_title
    AND    NVL(i.item_subtitle,'x') = NVL(cv_subtitle,'x');    
 
  /* Declare item type cursor. */
  CURSOR item_type 
  ( cv_lookup_table   VARCHAR2
  , cv_lookup_column  VARCHAR2 ) IS
    SELECT cl.common_lookup_id
    FROM   common_lookup cl
    WHERE  common_lookup_table = cv_lookup_table
    AND    common_lookup_column = cv_lookup_column
    AND    common_lookup_type IN ('BLU-RAY','HD','SD','DVD');
 
  /* Declare film cursor. */
  CURSOR item_title_cur IS
    SELECT DISTINCT
           item_title
    ,      item_subtitle
    ,      item_rating
    FROM   item
    WHERE  item_type IN (SELECT common_lookup_id
                         FROM   common_lookup
                         WHERE  common_lookup_table = 'ITEM'
                         AND    common_lookup_column = 'ITEM_TYPE'
                         AND    common_lookup_type IN
                                  ('DVD_FULL_SCREEN'
                                  ,'DVD_WIDE_SCREEN'
                                  ,'VHS_SINGLE_TAPE'
                                  ,'VHS_DOUBLE_TAPE'));
 
BEGIN
  /* Read list of distinct item titles. */
  FOR i IN item_title_cur LOOP
    lv_item_title_tab.EXTEND;
    lv_item_title_tab(lv_item_title_tab.COUNT) :=
      item_title_obj( i.item_title
                    , i.item_subtitle
                    , i.item_rating );
  END LOOP;
 
  FOR i IN 1..lv_item_title_tab.COUNT LOOP
    /* Generate a new barcode value. */
    FOR j IN update_barcode( lv_item_title_tab(i).title
                           , lv_item_title_tab(i).subtitle ) LOOP
      lv_item_barcode := j.barcode;
      lv_item_type := j.item_type;
      lv_release_date := j.item_release_date;
    END LOOP;
 
    /* Read through the item types. */
    FOR j IN item_type ('ITEM','ITEM_TYPE') LOOP
 
      /* Insert into the item table. */
      INSERT
      INTO   item
      ( item_id 
      , item_barcode
      , item_type
      , item_title
      , item_subtitle
      , item_desc
      , item_release_date
      , item_rating
      , item_rating_agency
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date )
      VALUES
      ( item_s1.NEXTVAL
      , lv_item_barcode
      , j.common_lookup_id
      , lv_item_title_tab(i).title
      , lv_item_title_tab(i).subtitle
      , EMPTY_CLOB()
      , lv_release_date
      , lv_item_title_tab(i).rating
      ,'MPAA'
      , lv_user_id
      , lv_creation_date
      , lv_user_id
      , lv_creation_date );
 
    END LOOP;
  END LOOP;
 
  /* Commit the write. */
  COMMIT;
END;
/
 
/* Query the results after the insert to the item table. */
COL TYPE  FORMAT A20
COL total FORMAT 99999
SELECT   cl.common_lookup_meaning AS TYPE
,        COUNT(i.item_type) AS total
FROM     item i INNER JOIN common_lookup cl
ON       i.item_type = cl.common_lookup_id
GROUP BY cl.common_lookup_meaning;
 
/* Display rating_agency table and rating_agency_s sequence, which should be none
   because of the cleanup.sql script. */
COL object_name FORMAT A30 HEADING "Object Name"
COL object_type FORMAT A30 HEADING "Object Type"
SELECT   object_name
,        object_type
FROM     user_objects
WHERE    REGEXP_LIKE(object_name,'^rating_agency.*$','i')
ORDER BY 2 DESC;
 
/* Conditionally drop table and sequence. */
BEGIN
  FOR i IN (SELECT   object_name
            ,        object_type
            FROM     user_objects
            WHERE    REGEXP_LIKE(object_name,'^rating_agency.*$','i')
            ORDER BY 2 DESC) LOOP
    IF i.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/
 
/* Create new sequence. */
CREATE SEQUENCE rating_agency_s START WITH 1001;
 
/* Create new table. */
CREATE TABLE rating_agency AS
  SELECT rating_agency_s.NEXTVAL AS rating_agency_id
  ,      il.item_rating AS rating
  ,      il.rating_meaning
  ,      il.item_rating_agency AS rating_agency
  ,      il.rating_agency_meaning
  FROM  (SELECT DISTINCT
                i.item_rating
         ,      cl.common_lookup_meaning AS rating_meaning
         ,      i.item_rating_agency
         ,      cl.common_lookup_meaning AS rating_agency_meaning
         FROM   item i INNER JOIN common_lookup cl
         ON     i.item_rating_agency = cl.common_lookup_type
         WHERE  cl.common_lookup_table = 'ITEM'
         AND    cl.common_lookup_column = 'ITEM_RATING_AGENCY') il;
 
/* Fix data incongruency in common lookup table. */
UPDATE common_lookup cl
SET    cl.common_lookup_code = 'EC'
WHERE  cl.common_lookup_table = 'ITEM'
AND    cl.common_lookup_column = 'ITEM_RATING'
AND    cl.common_lookup_type = 'ESRB EC';
 
/* Add missing rating. */
INSERT
INTO   rating_agency
SELECT rating_agency_s.NEXTVAL
,      cl1.common_lookup_code
,      cl1.common_lookup_meaning
,      cl2.common_lookup_type
,      cl2.common_lookup_meaning
FROM   common_lookup cl1 CROSS JOIN common_lookup cl2
WHERE  cl1.common_lookup_table = 'ITEM'
AND    cl1.common_lookup_column = 'ITEM_RATING'
AND    cl1.common_lookup_code = 'EC'
AND    cl2.common_lookup_table = 'ITEM'
AND    cl2.common_lookup_column = 'ITEM_RATING_AGENCY'
AND    cl2.common_lookup_code = 'ESRB';
 
/* Add missing rating. */
INSERT
INTO   rating_agency
SELECT rating_agency_s.NEXTVAL
,      cl1.common_lookup_code
,      cl1.common_lookup_meaning
,      cl2.common_lookup_type
,      cl2.common_lookup_meaning
FROM   common_lookup cl1 CROSS JOIN common_lookup cl2
WHERE  cl1.common_lookup_table = 'ITEM'
AND    cl1.common_lookup_column = 'ITEM_RATING'
AND    cl1.common_lookup_code = 'E'
AND    cl2.common_lookup_table = 'ITEM'
AND    cl2.common_lookup_column = 'ITEM_RATING_AGENCY'
AND    cl2.common_lookup_code = 'ESRB';
 
UPDATE rating_agency ra
SET    ra.rating_agency_meaning =
         (SELECT cl.common_lookup_meaning
          FROM   common_lookup cl
          WHERE  cl.common_lookup_table = 'ITEM'
          AND    cl.common_lookup_column = 'ITEM_RATING_AGENCY'
          AND    ra.rating_agency = cl.common_lookup_type);
 
UPDATE rating_agency ra
SET    ra.rating_meaning =
         (SELECT cl.common_lookup_meaning
          FROM   common_lookup cl
          WHERE  cl.common_lookup_table = 'ITEM'
          AND    cl.common_lookup_column = 'ITEM_RATING'
          AND    ra.rating = cl.common_lookup_code);
 
/* Add a foreign key to table created by query. */
ALTER TABLE rating_agency
  ADD CONSTRAINT pk_rating_agency PRIMARY KEY (rating_agency_id);
 
/* Describe the item table before changes. */
DESC item
 
/* Add column to table. */
ALTER TABLE item
  ADD (rating_agency_id NUMBER);
 
/* Describe the item table after adding the column. */
DESC item
 
/* Add foreign key column. */
ALTER TABLE item
  ADD CONSTRAINT fk_item_4 FOREIGN KEY (rating_agency_id)
      REFERENCES rating_agency(rating_agency_id);
 
/* Display rating_agency table and rating_agency_s sequence after creation. */
COL object_name FORMAT A30 HEADING "Object Name"
COL object_type FORMAT A30 HEADING "Object Type"
SELECT   object_name
,        object_type
FROM     user_objects
WHERE    REGEXP_LIKE(object_name,'^rating_agency.*$','i')
ORDER BY 2 DESC;
 
/* Add the foreign keys that match the RATING_AGENCY table. */
UPDATE item i
SET    rating_agency_id = (SELECT ra.rating_agency_id
                           FROM   rating_agency ra
                           WHERE  ra.rating = i.item_rating
                           AND    ra.rating_agency = i.item_rating_agency);
 
/* Query results from new rating_agency_id column. */
COL rating_agency_id FORMAT 9999 HEADING "Rating|Agency|ID #"
COL rating           FORMAT A8   HEADING "Rating"
COL rating_agency    FORMAT A8   HEADING "Rating|Agency"
COL rating_meaning   FORMAT A40  HEADING "Rating Meaning"
SELECT   DISTINCT
         ra.rating_agency_id
,        i.item_rating AS rating
,        i.item_rating_agency AS rating_agency
,        cl.common_lookup_meaning AS rating_meaning
FROM     rating_agency ra INNER JOIN item i
ON       ra.rating = i.item_rating
AND      ra.rating_agency = i.item_rating_agency INNER JOIN common_lookup cl
ON       cl.common_lookup_type = i.item_rating_agency
WHERE    cl.common_lookup_table = 'ITEM'
AND      cl.common_lookup_column = 'ITEM_RATING_AGENCY'
ORDER BY 3, 2;
 
/* Remove column to table. */
ALTER TABLE item
  DROP COLUMN item_rating;
 
ALTER TABLE item
  DROP COLUMN item_rating_agency;
 
/* Query results from new rating_agency_id column. */
COL rating_agency_id        FORMAT 9999 HEADING "Rating|Agency|ID #"
COL rating                  FORMAT A6   HEADING "Rating"
COL rating_meaning          FORMAT A14  HEADING "Rating Meaning"
COL rating_agency           FORMAT A8   HEADING "Rating|Agency"
COL rating_agency_meaning   FORMAT A40  HEADING "Rating Agency Meaning"
SELECT   DISTINCT
         ra.rating_agency_id
,        ra.rating
,        SUBSTR(REGEXP_SUBSTR(ra.rating_meaning,'\s[A-Za-z].*$',1,1),2,14) AS rating_meaning
,        ra.rating_agency
,        ra.rating_agency_meaning
FROM     rating_agency ra LEFT JOIN item i
ON       ra.rating_agency_id = i.rating_agency_id
ORDER BY CASE
           WHEN ra.rating = 'EC'    THEN 1
           WHEN ra.rating = 'E'     THEN 2
           WHEN ra.rating = 'E10+'  THEN 3
           WHEN ra.rating = 'T'     THEN 4
           WHEN ra.rating = 'G'     THEN 5
           WHEN ra.rating = 'PG'    THEN 6
           WHEN ra.rating = 'PG-13' THEN 7
           WHEN ra.rating = 'R'     THEN 8
         END;
 
/* Alter the rating_agency_id column and make it not null. */
ALTER TABLE item
  MODIFY (rating_agency_id NUMBER CONSTRAINT nn_item_12 NOT NULL);
 
/* Describe the item table after adding a not null constraint. */
DESC item
 
/* Add the temporal activity missing columns. */
ALTER TABLE common_lookup
  ADD (begin_date  DATE)
  ADD (end_date    DATE);
 
/* Set store opening as default begin date. */
UPDATE  common_lookup
SET     begin_date = '01-JAN-2001'
WHERE  (common_lookup_table = 'ITEM'
AND     common_lookup_column = 'ITEM_TYPE'
AND     common_lookup_type NOT IN ('BLU-RAY','HD','SD','DVD'))
OR NOT (common_lookup_table = 'ITEM'
AND     common_lookup_column = 'ITEM_TYPE');
 
/* Set store opening as secondary default begin date. */
UPDATE common_lookup
SET    begin_date = TRUNC(SYSDATE)
WHERE  common_lookup_table = 'ITEM'
AND    common_lookup_column = 'ITEM_TYPE'
AND    common_lookup_type IN ('BLU-RAY','HD','SD','DVD');
 
/* Set end date on various DVD and VHS formats. */
UPDATE common_lookup cl
SET    cl.end_date = TRUNC(SYSDATE) - 1
WHERE  cl.common_lookup_table = 'ITEM'
AND    cl.common_lookup_column = 'ITEM_TYPE'
AND    REGEXP_LIKE(cl.common_lookup_type,'^(DVD|VHS).+$','i');
 
/* Obsolete common lookup value for the ITEM table. */
UPDATE common_lookup
SET    end_date = TRUNC(SYSDATE) - 1
WHERE  common_lookup_table = 'ITEM'
AND    common_lookup_column IN ('ITEM_RATING','ITEM_RATING_AGENCY');
 
/* Conditionally drop the NC_ERROR table and NC_ERROR_S1 sequence. */
BEGIN
  FOR i IN (SELECT   object_name
            ,        object_type
            FROM     user_objects
            WHERE    REGEXP_LIKE(object_name,'^nc_error.*$','i')
            ORDER BY 2 DESC) LOOP
    IF i.object_type = 'TABLE' THEN
      EXECUTE IMMEDIATE 'DROP TABLE '||i.object_name||' CASCADE CONSTRAINTS';
    ELSE
      EXECUTE IMMEDIATE 'DROP SEQUENCE '||i.object_name;
    END IF;
  END LOOP;
END;
/
 
/* Create the NC_ERROR table. */
CREATE TABLE nc_error
( error_id            NUMBER         CONSTRAINT pk_nce   PRIMARY KEY
, object_name         VARCHAR2(30)   CONSTRAINT nn_nce_1 NOT NULL
, module_name         VARCHAR2(30)
, class_name          VARCHAR2(30)
, sqlerror_code       VARCHAR2(9)
, sqlerror_message    VARCHAR2(2000)
, user_error_message  VARCHAR2(2000)
, last_updated_by     NUMBER         CONSTRAINT nn_nce_2 NOT NULL
, last_update_date    DATE           CONSTRAINT nn_nce_3 NOT NULL
, created_by          NUMBER         CONSTRAINT nn_nce_4 NOT NULL
, creation_date       DATE           CONSTRAINT nn_nce_5 NOT NULL);
 
/* Create the NC_ERROR_S1 sequence. */
CREATE SEQUENCE nc_error_s1;
 
 
/* Conditionally drop the common lookup types, table and then objectWHERE. */
BEGIN
  FOR i IN (SELECT   object_name
            FROM     user_objects
            WHERE    object_name = 'RECORD_ERRORS') LOOP
    EXECUTE IMMEDIATE 'DROP PROCEDURE '||i.object_name;
  END LOOP;
END;
/
 
/* Create procedure to record reported errors. */
CREATE OR REPLACE PROCEDURE record_errors
( object_name           IN        VARCHAR2
, module_name           IN        VARCHAR2 := NULL
, class_name            IN        VARCHAR2 := NULL
, sqlerror_code         IN        VARCHAR2 := NULL
, sqlerror_message      IN        VARCHAR2 := NULL
, user_error_message    IN        VARCHAR2 := NULL ) IS
 
  /* Declare anchored record variable. */
  nc_error_record NC_ERROR%ROWTYPE;
 
  /* Set procedure to be autonomous. */
  PRAGMA AUTONOMOUS_TRANSACTION;
 
BEGIN 
  /* Substitute actual parameters for default values. */
  IF object_name IS NOT NULL THEN
    nc_error_record.object_name := object_name;
  END IF;
  IF module_name IS NOT NULL THEN
    nc_error_record.module_name := module_name;
  END IF;
  IF sqlerror_code IS NOT NULL THEN
    nc_error_record.sqlerror_code := sqlerror_code;
  END IF;
  IF sqlerror_message IS NOT NULL THEN
    nc_error_record.sqlerror_message := sqlerror_message;
  END IF;
  IF user_error_message IS NOT NULL THEN
    nc_error_record.user_error_message := user_error_message;
  END IF;
 
  dbms_output.put_line('Inside ['||object_name||'].');
 
  /* Insert non-critical error record. */
  INSERT INTO nc_error
  VALUES
  ( nc_error_s1.NEXTVAL
  , nc_error_record.object_name
  , nc_error_record.module_name
  , nc_error_record.class_name
  , nc_error_record.sqlerror_code
  , nc_error_record.sqlerror_message
  , nc_error_record.user_error_message
  , 2
  , SYSDATE
  , 2
  , SYSDATE);
 
  /* Write to logging table. */
  COMMIT;
 
EXCEPTION
  WHEN OTHERS THEN
    RETURN;
END;
/
 
/* Anonymous program. */
BEGIN
  /* Test record_errors procedure. */
  record_errors( object_name => 'Test Object'
               , module_name => 'Test Module'
               , class_name => 'Test Class'
               , sqlerror_code => 'ORA-00001'
               , sqlerror_message => 'ORA-00001: User Error');
END;
/
 
/* Query test results. */
SELECT ne.object_name
,      ne.module_name
,      ne.sqlerror_code
FROM   nc_error ne;
 
/* Conditionally drop the insert_item procedure. */
BEGIN
  FOR i IN (SELECT   object_name
            ,        object_type
            FROM     user_objects
            WHERE    REGEXP_LIKE(object_name,'^insert_item.*$','i')
            ORDER BY 2 DESC) LOOP
      EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name;
  END LOOP;
END;
/
 
/* Create draft insert_item procedure. */
CREATE PROCEDURE insert_item
( pv_item_barcode        VARCHAR2
, pv_item_type           VARCHAR2
, pv_item_title          VARCHAR2
, pv_item_subtitle       VARCHAR2 := NULL
, pv_item_rating         VARCHAR2
, pv_item_rating_agency  VARCHAR2
, pv_item_release_date   DATE ) IS
 
  /* Declare local variables. */
  lv_item_type  NUMBER;
  lv_rating_id  NUMBER;
  lv_user_id    NUMBER := 1;
  lv_date       DATE := TRUNC(SYSDATE);
  lv_control    BOOLEAN := FALSE;
 
  /* Declare error handling variables. */
  lv_local_object  VARCHAR2(30) := 'PROCEDURE';
  lv_local_module  VARCHAR2(30) := 'INSERT_ITEM';
 
  /* Declare conversion cursor. */
  CURSOR item_type_cur
  ( cv_item_type  VARCHAR2 ) IS
    SELECT common_lookup_id
    FROM   common_lookup
    WHERE  common_lookup_table = 'ITEM'
    AND    common_lookup_column = 'ITEM_TYPE'
    AND    common_lookup_type = cv_item_type;
 
  /* Declare conversion cursor. */
  CURSOR rating_cur 
  ( cv_rating         VARCHAR2
  , cv_rating_agency  VARCHAR2 ) IS
    SELECT rating_agency_id
    FROM   rating_agency
    WHERE  rating = cv_rating
    AND    rating_agency = cv_rating_agency;
 
  /*
     Enforce logic validation that the rating, rating agency and 
     media type match. This is a user-configuration area and they
     may need to add validation code for new materials here.
  */
  CURSOR match_media_to_rating 
  ( cv_item_type  NUMBER
  , cv_rating_id  NUMBER ) IS
    SELECT  NULL
    FROM    common_lookup cl CROSS JOIN rating_agency ra
    WHERE   common_lookup_id = cv_item_type
    AND    (common_lookup_type IN ('BLU-RAY','DVD','HD','SD')
    AND     rating_agency_id = cv_rating_id
    AND     rating IN ('G','PG','PG-13','R')
    AND     rating_agency = 'MPAA')
    OR     (common_lookup_type IN ('GAMECUBE','PLAYSTATION','XBOX')
    AND     rating_agency_id = cv_rating_id
    AND     rating IN ('C','E','E10+','T')
    AND     rating_agency = 'ESRB');
 
  /* Declare an exception. */
  e  EXCEPTION;
  PRAGMA EXCEPTION_INIT(e,-20001);
 
  /* Designate as an autonomous program. */
  PRAGMA AUTONOMOUS_TRANSACTION;
 
BEGIN
  /* Get the foreign key of an item type. */
  FOR i IN item_type_cur(pv_item_type) LOOP
    lv_item_type := i.common_lookup_id;
  END LOOP;
 
  /* Get the foreign key of a rating. */
  FOR i IN rating_cur(pv_item_rating, pv_item_rating_agency) LOOP
    lv_rating_id := i.rating_agency_id;
  END LOOP;
 
  /* Only insert when the two foreign key values are set matches. */
  FOR i IN match_media_to_rating(lv_item_type, lv_rating_id) LOOP
 
    INSERT
    INTO   item
    ( item_id
    , item_barcode 
    , item_type
    , item_title
    , item_subtitle
    , item_desc
    , item_release_date
    , rating_agency_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date )
    VALUES
    ( item_s1.NEXTVAL
    , pv_item_barcode
    , lv_item_type
    , pv_item_title
    , pv_item_subtitle
    , EMPTY_CLOB()
    , pv_item_release_date
    , lv_rating_id
    , lv_user_id
    , lv_date
    , lv_user_id
    , lv_date );
 
    /* Set control to true. */
    lv_control := TRUE;
 
    /* Commmit the record. */
    COMMIT;
 
  END LOOP;
 
  /* Raise an exception when required. */
  IF NOT lv_control THEN
    RAISE e;
  END IF; 
 
EXCEPTION
  WHEN OTHERS THEN
    record_errors( object_name => lv_local_object
                 , module_name => lv_local_module
                 , sqlerror_code => 'ORA'||SQLCODE
                 , sqlerror_message => SQLERRM
                 , user_error_message => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
    RAISE;
END;
/
 
/* Enable serveroutput. */
SET SERVEROUTPUT ON SIZE UNLIMITED
 
/* Call the insert_item procedure. */
BEGIN
  insert_item( pv_item_barcode => 'B01IOHVPA8'
             , pv_item_type => 'DVD'
             , pv_item_title => 'Jason Bourne'
             , pv_item_rating => 'PG-13'
             , pv_item_rating_agency => 'MPAA'
             , pv_item_release_date => '06-DEC-2016');
END;
/
 
/* Query result from the insert_item procedure. */
COL item_barcode FORMAT A10 HEADING "Item|Barcode"
COL item_title   FORMAT A30 HEADING "Item Title"
COL release_date FORMAT A12 HEADING "Item|Release|Date"
SELECT i.item_barcode
,      i.item_title
,      i.item_release_date AS release_date
FROM   item i
WHERE  i.item_title = 'Jason Bourne';
 
 
/* Conditionally drop the common lookup types, table and then objectWHERE. */
BEGIN
  FOR i IN (SELECT   type_name
            FROM     user_types
            WHERE    type_name IN ('ITEM_OBJ','ITEM_TAB')
            ORDER BY 1 DESC) LOOP
    EXECUTE IMMEDIATE 'DROP TYPE '||i.type_name;
  END LOOP;
END;
/
 
/* Create an item object type. */
CREATE OR REPLACE
  TYPE item_obj IS OBJECT
  ( item_barcode        VARCHAR2(20)
  , item_type           VARCHAR2(7)
  , item_title          VARCHAR2(60)
  , item_subtitle       VARCHAR2(60)
  , item_rating         VARCHAR2(8)
  , item_rating_agency  VARCHAR2(4)
  , item_release_date   DATE );
/
 
CREATE OR REPLACE
  TYPE item_tab IS TABLE OF item_obj;
/
 
/* Conditionally drop the common lookup types, table and then objectWHERE. */
BEGIN
  FOR i IN (SELECT   object_name
            FROM     user_objects
            WHERE    object_name = 'INSERT_ITEMS') LOOP
    EXECUTE IMMEDIATE 'DROP PROCEDURE '||i.object_name;
  END LOOP;
END;
/
 
/* Create draft insert_items procedure. */
CREATE PROCEDURE insert_items
( pv_items  ITEM_TAB ) IS

/* Declare error handling variables. */
  lv_local_object  VARCHAR2(30) := 'PROCEDURE';
  lv_local_module  VARCHAR2(30) := 'INSERT_ITEMS';


 
BEGIN
  /* Read the list of items and call the insert_item procedure. */
  FOR i IN 1..pv_items.COUNT LOOP
    insert_item( pv_item_barcode => pv_items(i).item_barcode
               , pv_item_type => pv_items(i).item_type
               , pv_item_title => pv_items(i).item_title
               , pv_item_subtitle => pv_items(i).item_subtitle
               , pv_item_rating => pv_items(i).item_rating
               , pv_item_rating_agency => pv_items(i).item_rating_agency
               , pv_item_release_date => pv_items(i).item_release_date );
  END LOOP;


 
EXCEPTION
  WHEN OTHERS THEN
    record_errors( object_name => lv_local_object
                 , module_name => lv_local_module
                 , sqlerror_code => 'ORA'||SQLCODE
                 , sqlerror_message => SQLERRM
                 , user_error_message => DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
    RAISE;
END;
/
 
 
/* Create draft insert_item procedure. */
DECLARE
  /* Create a collection. */
  lv_items  ITEM_TAB :=
    item_tab(
        item_obj( item_barcode => 'B002ZHKZCO'
                , item_type => 'BLU-RAY'
                , item_title => 'The Bourne Identity'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '19-JAN-2010')
      , item_obj( item_barcode => 'B0068FZ18C'
                , item_type => 'BLU-RAY'
                , item_title => 'The Bourne Supremacy'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '10-JAN-2012')
      , item_obj( item_barcode => 'B00AIZK85E'
                , item_type => 'BLU-RAY'
                , item_title => 'The Bourne Ultimatum'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '11-DEC-2012')
      , item_obj( item_barcode => 'B01AT251XY'
                , item_type => 'BLU-RAY'
                , item_title => 'The Bourne Legacy'
                , item_subtitle => NULL
                , item_rating => 'PG-13'
                , item_rating_agency => 'MPAA'
                , item_release_date => '05-APR-2016'));
BEGIN
  /* Call a element processing procedure. */
  insert_items(lv_items);
END;
/ 
 
/* Query result from the insert_item procedure. */
COL item_barcode FORMAT A10 HEADING "Item|Barcode"
COL item_title   FORMAT A30 HEADING "Item Title"
COL release_date FORMAT A12 HEADING "Item|Release|Date"
SELECT   i.item_barcode
,        i.item_title
,        i.item_release_date AS release_date
FROM     item i
WHERE    REGEXP_LIKE(i.item_title,'^.*bourne.*$','i')
ORDER BY i.item_release_date;