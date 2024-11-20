-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(26);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    CREATE TABLE dbms_output_test (buff TEXT, status INTEGER);

    -- DBMS_OUTPUT.DISABLE [0]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES (NULL::text, 1)$$,
        'Test dbms_output.disable'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.PUT_LINE [1]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
        orafce	VARCHAR(20) := 'orafce';
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.PUT_LINE (orafce);
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.PUT ('ABC');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.PUT_LINE ('');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE'::text, 0),
            ('orafce'::text, 0),
            ('ABC'::text, 0),
            (''::text, 0)
        $$,
        'Test dbms_output.put_line'
    );
    TRUNCATE TABLE dbms_output_test;
 
    -- DBMS_OUTPUT.PUT_LINE [2]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE (
            E'ORA\n'
             'F\n'
             'CE'
        );
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            (E'ORA\nF\nCE'::text, 0)
        $$,
        'Test dbms_output.put_line with multi-line text'
    );
    TRUNCATE TABLE dbms_output_test;
 
    -- DBMS_OUTPUT.PUT [1]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT ('ORA');
        PERFORM DBMS_OUTPUT.PUT ('F');
        PERFORM DBMS_OUTPUT.PUT ('CE');
        PERFORM DBMS_OUTPUT.PUT_LINE ('');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.PUT ('ABC');
        PERFORM DBMS_OUTPUT.PUT_LINE ('');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
    END;
    $$;
   
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE'::text, 0),
            ('ABC'::text, 0)
        $$,
        'Test dbms_output.put'
    );
    TRUNCATE TABLE dbms_output_test;
 
    -- DBMS_OUTPUT.PUT [2]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT (
            E'ORA\n'
             'F\n'
             'CE'
        );
        PERFORM DBMS_OUTPUT.PUT_LINE ('');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
    END;
    $$;
    
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            (E'ORA\nF\nCE'::text, 0)
        $$,
        'Test dbms_output.put with multi-line text'
    );
    TRUNCATE TABLE dbms_output_test;
    
    -- DBMS_OUTPUT.GET_LINE [1]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
    END;
    $$;
    
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 0),
            ('ORAFCE TEST 2'::text, 0)
        $$,
        'Test dbms_output.get_line'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINE [2]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 3');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 0),
            ('ORAFCE TEST 3'::text, 0),
            (NULL::text, 1)
        $$,
        'Test dbms_output.get_line mixed with multiple put_lines'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINE [3]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.PUT ('ORA');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 0),
            ('ORA'::text, 0),
            (NULL::text, 1)
        $$,
        'Test dbms_output.get_line mixed with put_line and put'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINE [4]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.NEW_LINE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 0),
            (''::text, 0),
            (NULL::text, 1)
        $$,
        'Test dbms_output.get_line mixed with put_line and new_line'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINE [5]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE (
            E'ORAFCE\n'
             'TEST\n'
             '1'
        );
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            (E'ORAFCE\nTEST\n1'::text, 0),
            ('ORAFCE TEST 2'::text, 0)
        $$,
        'Test dbms_output.get_line mixed with multi-line text'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINES [1]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        buff1	TEXT;
        buff2	TEXT;
        buff3	TEXT;
        stts	INTEGER := 10;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 3');
        SELECT INTO buff1,buff2,buff3,stts lines[1],lines[2],lines[3],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff1, stts);
        INSERT INTO dbms_output_test VALUES (buff2, stts);
        INSERT INTO dbms_output_test VALUES (buff3, stts);
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 3),
            ('ORAFCE TEST 2'::text, 3),
            ('ORAFCE TEST 3'::text, 3),
            (NULL::text, 0)
        $$,
        'Test dbms_output.get_lines'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINES [2]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        buff1	TEXT;
        buff2	TEXT;
        stts	INTEGER := 2;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 3');
        SELECT INTO buff1,buff2,stts lines[1],lines[2],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff1, stts);
        INSERT INTO dbms_output_test VALUES (buff2, stts);
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 2),
            ('ORAFCE TEST 2'::text, 2),
            ('ORAFCE TEST 3'::text, 1)
        $$,
        'Test dbms_output.get_lines with lower numlines'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINES [3]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER := 1;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 3');
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 1),
            ('ORAFCE TEST 3'::text, 1),
            (NULL::text, 0)
        $$,
        'Test dbms_output.get_lines mixed with multiple put_lines'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINES [4]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER := 1;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.PUT ('ORA');
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 1),
            ('ORA'::text, 1),
            (NULL::text, 0)
        $$,
        'Test dbms_output.get_lines mixed with put_line and put'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINES [5]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER := 1;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.NEW_LINE();
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORAFCE TEST 1'::text, 1),
            (''::text, 1),
            (NULL::text, 0)
        $$,
        'Test dbms_output.get_lines mixed with put_line and new_line'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.GET_LINES [6]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER := 1;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE (
            E'ORA\n'
             'F\n'
             'CE'
        );
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            (E'ORA\nF\nCE'::text, 1)
        $$,
        'Test dbms_output.get_lines with multi-line text'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.NEW_LINE [1]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff1	TEXT;
        buff2	TEXT;
        stts	INTEGER := 10;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.PUT ('ORA');
        PERFORM DBMS_OUTPUT.NEW_LINE();
        PERFORM DBMS_OUTPUT.PUT ('FCE');
        PERFORM DBMS_OUTPUT.NEW_LINE();
        SELECT INTO buff1,buff2,stts lines[1],lines[2],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff1, stts);
        INSERT INTO dbms_output_test VALUES (buff2, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('ORA'::text, 2),
            ('FCE'::text, 2)
        $$,
        'Test dbms_output.new_line'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.NEW_LINE [2]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff1	TEXT;
        stts	INTEGER := 10;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.ENABLE(2000);
        FOR j IN 1..1999 LOOP
            PERFORM DBMS_OUTPUT.PUT ('A');
        END LOOP;
        PERFORM DBMS_OUTPUT.NEW_LINE();
        SELECT INTO buff1,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff1, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            ('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'::text, 1)
        $$,
        'Test dbms_output.new_line with long text'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.DISABLE [1]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 2');
        PERFORM DBMS_OUTPUT.ENABLE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 3');
        PERFORM DBMS_OUTPUT.DISABLE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.PUT ('ORAFCE TEST 4');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.NEW_LINE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT ('ORAFCE TEST 5');
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.NEW_LINE();
        PERFORM DBMS_OUTPUT.ENABLE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;

    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            (NULL::text, 1),
            (NULL::text, 1),
            (NULL::text, 1),
            (''::text, 0),
            (NULL::text, 1)
        $$,
        'Test dbms_output.disable timing'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.DISABLE [2]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER := 10;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES 
            (NULL::text, 0)
        $$,
        'Test dbms_output.disable with getlines'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.ENABLE [1]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.PUT ('ORAFCE TEST 2');
        PERFORM DBMS_OUTPUT.NEW_LINE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.ENABLE();
    END;

    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES
            ('ORAFCE TEST 1'::text, 0),
            ('ORAFCE TEST 2'::text, 0)
        $$,
        'Test dbms_output.enable'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.ENABLE [2]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
        num		INTEGER := 2000;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.ENABLE(2000);
        PERFORM DBMS_OUTPUT.PUT ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.NEW_LINE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES
            ('ORAFCE TEST 1'::text, 0)
        $$,
        'Test dbms_output.enable with large buffer size'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.ENABLE [3]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER := 10;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        SELECT INTO buff,stts lines[1],numlines FROM DBMS_OUTPUT.GET_LINES(stts);
        INSERT INTO dbms_output_test VALUES (buff, stts);
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES
            ('ORAFCE TEST 1'::text, 1)
        $$,
        'Test dbms_output.enable with get_lines'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.ENABLE [4]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER := 10;
    BEGIN
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        FOR j IN 1..2000 LOOP
            PERFORM DBMS_OUTPUT.PUT ('A');
        END LOOP;
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);

        PERFORM DBMS_OUTPUT.NEW_LINE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES
            ('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'::text, 0)
        $$,
        'Test dbms_output.enable with large text'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.ENABLE [5]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE(NULL);
        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES
            ('ORAFCE TEST 1'::text, 0)
        $$,
        'Test dbms_output.enable with NULL value for buffer_size'
    );
    TRUNCATE TABLE dbms_output_test;

    -- DBMS_OUTPUT.ENABLE [6]
    CREATE OR REPLACE FUNCTION dbms_output_test()
    RETURNS VOID
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        buff	TEXT;
        stts	INTEGER;
    BEGIN
        PERFORM DBMS_OUTPUT.SERVEROUTPUT ('f');
        PERFORM DBMS_OUTPUT.ENABLE();

        PERFORM DBMS_OUTPUT.PUT_LINE ('ORAFCE TEST 1');
        PERFORM DBMS_OUTPUT.ENABLE();
        SELECT INTO buff,stts line,status FROM DBMS_OUTPUT.GET_LINE();
        INSERT INTO dbms_output_test VALUES (buff, stts);
        PERFORM DBMS_OUTPUT.DISABLE();
        PERFORM DBMS_OUTPUT.ENABLE();
    END;
    $$;
    SELECT dbms_output_test();
    SELECT results_eq(
        $$SELECT * FROM dbms_output_test;$$,
        $$VALUES
            ('ORAFCE TEST 1'::text, 0)
        $$,
        'Test dbms_output.enable with being called twice'
    );
    TRUNCATE TABLE dbms_output_test;

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;