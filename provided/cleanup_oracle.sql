BEGIN
  FOR i IN (SELECT    object_name
            ,         object_type
            ,         last_ddl_time
            FROM      user_objects
            WHERE     object_name NOT IN
                       ('APEX$_WS_WEBPG_SECTION_HISTORY','APEX$_WS_WEBPG_SECTIONS_T1'
                       ,'APEX$_WS_WEBPG_SECTIONS_PK','APEX$_WS_WEBPG_SECTIONS'
                       ,'APEX$_WS_WEBPG_SECHIST_IDX1','APEX$_WS_TAGS_T1'
                       ,'APEX$_WS_TAGS_PK','APEX$_WS_TAGS_IDX2','APEX$_WS_TAGS_IDX1'
                       ,'APEX$_WS_TAGS','APEX$_WS_ROWS_T1','APEX$_WS_ROWS_PK'
                       ,'APEX$_WS_ROWS_IDX','APEX$_WS_ROWS','APEX$_WS_NOTES_T1'
                       ,'APEX$_WS_NOTES_PK','APEX$_WS_NOTES_IDX2','APEX$_WS_NOTES_IDX1'
                       ,'APEX$_WS_NOTES','APEX$_WS_LINKS_T1','APEX$_WS_LINKS_PK'
                       ,'APEX$_WS_LINKS_IDX2','APEX$_WS_LINKS_IDX1','APEX$_WS_LINKS'
                       ,'APEX$_WS_HISTORY_IDX','APEX$_WS_HISTORY','APEX$_WS_FILES_T1'
                       ,'APEX$_WS_FILES_PK','APEX$_WS_FILES_IDX2','APEX$_WS_FILES_IDX1'
                       ,'APEX$_WS_FILES','APEX$_ACL_T1','APEX$_ACL_PK','APEX$_ACL_IDX1'
                       ,'APEX$_ACL','CUSTOM_AUTH','CUSTOM_HASH','DEPT','EMP'
                       ,'UPDATE_ORDER_TOTAL')
            AND NOT ((object_name LIKE 'DEMO%' OR
                      object_name LIKE 'INSERT_DEMO%' OR
                      object_name LIKE 'BI_DEMO%') AND
                      object_type IN ('TABLE','INDEX','SEQUENCE','TRIGGER'))
            AND NOT (object_name LIKE 'SYS_LOB%' AND object_type = 'LOB')
            AND NOT (object_name LIKE 'SYS_C%' AND object_type = 'INDEX')
            ORDER BY object_type DESC) LOOP
 
    /* Drop types in descending order. */
    IF i.object_type = 'TYPE' THEN
 
      /* Drop type and force operation because dependencies may exist. Oracle 12c
         also fails to remove object types with dependents in pluggable databases
         (at least in release 12.1). Type evolution works in container database
         schemas. */
      EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name||' FORCE';
 
    /* Drop table tables in descending order. */
    ELSIF i.object_type = 'TABLE' THEN
 
      /* Drop table with cascading constraints to ensure foreign key constraints
         don't prevent the action. */
      EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name||' CASCADE CONSTRAINTS PURGE';
 
      /* Oracle 12c ONLY: Purge the recyclebin to dispose of system-generated
         sequence values because dropping the table doesn't automatically 
         remove them from the active session.
         CRITICAL: Remark out the following when working in Oracle Database 11g. */
      EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';
 
    ELSIF i.object_type = 'LOB' OR i.object_type = 'INDEX' THEN

      /* A system generated LOB column or INDEX will cause a failure in a
         generic drop of a table because it is listed in the cursor but removed
         by the drop of its table. This NULL block ensures there is no attempt
         to drop an implicit LOB data type or index because the dropping the
         table takes care of it. */
      NULL;

    ELSE

      dbms_output.put_line('DROP '||i.object_type||' '||i.object_name||';');
      /* Drop any other objects, like sequences, functions, procedures, and packages. */
      EXECUTE IMMEDIATE 'DROP '||i.object_type||' '||i.object_name;
 
    END IF;
  END LOOP;
END;
/
