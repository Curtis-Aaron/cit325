/*
   Name:   apply_plsql_lab4.sql
   Author: Calvin Milliron
   Date:   5-OCT-2017
*/

-- Open your log file and make sure the extension is ".log".
SPOOL apply_plsql_lab4.log

DECLARE
  TYPE short IS TABLE OF VARCHAR2(8);
  TYPE long IS TABLE OF VARCHAR2(24);
  lv_order SHORT := SHORT('first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh', 'eighth', 'ninth', 'tenth', 'eleventh', 'twelfth');
  lv_gifts LONG := LONG('Partridge in a pear tree', 'Two Turtle doves', 'Three French hens', 'Four Calling birds', 'Five Golden rings', 'Six Geese a laying', 'Seven Swans a swimming', 'Eight Maids a milking', 'Nine Ladies dancing', 'Ten Lords a leaping', 'Eleven Pipers piping', 'Twelve Drummers drumming');
  pre VARCHAR2(8) := '';
BEGIN
  FOR i IN 1..lv_order.LAST LOOP
    dbms_output.put_line('On the '||lv_order(i)||' day of Christmas');
    dbms_output.put_line('my true love sent to me:');
    FOR j IN REVERSE 1..i LOOP
      IF j = 1 THEN
        IF i = 1 THEN
          pre := 'A ';
        ELSE
          pre := 'and a ';
        END IF;
      ELSE
        pre := '';
      END IF;
      dbms_output.put_line('-'||pre||lv_gifts(j));
    END LOOP;
    dbms_output.put_line(CHR(13));
  END LOOP;
END;
/

-- Close your log file.
SPOOL OFF
QUIT;