/*
   Name:   apply_plsql_lab12.sql
   Author: Calvin Milliron
   Date:   30-NOV-2017
*/

-- Open your log file and make sure the extension is ".log".
SPOOL apply_plsql_lab12.log

DROP FUNCTION item_list;
DROP TYPE item_tab;
DROP TYPE item_obj;

/* Create item object */
CREATE OR REPLACE
  TYPE item_obj IS OBJECT
  ( title        VARCHAR2(60)
  , subtitle     VARCHAR2(60)
  , rating       VARCHAR2(8)
  , release_date DATE);
/

/* Verify Create item object */
desc item_obj

/* Create table of item objects */
CREATE OR REPLACE
  TYPE item_tab IS TABLE of item_obj;
/

/* Verify Create table of item objects */
desc item_tab

/* Create item_list function */
CREATE OR REPLACE
  FUNCTION item_list
  ( pv_start_date DATE
  , pv_end_date   DATE DEFAULT (TRUNC(SYSDATE) + 1) ) RETURN item_tab IS
 
    /* Declare a record type. */
    TYPE item_rec IS RECORD
    ( title        VARCHAR2(60)
    , subtitle     VARCHAR2(60)
    , rating       VARCHAR2(8)
    , release_date DATE);
 
    /* Declare reference cursor for an NDS cursor. */
    item_cur   SYS_REFCURSOR;
 
    /* Declare a customer row for output from an NDS cursor. */
    item_row   ITEM_REC;
    item_set   ITEM_TAB := item_tab();
 
    /* Declare dynamic statement. */
    stmt  VARCHAR2(2000);
  BEGIN
    /* Create a dynamic statement. */
    stmt := 'SELECT item_title AS title, item_subtitle AS subtitle, item_rating AS rating, item_release_date AS release_date '
         || 'FROM   item '
         || 'WHERE  item_rating_agency = ''MPAA'''
         || 'AND  item_release_date > :start_date AND item_release_date < :end_date';
 
    /* Open and read dynamic cursor. */
    OPEN item_cur FOR stmt USING pv_start_date, pv_end_date;
    LOOP
      /* Fetch the cursror into a item row. */
      FETCH item_cur INTO item_row;
      EXIT WHEN item_cur%NOTFOUND;
 
      /* Extend space and assign a value collection. */      
      item_set.EXTEND;
      item_set(item_set.COUNT) :=
        item_obj( title  => item_row.title
                , subtitle => item_row.subtitle
                , rating   => item_row.rating
                , release_date => item_row.release_date );
    END LOOP;
 
    /* Return item set. */
    RETURN item_set;
  END item_list;
/

/* Verify Create item_list function */
desc item_list

/* Test Create item_list function */
SET PAGESIZE 9999
COL title   FORMAT A60
COL rating  FORMAT A6
SELECT   il.title
,        il.rating
FROM     TABLE(item_list('01-JAN-2000')) il
ORDER BY 1, 2;

-- Close your log file.
SPOOL OFF