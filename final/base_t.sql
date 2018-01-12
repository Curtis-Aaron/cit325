/*
   Name:   base_t.sql
   Author: Calvin Milliron
   Date:   05-DEC-2017
*/
DROP TABLE tolkien;
DROP TYPE teleri_t;
DROP TYPE sindar_t;
DROP TYPE silvan_t;
DROP TYPE noldor_t;
DROP TYPE elf_t;
DROP TYPE orc_t;
DROP TYPE man_t;
DROP TYPE maia_t;
DROP TYPE hobbit_t;
DROP TYPE goblin_t;
DROP TYPE dwarf_t;
DROP TYPE base_t;

CREATE OR REPLACE
  TYPE base_t IS OBJECT
  ( oid    NUMBER
  , oname  VARCHAR2(30)
  , CONSTRUCTOR FUNCTION base_t
    ( oid    NUMBER
    , oname  VARCHAR2 DEFAULT 'BASE_T' ) RETURN SELF AS RESULT
  , MEMBER FUNCTION get_oname RETURN VARCHAR2
  , MEMBER PROCEDURE set_oname (oname VARCHAR2)
  , MEMBER FUNCTION get_name RETURN VARCHAR2
  , MEMBER FUNCTION to_string RETURN VARCHAR2 )
  INSTANTIABLE NOT FINAL;
/

CREATE OR REPLACE
  TYPE BODY base_t IS
  /* Implement a default constructor. */
  CONSTRUCTOR FUNCTION base_t
    ( oid        NUMBER
    , oname      VARCHAR2 DEFAULT 'BASE_T' ) RETURN SELF AS RESULT IS
  BEGIN
    self.oid := oid;
    self.oname := oname;
    RETURN;
  END base_t;
 
  /* Implement a get_oname function. */
  MEMBER FUNCTION get_oname
  RETURN VARCHAR2 IS
  BEGIN
    RETURN self.oname;
  END get_oname;
 
  /* Implement a set_oname procedure. */
  MEMBER PROCEDURE set_oname (oname VARCHAR2) IS
  BEGIN
    self.oname := oname;
  END set_oname;
 
  /* Implement a get_name function. */
  MEMBER FUNCTION get_name
  RETURN VARCHAR2 IS
  BEGIN
    RETURN NULL;
  END get_name;

  /* Implement a to_string function. */
  MEMBER FUNCTION to_string
  RETURN VARCHAR2 IS
  BEGIN
    RETURN '['||self.oid||']';
  END to_string;
END;
/

QUIT;