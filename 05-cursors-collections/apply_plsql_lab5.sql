/*
   Name:   apply_plsql_lab5.sql
   Author: Calvin Milliron
   Date:   10-OCT-2017
*/

-- Open your log file and make sure the extension is ".log".
@/home/student/Data/cit325/oracle/lib/cleanup_oracle.sql
@/home/student/Data/cit325/oracle/lib/Oracle12cPLSQLCode/Introduction/create_video_store.sql

-- Open your log file and make sure the extension is ".log".
SPOOL apply_plsql_lab5.log

CREATE SEQUENCE rating_agency_s START WITH 1001;
CREATE TABLE rating_agency AS
  SELECT rating_agency_s.NEXTVAL AS rating_agency_id
  ,      il.item_rating AS rating
  ,      il.item_rating_agency AS rating_agency
  FROM  (SELECT DISTINCT
                i.item_rating
         ,      i.item_rating_agency
         FROM   item i) il;



ALTER TABLE item ADD rating_agency_id NUMBER;



SELECT * FROM rating_agency;

DROP TYPE agency;

DROP TYPE agencies;


CREATE OR REPLACE 
    TYPE agency IS OBJECT
  ( rating_agency_id   NUMBER
  , rating             VARCHAR2(8)
  , rating_agency      VARCHAR2(4));
/

  CREATE OR REPLACE TYPE agencies IS TABLE OF agency;
/


DECLARE
  CURSOR c IS SELECT * FROM rating_agency;


  lv_rating_agency AGENCIES := agencies();

BEGIN


  FOR i IN c LOOP
    lv_rating_agency.EXTEND;
    lv_rating_agency(lv_rating_agency.LAST) := agency(i.rating_agency_id, i.rating, i.rating_agency);
  END LOOP;

  FOR i IN 1..lv_rating_agency.LAST LOOP
    UPDATE item SET rating_agency_id = lv_rating_agency(i).rating_agency_id
    WHERE item_rating = lv_rating_agency(i).rating
    AND item_rating_agency = lv_rating_agency(i).rating_agency;
  END LOOP;

END;
/
  

SELECT   rating_agency_id
,        COUNT(*)
FROM     item
WHERE    rating_agency_id IS NOT NULL
GROUP BY rating_agency_id
ORDER BY 1;



-- Close your log file.
SPOOL OFF
QUIT;