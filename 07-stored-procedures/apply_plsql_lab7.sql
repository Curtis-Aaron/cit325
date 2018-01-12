/*
   Name:   apply_plsql_lab7.sql
   Author: Calvin Milliron
   Date:   28-OCT-2017
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
SPOOL apply_plsql_lab7.log

-- ------------------------------------------------------------------
-- Step 0
-- ------------------------------------------------------------------
/* Show all 4 DBAs if they have the same name*/
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name = 'DBA';

/* Change all 4 DBAs back to DBA if they are different*/
UPDATE system_user
SET    system_user_name = 'DBA'
WHERE  system_user_name LIKE 'DBA%';

/* Change DBAs to DBA1-4 to be different*/
DECLARE
  /* Create a local counter variable. */
  lv_counter  NUMBER := 2;
 
  /* Create a collection of two-character strings. */
  TYPE numbers IS TABLE OF NUMBER;
 
  /* Create a variable of the roman_numbers collection. */
  lv_numbers  NUMBERS := numbers(1,2,3,4);
 
BEGIN
  /* Update the system_user names to make them unique. */
  FOR i IN 1..lv_numbers.COUNT LOOP
    /* Update the system_user table. */
    UPDATE system_user
    SET    system_user_name = system_user_name || ' ' || lv_numbers(i)
    WHERE  system_user_id = lv_counter;
 
    /* Increment the counter. */
    lv_counter := lv_counter + 1;
  END LOOP;
END;
/

/* Show new different DBAs */
SELECT system_user_id
,      system_user_name
FROM   system_user
WHERE  system_user_name LIKE 'DBA%';

/* Drop existing objects */
BEGIN
  FOR i IN (SELECT uo.object_type
            ,      uo.object_name
            FROM   user_objects uo
            WHERE  uo.object_name = 'INSERT_CONTACT') LOOP
    EXECUTE IMMEDIATE 'DROP ' || i.object_type || ' ' || i.object_name;
  END LOOP;
END;
/

-- ------------------------------------------------------------------
-- Step 1
-- ------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE insert_contact

( pv_first_name          VARCHAR2
, pv_middle_name         VARCHAR2 := ''
, pv_last_name           VARCHAR2
, pv_contact_type        VARCHAR2
, pv_account_number      VARCHAR2
, pv_member_type         VARCHAR2

, pv_credit_card_number  VARCHAR2

, pv_credit_card_type    VARCHAR2

, pv_city                VARCHAR2

, pv_state_province      VARCHAR2

, pv_postal_code         VARCHAR2

, pv_address_type        VARCHAR2

, pv_country_code        VARCHAR2

, pv_area_code           VARCHAR2
, pv_telephone_number    VARCHAR2
, pv_telephone_type      VARCHAR2

, pv_user_name           VARCHAR2) IS



  -- Local variables, to leverage subquery assignments in INSERT statements.

  lv_address_type        VARCHAR2(30);

  lv_contact_type        VARCHAR2(30);

  lv_credit_card_type    VARCHAR2(30);

  lv_member_type         VARCHAR2(30);

  lv_telephone_type      VARCHAR2(30);
  lv_member_id NUMBER;
  lv_system_user_id NUMBER;



  CURSOR c_member IS 
  SELECT member_id FROM member
  WHERE account_number = pv_account_number;

  CURSOR c_user IS
  SELECT system_user_id FROM system_user
  WHERE system_user_name = pv_user_name;


  

BEGIN

  -- Assign parameter values to local variables for nested assignments to DML subqueries.

  lv_address_type := pv_address_type;

  lv_contact_type := pv_contact_type;

  lv_credit_card_type := pv_credit_card_type;

  lv_member_type := pv_member_type;

  lv_telephone_type := pv_telephone_type;
  lv_system_user_id := 0;
  lv_member_id := 0;



 

  -- Create a SAVEPOINT as a starting point.

  SAVEPOINT starting_point;



  -- Find User
  FOR i IN c_user LOOP
      lv_system_user_id := i.system_user_id;
  END LOOP;

  -- Quit if no user found
  IF lv_system_user_id = 0 THEN
    dbms_output.put_line('No User Found');
    RETURN;
  END IF;

  -- Find member
  FOR i IN c_member LOOP
      lv_member_id := i.member_id;
  END LOOP;

  -- Add new member if no member found
  IF lv_member_id = 0 THEN

    INSERT INTO member

    ( member_id

    , member_type

    , account_number

    , credit_card_number

    , credit_card_type

    , created_by

    , creation_date

    , last_updated_by

    , last_update_date )

    VALUES

    ( member_s1.NEXTVAL

    ,( SELECT   common_lookup_id

       FROM     common_lookup

       WHERE    common_lookup_table = 'MEMBER'

       AND      common_lookup_column = 'MEMBER_TYPE'

       AND      common_lookup_type = lv_member_type)

    , pv_account_number

    , pv_credit_card_number

    ,( SELECT   common_lookup_id

       FROM     common_lookup

       WHERE    common_lookup_table = 'MEMBER'

       AND      common_lookup_column = 'CREDIT_CARD_TYPE'

       AND      common_lookup_type = lv_credit_card_type)

    , lv_system_user_id

    , SYSDATE

    , lv_system_user_id

    , SYSDATE );

    lv_member_id := member_s1.CURRVAL;
  END IF;



  INSERT INTO contact

  ( contact_id

  , member_id

  , contact_type

  , last_name

  , first_name

  , middle_name

  , created_by

  , creation_date

  , last_updated_by

  , last_update_date)

  VALUES

  ( contact_s1.NEXTVAL

  , lv_member_id

  ,(SELECT   common_lookup_id

    FROM     common_lookup

    WHERE    common_lookup_table = 'CONTACT'

    AND      common_lookup_column = 'CONTACT_TYPE'

    AND      common_lookup_type = lv_contact_type)

  , pv_last_name

  , pv_first_name

  , pv_middle_name

  , lv_system_user_id

  , SYSDATE

  , lv_system_user_id

  , SYSDATE );  



  INSERT INTO address

  VALUES

  ( address_s1.NEXTVAL

  , contact_s1.CURRVAL

  ,(SELECT   common_lookup_id

    FROM     common_lookup

    WHERE    common_lookup_table = 'ADDRESS'

    AND      common_lookup_column = 'ADDRESS_TYPE'

    AND      common_lookup_type = lv_address_type)

  , pv_city

  , pv_state_province

  , pv_postal_code

  , lv_system_user_id

  , SYSDATE

  , lv_system_user_id

  , SYSDATE );  


/* There is no parameter for street_address in insert_contact()

  INSERT INTO street_address

  VALUES

  ( street_address_s1.NEXTVAL

  , address_s1.CURRVAL

  , 1

  , pv_street_address

  , lv_system_user_id

  , SYSDATE

  , lv_system_user_id

  , SYSDATE );  

*/


  INSERT INTO telephone

  VALUES

  ( telephone_s1.NEXTVAL                              -- TELEPHONE_ID

  , contact_s1.CURRVAL                                -- CONTACT_ID

  , address_s1.CURRVAL                                -- ADDRESS_ID

  ,(SELECT   common_lookup_id

    FROM     common_lookup

    WHERE    common_lookup_table = 'TELEPHONE'

    AND      common_lookup_column = 'TELEPHONE_TYPE'

    AND      common_lookup_type = lv_telephone_type)

  , pv_country_code                                   -- COUNTRY_CODE

  , pv_area_code                                      -- AREA_CODE

  , pv_telephone_number                               -- TELEPHONE_NUMBER

  , lv_system_user_id                                     -- CREATED_BY

  , SYSDATE                                  -- CREATION_DATE

  , lv_system_user_id                                -- LAST_UPDATED_BY

  , SYSDATE);                             -- LAST_UPDATE_DATE



  COMMIT;

EXCEPTION 

  WHEN OTHERS THEN

    ROLLBACK TO starting_point;

    RETURN;

END insert_contact;

/


BEGIN
insert_contact

( 'Charles'
, 'Francis'
, 'Xavier'
, 'CUSTOMER'
, 'SLC-000008'
, 'INDIVIDUAL'
, '7777-6666-5555-4444'
, 'DISCOVER_CARD'
, 'Milbridge'
, 'Maine'
, '04658'
, 'HOME'
, '001'
, '207'
, '111-1234'
, 'HOME'
, 'DBA 2');
END;
/

-- ------------------------------------------------------------------
-- Verify Step 1
-- ------------------------------------------------------------------
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14
 
SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Xavier';

-- ------------------------------------------------------------------
-- Step 2
-- ------------------------------------------------------------------
BEGIN
insert_contact

( 'Maura'
, 'Jane'
, 'Haggerty'
, 'CUSTOMER'
, 'SLC-000009'
, 'INDIVIDUAL'
, '8888-7777-6666-5555'
, 'MASTER_CARD'
, 'Bangor'
, 'Maine'
, '04401'
, 'HOME'
, '001'
, '207'
, '111-1234'
, 'HOME'
, 'DBA 2');
END;
/

-- ------------------------------------------------------------------
-- Verify Step 2
-- ------------------------------------------------------------------
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14
 
SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'Haggerty';

-- ------------------------------------------------------------------
-- Step 3
-- ------------------------------------------------------------------
BEGIN
insert_contact

( 'Harriet'
, 'Mary'
, 'McDonnell'
, 'CUSTOMER'
, 'SLC-000010'
, 'INDIVIDUAL'
, '9999-8888-7777-6666'
, 'VISA_CARD'
, 'Orono'
, 'Maine'
, '04469'
, 'HOME'
, '001'
, '207'
, '111-1234'
, 'HOME'
, 'DBA 2');
END;
/

-- ------------------------------------------------------------------
-- Verify Step 3
-- ------------------------------------------------------------------
COL full_name      FORMAT A24
COL account_number FORMAT A10 HEADING "ACCOUNT|NUMBER"
COL address        FORMAT A22
COL telephone      FORMAT A14
 
SELECT c.first_name
||     CASE
         WHEN c.middle_name IS NOT NULL THEN ' '||c.middle_name||' ' ELSE ' '
       END
||     c.last_name AS full_name
,      m.account_number
,      a.city || ', ' || a.state_province AS address
,      '(' || t.area_code || ') ' || t.telephone_number AS telephone
FROM   member m INNER JOIN contact c
ON     m.member_id = c.member_id INNER JOIN address a
ON     c.contact_id = a.contact_id INNER JOIN telephone t
ON     c.contact_id = t.contact_id
AND    a.address_id = t.address_id
WHERE  c.last_name = 'McDonnell';

-- ------------------------------------------------------------------
-- Step 4
-- ------------------------------------------------------------------
CREATE OR REPLACE TYPE contact_obj IS OBJECT
  ( first_name   VARCHAR2(20)
  , middle_name  VARCHAR2(20)
  , last_name    VARCHAR2(20));
/

  CREATE OR REPLACE TYPE contact_tab IS TABLE OF contact_obj;
/

CREATE OR REPLACE FUNCTION get_contact RETURN CONTACT_TAB IS

  lv_contact_tab CONTACT_TAB := contact_tab();
  CURSOR contacts IS
    SELECT * FROM contact;

BEGIN

  FOR i IN contacts LOOP
      lv_contact_tab.EXTEND;
      lv_contact_tab(lv_contact_tab.LAST) := contact_obj(i.first_name, i.middle_name, i.last_name);
  END LOOP;

  RETURN lv_contact_tab;
END get_contact;
/

-- ------------------------------------------------------------------
-- Verify Step 4
-- ------------------------------------------------------------------
SET PAGESIZE 999
COL full_name FORMAT A24
SELECT first_name || CASE
                       WHEN middle_name IS NOT NULL
                       THEN ' ' || middle_name || ' '
                       ELSE ' '
                     END || last_name AS full_name
FROM   TABLE(get_contact);


-- Close your log file.
SPOOL OFF
QUIT;