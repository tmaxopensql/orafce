-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(22);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    select is(
        dbms_assert.enquote_literal('some text '' some text'),
        $$'some text '' some text'$$,
        'Test dbms_assert.enquote_literal');

    select is(
        dbms_assert.enquote_name('''"AAA'),
        $$"'""aaa"$$,
        'Test dbms_assert.enquote_name');
    
    select is(
        dbms_assert.enquote_name('''"AAA', false),
        $$"'""AAA"$$,
        'Test dbms_assert.enquote_name without lowerizing');

    select is(
        dbms_assert.noop('some string'),
        'some string',
        'Test dbms_assert.noop');

    select is(
        dbms_assert.qualified_sql_name('aaa.bbb.ccc."aaaa""aaa"'),
        $$aaa.bbb.ccc."aaaa""aaa"$$,
        'Test dbms_assert.qualified_sql_name');
    
    select throws_ok(
        $$select dbms_assert.qualified_sql_name('aaa.bbb.cc%c."aaaa""aaa"');$$,
        44004, 'string is not qualified SQL name',
        'Test dbms_assert.qualified_sql_name with invalid name'
    );
    
    select is(
        dbms_assert.schema_name('dbms_assert'),
        'dbms_assert',
        'Test dbbms_assert.schema_name');

    select throws_ok(
        $$select dbms_assert.schema_name('jabadabado');$$,
        44001, 'invalid schema name',
        'Test dbms_assert.schema_name with invalid name'
    );

    select is(
        dbms_assert.simple_sql_name('"Aaa dghh shsh"'),
        $$"Aaa dghh shsh"$$,
        'Test dbms_assert.simple_sql_name');

    select throws_ok(
        $$select dbms_assert.simple_sql_name('ajajaj -- ajaj');$$,
        44003, 'string is not simple SQL name',
        'Test dbms_assert.simple_sql_name with not simple name'
    );

    select is(
        dbms_assert.object_name('pg_catalog.pg_class'),
        'pg_catalog.pg_class',
        'Test dbms_assert.object_name');

    select throws_ok(
        $$select dbms_assert.object_name('dbms_assert.fooo');$$,
        44002, 'invalid object name',
        'Test dbms_assert.object_name with invalid name'
    );

    select throws_ok(
        $$select dbms_assert.qualified_sql_name('1broken');$$,
        44004, 'string is not qualified SQL name',
        'Test dbms_assert.qualified_sql_name with invalid name'
    );

    select throws_ok(
        $$select dbms_assert.simple_sql_name('1broken');$$,
        44003, 'string is not simple SQL name',
        'Test dbms_assert.simple_sql_name with not simple name'
    );

    select is(
        dbms_assert.enquote_literal(NULL),
        NULL,
        'Test dbms_assert.enquote_literal with NULL value'
    );
    
    select is(
        dbms_assert.enquote_name(NULL),
        NULL,
        'Test dbms_assert.enquote_name with NULL value'
    );

    select is(
        dbms_assert.enquote_name(NULL, false),
        NULL,
        'Test dbms_assert.enquote_name without lowerizing and NULL value'
    );

    select is(
        dbms_assert.noop(NULL),
        NULL,
        'Test dbms_assert.noop with NULL value'
    );
    
    select throws_ok(
		$$select dbms_assert.qualified_sql_name(NULL);$$,
        44004, 'string is not qualified SQL name',
        'Test dbms_assert.qualified_sql_name with NULL value'
    );
   
    select throws_ok(
		$$select dbms_assert.schema_name(NULL);$$,
        44001, 'invalid schema name',
        'Test dbms_assert.schema_name with NULL value'
    );

    select throws_ok(
		$$select dbms_assert.simple_sql_name(NULL);$$,
        44003, 'string is not simple SQL name',
        'Test dbms_assert.simple_sql_name with NULL value'
    );

    select throws_ok(
		$$select dbms_assert.object_name(NULL);$$,
        44002, 'invalid object name',
        'Test dbms_assert.object_name with NULL value'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;