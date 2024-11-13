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
    SELECT results_eq(
        'SELECT bitand(5,1), bitand(5,2), bitand(5,4);',
        $$VALUES (1::bigint, 0::bigint, 4::bigint)$$
    );
    
    SELECT results_eq(
        'SELECT sinh(1.570796)::numeric(10, 8), cosh(1.570796)::numeric(10, 8), tanh(4)::numeric(10, 8);',
        $$VALUES (2.30129808, 2.50917773, 0.99932930)$$
    );

    -- Test remainder
    CREATE TABLE testorafce_remainder(v1 int, v2 int);

    INSERT INTO testorafce_remainder VALUES(24, 7);
    INSERT INTO testorafce_remainder VALUES(24, 6);
    INSERT INTO testorafce_remainder VALUES(24, 5);
    INSERT INTO testorafce_remainder VALUES(-58, -10);
    INSERT INTO testorafce_remainder VALUES(58, 10);
    INSERT INTO testorafce_remainder VALUES(58, -10);
    INSERT INTO testorafce_remainder VALUES(58, 10);
    INSERT INTO testorafce_remainder VALUES(-44, -10);
    INSERT INTO testorafce_remainder VALUES(44, 10);
    INSERT INTO testorafce_remainder VALUES(44, -10);
    INSERT INTO testorafce_remainder VALUES(44, 10);

    SELECT v1, v2, oracle.remainder(v1, v2) FROM testorafce_remainder;
    SELECT v1, v2, oracle.remainder(v1::smallint, v2::smallint) FROM testorafce_remainder;
    SELECT v1, v2, oracle.remainder(v1::bigint, v2::bigint) FROM testorafce_remainder;
    SELECT v1, v2, oracle.remainder(v1::numeric, v2::numeric) FROM testorafce_remainder;

   -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;