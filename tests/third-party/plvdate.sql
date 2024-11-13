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
    -- Test plvdate.bizdays_between
    SELECT plvdate.including_start();
    SELECT plvdate.bizdays_between('2016-02-24','2016-02-26');
    SELECT plvdate.bizdays_between('2016-02-21','2016-02-27');
    SELECT plvdate.include_start(false);
    SELECT plvdate.bizdays_between('2016-02-24','2016-02-26');
    SELECT plvdate.bizdays_between('2016-02-21','2016-02-27');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;