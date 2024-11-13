-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(1);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests

    select dbms_assert.enquote_literal('some text '' some text');
    select dbms_assert.enquote_name('''"AAA');
    select dbms_assert.enquote_name('''"AAA', false);
    select dbms_assert.noop('some string');
    select dbms_assert.qualified_sql_name('aaa.bbb.ccc."aaaa""aaa"');
    select dbms_assert.qualified_sql_name('aaa.bbb.cc%c."aaaa""aaa"');
    select dbms_assert.schema_name('dbms_assert');
    select dbms_assert.schema_name('jabadabado');
    select dbms_assert.simple_sql_name('"Aaa dghh shsh"');
    select dbms_assert.simple_sql_name('ajajaj -- ajaj');
    select dbms_assert.object_name('pg_catalog.pg_class');
    select dbms_assert.object_name('dbms_assert.fooo');
    select dbms_assert.qualified_sql_name('1broken');
    select dbms_assert.simple_sql_name('1broken');

    select dbms_assert.enquote_literal(NULL);
    select dbms_assert.enquote_name(NULL);
    select dbms_assert.enquote_name(NULL, false);
    select dbms_assert.noop(NULL);
    select dbms_assert.qualified_sql_name(NULL);
    select dbms_assert.qualified_sql_name(NULL);
    select dbms_assert.schema_name(NULL);
    select dbms_assert.schema_name(NULL);
    select dbms_assert.simple_sql_name(NULL);
    select dbms_assert.simple_sql_name(NULL);
    select dbms_assert.object_name(NULL);
    select dbms_assert.object_name(NULL);

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;