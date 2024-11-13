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
    select plunit.assert_true(NULL);
    select plunit.assert_true(1 = 2);
    select plunit.assert_true(1 = 2, 'one is not two');
    select plunit.assert_true(1 = 1);
    select plunit.assert_false(1 = 1);
    select plunit.assert_false(1 = 1, 'trap is open');
    select plunit.assert_false(NULL);
    select plunit.assert_null(current_date);
    select plunit.assert_null(NULL::date);
    select plunit.assert_not_null(current_date);
    select plunit.assert_not_null(NULL::date);
    select plunit.assert_equals('Pavel','Pa'||'vel');
    select plunit.assert_equals(current_date, current_date + 1, 'diff dates');
    select plunit.assert_equals(10.2, 10.3, 0.5);
    select plunit.assert_equals(10.2, 10.3, 0.01, 'attention some diff');
    select plunit.assert_not_equals(current_date, current_date + 1, 'yestarday is today');
    select plunit.fail();
    select plunit.fail('custom exception');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;