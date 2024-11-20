-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(18);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    SELECT results_eq(
        'SELECT bitand(5,1), bitand(5,2), bitand(5,4);',
        $$VALUES (1::bigint, 0::bigint, 4::bigint)$$,
        'Test bitand'
    );
    
    SELECT results_eq(
        'SELECT sinh(1.570796)::numeric(10, 8), cosh(1.570796)::numeric(10, 8), tanh(4)::numeric(10, 8);',
        $$VALUES (2.30129808, 2.50917773, 0.99932930)$$,
        'Test hyperbolic trignometric functions'
    );

    -- Test remainder
    SELECT is(oracle.remainder(24, 7), 3, 'Test remainder 24 % 7 = 3');
    SELECT is(oracle.remainder(24, 6), 0, 'Test remainder 24 % 6 = 0');
    SELECT is(oracle.remainder(24, 5), -1, 'Test remainder 24 % 5 = -1');
    SELECT is(oracle.remainder(-58, -10), 2, 'Test remainder -58 % -10 = 2');

    SELECT is(oracle.remainder(24::smallint, 7::smallint), 3::smallint, 'Test remainder with smallint 24 % 7 = 3');
    SELECT is(oracle.remainder(24::smallint, 6::smallint), 0::smallint, 'Test remainder with smallint 24 % 6 = 0');
    SELECT is(oracle.remainder(24::smallint, 5::smallint), -1::smallint, 'Test remainder with smallint 24 % 5 = -1');
    SELECT is(oracle.remainder(-58::smallint, -10::smallint), 2::smallint, 'Test remainder with smallint -58 % -10 = 2');

    SELECT is(oracle.remainder(24::bigint, 7::bigint), 3::bigint, 'Test remainder with bigint 24 % 7 = 3');
    SELECT is(oracle.remainder(24::bigint, 6::bigint), 0::bigint, 'Test remainder with bigint 24 % 6 = 0');
    SELECT is(oracle.remainder(24::bigint, 5::bigint), -1::bigint, 'Test remainder with bigint 24 % 5 = -1');
    SELECT is(oracle.remainder(-58::bigint, -10::bigint), 2::bigint, 'Test remainder with bigint -58 % -10 = 2');

    SELECT is(oracle.remainder(24::numeric, 7::numeric), 3::numeric, 'Test remainder with numeric 24 % 7 = 3');
    SELECT is(oracle.remainder(24::numeric, 6::numeric), 0::numeric, 'Test remainder with numeric 24 % 6 = 0');
    SELECT is(oracle.remainder(24::numeric, 5::numeric), -1::numeric, 'Test remainder with numeric 24 % 5 = -1');
    SELECT is(oracle.remainder(-58::numeric, -10::numeric), 2::numeric, 'Test remainder with numeric -58 % -10 = 2');

   -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;