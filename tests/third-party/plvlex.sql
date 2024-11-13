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
    SELECT pos, token, class, mod FROM plvlex.tokens('select * from a.b.c join d on x=y', true, true);
    select pos,token from plvlex.tokens('select * from a.b.c join d ON x=y', true, true);
    
    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;