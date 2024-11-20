-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(4);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    /*
    * Test for dbms_utility.format_call_stack(char mode). 
    * Mode is hex. 
    * The callstack returned is passed to regex_replace function.
    * Regex_replace replaces the function oid from the stack with zero.
    * This is done to avoid random results due to different oids generated.
    * Also the line number and () of the function is removed since it is different
    * across different pg version.
    */
    CREATE OR REPLACE FUNCTION check_hex_call_stack()
    RETURNS text
    LANGUAGE plpgsql
    AS 
    $$
    DECLARE
        stack text;
    BEGIN
        select * INTO stack from dbms_utility.format_call_stack('o');
        select * INTO stack from regexp_replace(stack,'[ 0-9a-fA-F]{4}[0-9a-fA-F]{4}','       0','g');
        select * INTO stack from regexp_replace(stack,'[45()]','','g');
        return stack;
    END;
    $$;

    SELECT is(
        check_hex_call_stack(),
        E'----- PL/pgSQL Call Stack -----\n'
         '  object     line  object\n'
         '  handle   number  name\n'
         '       0           function anonymous object\n'
         '       0          function check_hex_call_stack',
        'Test dbms_utility.format_call_stack with o'
    );
    
    /*
    * Test for dbms_utility.format_call_stack(char mode). 
    * Mode is integer.
    */
    CREATE OR REPLACE FUNCTION check_int_call_stack()
    RETURNS text
    LANGUAGE plpgsql
    AS 
    $$
    DECLARE
        stack text;
    BEGIN
        select * INTO stack from dbms_utility.format_call_stack('p');
        select * INTO stack from regexp_replace(stack,'[ 0-9]{3}[0-9]{5}','       0','g');
        select * INTO stack from regexp_replace(stack,'[45()]','','g');
        return stack;
    END;
    $$;

    SELECT is(
        check_int_call_stack(),
        E'       0           function anonymous object\n'
         '       0          function check_int_call_stack',
        'Test dbms_utility.format_call_stack with p'
    );
    
    /*
    * Test for dbms_utility.format_call_stack(char mode). 
    * Mode is integer with unpadded output.
    */
    CREATE OR REPLACE FUNCTION check_int_unpadded_call_stack()
    RETURNS text
    LANGUAGE plpgsql
    AS 
    $$
    DECLARE
        stack text;
    BEGIN
        select * INTO stack from dbms_utility.format_call_stack('s');
        select * INTO stack from regexp_replace(stack,'[0-9]{5,}','0','g');
        select * INTO stack from regexp_replace(stack,'[45()]','','g');
        return stack;
    END;
    $$;

    SELECT is(
        check_int_unpadded_call_stack(),
        E'0,,anonymous object\n'
         '0,,check_int_unpadded_call_stack',
        'Test dbms_utility.format_call_stack with s'
    );

    /*
    * Test for dbms_utility.get_time(), the result is rounded
    * to have constant result in the regression test.
    */
    CREATE OR REPLACE FUNCTION check_get_time()
    RETURNS numeric
    LANGUAGE plpgsql
    AS 
    $$
    DECLARE
        start_time integer;
        end_time integer;
    BEGIN
        start_time := DBMS_UTILITY.GET_TIME();
        PERFORM pg_sleep(1);
        end_time := DBMS_UTILITY.GET_TIME();
        return trunc((end_time - start_time)::numeric/100);
    END
    $$;
    
    SELECT is(
        check_get_time(),
        1::numeric,
        'Test dbms_utility.get_time'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;