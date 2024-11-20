-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(12);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    CREATE OR REPLACE FUNCTION test_simple_query()
    RETURNS text
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
        strval varchar;
        intval int;
        stack text := '';
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'select ''ahoj'' || i, i from generate_series(1, 5) g(i)');
        CALL dbms_sql.define_column(c, 1, strval);
        CALL dbms_sql.define_column(c, 2, intval);
        PERFORM dbms_sql.execute(c);
        
        WHILE dbms_sql.fetch_rows(c) > 0
        LOOP
            CALL dbms_sql.column_value(c, 1, strval);
            CALL dbms_sql.column_value(c, 2, intval);
            stack := stack || strval || ',' || intval || E'\n';
        END LOOP;

        CALL dbms_sql.close_cursor(c);
        RETURN stack;
    END;
    $$;

    SELECT is(
        test_simple_query(),
        E'ahoj1,1\n'
         'ahoj2,2\n'
         'ahoj3,3\n'
         'ahoj4,4\n'
         'ahoj5,5\n',
        'Test simple query scenario'
    );

    CREATE OR REPLACE FUNCTION test_simple_query_f()
    RETURNS text
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
        strval varchar;
        intval int;
        stack text := '';
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'select ''ahoj'' || i, i from generate_series(1, 5) g(i)');
        CALL dbms_sql.define_column(c, 1, strval);
        CALL dbms_sql.define_column(c, 2, intval);
        PERFORM dbms_sql.execute(c);
        
        WHILE dbms_sql.fetch_rows(c) > 0
        LOOP
            strval := dbms_sql.column_value_f(c, 1, strval);
            intval := dbms_sql.column_value_f(c, 2, intval);
            stack := stack || strval || ',' || intval || E'\n';
        END LOOP;

        CALL dbms_sql.close_cursor(c);
        RETURN stack;
    END;
    $$;

    SELECT is(
        test_simple_query_f(),
        E'ahoj1,1\n'
         'ahoj2,2\n'
         'ahoj3,3\n'
         'ahoj4,4\n'
         'ahoj5,5\n',
        'Test simple query scenario with column_value_f'
    );

    CREATE TABLE IF NOT EXISTS FOO(a varchar, b int);

    CREATE OR REPLACE FUNCTION test_simple_insert()
    RETURNS void
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'insert into foo values(:a, :b)');
        FOR i in 1..5
        LOOP
            CALL dbms_sql.bind_variable(c, 'a', 'ahoj' || i);
            CALL dbms_sql.bind_variable(c, 'b', i);
            PERFORM dbms_sql.execute(c);
        END LOOP;

        CALL dbms_sql.close_cursor(c);
    END;
    $$;

    SELECT test_simple_insert();
    SELECT results_eq(
        $$SELECT * FROM foo;$$,
        $$VALUES ('ahoj1'::varchar, 1),
                 ('ahoj2'::varchar, 2),
                 ('ahoj3'::varchar, 3),
                 ('ahoj4'::varchar, 4),
                 ('ahoj5'::varchar, 5)$$,
        'Test simple insert scenario'
    );
    
    TRUNCATE foo;

    CREATE OR REPLACE FUNCTION test_simple_insert_f()
    RETURNS void
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'insert into foo values(:a, :b)');
        FOR i in 1..5
        LOOP
            PERFORM dbms_sql.bind_variable_f(c, 'a', 'ahoj' || i);
            PERFORM dbms_sql.bind_variable_f(c, 'b', i);
            PERFORM dbms_sql.execute(c);
        END LOOP;

        CALL dbms_sql.close_cursor(c);
    END;
    $$;

    SELECT test_simple_insert_f();
    SELECT results_eq(
        $$SELECT * FROM foo;$$,
        $$VALUES ('ahoj1'::varchar, 1),
                 ('ahoj2'::varchar, 2),
                 ('ahoj3'::varchar, 3),
                 ('ahoj4'::varchar, 4),
                 ('ahoj5'::varchar, 5)$$,
        'Test simple insert scenario with bind_variable_f'
    );
    TRUNCATE foo;

    CREATE OR REPLACE FUNCTION test_insert_with_array()
    RETURNS int
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
        a varchar[];
        b int[];
        result int;
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'insert into foo values(:a, :b)');
        
        a := ARRAY['ahoj1', 'ahoj2', 'ahoj3', 'ahoj4', 'ahoj5'];
        b := ARRAY[1, 2, 3, 4, 5];
        
        CALL dbms_sql.bind_array(c, 'a', a, 2, 3);
        CALL dbms_sql.bind_array(c, 'b', b, 3, 4);
        
        result := dbms_sql.execute(c);

        CALL dbms_sql.close_cursor(c);
        
        return result;
    END;
    $$;

    SELECT is(
        test_insert_with_array(),
        1,
        'Test number of affected rows after bulk insert'
    );

    SELECT results_eq(
        $$SELECT * FROM foo;$$,
        $$VALUES ('ahoj3'::varchar, 3)$$,
        'Test the contents of the table after bulk insert'
    );
    TRUNCATE foo;

    CREATE OR REPLACE FUNCTION test_insert_with_empty_array()
    RETURNS int
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
        a varchar[];
        result int;
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'insert into foo values(:a, 10)');
       
        CALL dbms_sql.bind_array(c, 'a', a);
        result := dbms_sql.execute(c);
        CALL dbms_sql.close_cursor(c);
        
        return result;
    END;
    $$;

    SELECT is(
        test_insert_with_empty_array(),
        0,
        'Test number of affected rows after bulk insert with empty array'
    );

    SELECT is_empty(
        $$SELECT * FROM foo;$$,
        'Test the contents of the table after bulk insert with empty array'
    );

    CREATE OR REPLACE FUNCTION test_query_without_execute()
    RETURNS void 
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
        a varchar[];
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'select i from generate_series(1, 2) g(i)');
       
        CALL dbms_sql.define_array(c, 1, a, 10, 1);
        CALL dbms_sql.column_value(c, 1, a);
        CALL dbms_sql.close_cursor(c);
    END;
    $$;

    SELECT throws_ok(
        $$SELECT test_query_without_execute();$$,
        'cursor is not executed',
        'Test when accessing the query result without executing'
    );

    CREATE OR REPLACE FUNCTION test_insert_with_overwritten_variable()
    RETURNS void 
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
        a int;
        result int;
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'insert into foo(b) values (:a)');
        CALL dbms_sql.bind_variable(c, 'a', a);
        CALL dbms_sql.bind_variable(c, 'a', a);
        PERFORM dbms_sql.execute(c);
        CALL dbms_sql.close_cursor(c);
    END;
    $$;

    SELECT lives_ok(
        $$SELECT test_insert_with_overwritten_variable();$$,
        'Test when variable is overwritten'
    );

    SELECT results_eq(
        $$SELECT * FROM foo;$$,
        $$VALUES (NULL::varchar, NULL::integer)$$,
        'NULL data is inserted if bind variable is NULL'
    );

    TRUNCATE foo;

    CREATE OR REPLACE FUNCTION test_query_with_no_data()
    RETURNS void 
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        c int;
        strval varchar;
        intval int;
    BEGIN
        c := dbms_sql.open_cursor();
        CALL dbms_sql.parse(c, 'select ''foo'', 1');
        CALL dbms_sql.define_column(c, 1, strval);
        CALL dbms_sql.define_column(c, 2, intval);
        PERFORM dbms_sql.execute(c);

        WHILE dbms_sql.fetch_rows(c) > -1
        LOOP
            CALL dbms_sql.column_value(c, 1, strval);
        END LOOP;
        
        CALL dbms_sql.close_cursor(c);
    END;
    $$;

    SELECT throws_ok(
        $$SELECT test_query_with_no_data();$$,
        'no data found',
        'Test when query has no result'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;