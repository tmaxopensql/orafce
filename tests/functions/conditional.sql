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
    SELECT is(lnnvl(true), false, 'Test lnnvl with true');
    SELECT is(lnnvl(false), true, 'Test lnnvl with false');
    SELECT is(lnnvl(NULL), true, 'Test lnnvl with NULL');

    -- Test NANVL
    SELECT results_eq(
        'select nanvl(12345, 1), nanvl(''NaN'', 1);',
        $$VALUES (12345::double precision, 1::double precision)$$,
        'Test nanvl with double precision'
    );

    SELECT results_eq(
        'select nanvl(12345::float4, 1), nanvl(''NaN''::float4, 1);',
        $$VALUES (12345::float4, 1::float4)$$,
        'Test nanvl with float4'
    );
 
    SELECT results_eq(
        'select nanvl(12345::float8, 1), nanvl(''NaN''::float8, 1);',
        $$VALUES (12345::float8, 1::float8)$$,
        'Test nanvl with float8'
    );
 
    SELECT results_eq(
        'select nanvl(12345::numeric, 1), nanvl(''NaN''::numeric, 1);',
        $$VALUES (12345::numeric, 1::numeric)$$,
        'Test nanvl with numeric'
    );
 
    SELECT results_eq(
        'select nanvl(12345, ''1''::varchar), nanvl(''NaN'', ''1''::varchar);',
        $$VALUES (12345::double precision, 1::double precision)$$,
        'Test nanvl with varchar'
    );

    SELECT results_eq(
        'select nanvl(12345, ''1''::char), nanvl(''NaN'', ''1''::char);',
        $$VALUES (12345::double precision, 1::double precision)$$,
        'Test nanvl with char'
    );

    SELECT is(nvl('A'::text, 'B'), 'A'::text, 'Test nvl with text, text');
    SELECT is(nvl(NULL::text, 'B'), 'B', 'Test nvl with NULL, text');
    SELECT is(nvl(NULL::text, NULL), NULL, 'Test nvl with NULL::text, NULL');
    SELECT is(nvl(1, 2), 1, 'Test nvl with int, int');
    SELECT is(nvl(NULL::int, 2), 2, 'Test nvl with NULL, int');
    SELECT is(nvl(NULL::double precision, 1), 1::double precision, 'Test nvl with NULL, double precision');
    SELECT is(nvl(1.1::double precision, 1), 1.1::double precision, 'Test nvl with double precision, double precision');
    SELECT is(nvl(1.1::numeric, 1), 1.1::numeric, 'Test nvl with numeric, numeric');
    SELECT is(nvl2('A'::text, 'B', 'C'), 'B', 'Test nvl2 with text, text, text');
    SELECT is(nvl2(NULL::text, 'B', 'C'), 'C', 'Test nvl2 with NULL, text, text');
    SELECT is(nvl2('A'::text, NULL, 'C'), NULL, 'Test nvl2 with text, NULL, text');
    SELECT is(nvl2(NULL::text, 'B', NULL), NULL, 'Test nvl2 with NULL::text, text, NULL');
    SELECT is(nvl2(1, 2, 3), 2, 'Test nvl2 with int, int, int');
    SELECT is(nvl2(NULL, 2, 3), 3, 'Test nvl2 with NULL, int, int');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;