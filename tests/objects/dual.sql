-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(2);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    SELECT has_view('dual');
    SELECT results_eq('SELECT * FROM DUAL;', $$VALUES ('X'::VARCHAR)$$);

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;
