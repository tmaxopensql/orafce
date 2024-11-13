-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(23);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    -- Test LNNVL
    SELECT is(lnnvl(true), false);
    SELECT is(lnnvl(false), true);
    SELECT is(lnnvl(NULL), true);

    -- Test NANVL
    SELECT results_eq(
        'select nanvl(12345, 1), nanvl(''NaN'', 1);',
        $$VALUES (12345::double precision, 1::double precision)$$
    );

    SELECT results_eq(
        'select nanvl(12345::float4, 1), nanvl(''NaN''::float4, 1);',
        $$VALUES (12345::float4, 1::float4)$$
    );
 
    SELECT results_eq(
        'select nanvl(12345::float8, 1), nanvl(''NaN''::float8, 1);',
        $$VALUES (12345::float8, 1::float8)$$
    );
 
    SELECT results_eq(
        'select nanvl(12345::numeric, 1), nanvl(''NaN''::numeric, 1);',
        $$VALUES (12345::numeric, 1::numeric)$$
    );
 
    SELECT results_eq(
        'select nanvl(12345, ''1''::varchar), nanvl(''NaN'', ''1''::varchar);',
        $$VALUES (12345::double precision, 1::double precision)$$
    );

    SELECT results_eq(
        'select nanvl(12345, ''1''::char), nanvl(''NaN'', ''1''::char);',
        $$VALUES (12345::double precision, 1::double precision)$$
    );

    SELECT is(nvl('A'::text, 'B'), 'A'::text);
    SELECT is(nvl(NULL::text, 'B'), 'B');
    SELECT is(nvl(NULL::text, NULL), NULL);
    SELECT is(nvl(1, 2), 1);
    SELECT is(nvl(NULL::int, 2), 2);
    SELECT is(nvl(NULL::double precision, 1), 1::double precision);
    SELECT is(nvl(1.1::double precision, 1), 1.1::double precision);
    SELECT is(nvl(1.1::numeric, 1), 1.1::numeric);
    SELECT is(nvl2('A'::text, 'B', 'C'), 'B');
    SELECT is(nvl2(NULL::text, 'B', 'C'), 'C');
    SELECT is(nvl2('A'::text, NULL, 'C'), NULL);
    SELECT is(nvl2(NULL::text, 'B', NULL), NULL);
    SELECT is(nvl2(1, 2, 3), 2);
    SELECT is(nvl2(NULL, 2, 3), 3);

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;