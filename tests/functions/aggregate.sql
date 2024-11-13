-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(9);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    -- Tests for listagg
    SELECT results_eq(
        'SELECT listagg(i::text) from generate_series(1,3) g(i);',
        ARRAY['123'],
        'Test listagg without a delimiter'
    );

    SELECT results_eq(
        'SELECT listagg(i::text, '','') from generate_series(1,3) g(i);',
        ARRAY['1,2,3'],
        'Test listagg with a delimiter'
    );

    SELECT results_eq(
        'SELECT coalesce(listagg(i::text), ''A'') from (SELECT ''''::text) g(i);',
        ARRAY[''],
        'Test listagg returns empty string for empty string as input'
    );

    SELECT results_eq(
        'SELECT coalesce(listagg(i::text), ''A'') from generate_series(1,0) g(i);',
        ARRAY['A'],
        'Test listagg returns NULL for empty set as input'
    );

    -- Tests for wm_concat
    SELECT results_eq(
        'SELECT wm_concat(i::text) from generate_series(1,3) g(i);',
        ARRAY['1,2,3'],
        'Test wm_concat'
    );

    -- Tests for median
    CREATE TABLE orafce_test1(c REAL);
    INSERT INTO orafce_test1 VALUES (1500), (2100), (3600), (4000), (4500);

    SELECT results_eq(
        'SELECT median(c) from orafce_test1;',
        ARRAY[3600::REAL],
        'Test median with real values when the number of values is odd'
    );

    INSERT INTO orafce_test1 VALUES (1000);

    SELECT results_eq(
        'SELECT median(c) from orafce_test1;',
        ARRAY[2850::REAL],
        'Test median with real values when the number of values is even'
    );

    CREATE TABLE orafce_test2(c DOUBLE PRECISION);
    INSERT INTO orafce_test2 VALUES (1500), (2100), (3600), (4000), (4500);

    SELECT results_eq(
        'SELECT median(c) from orafce_test2;',
        ARRAY[3600::DOUBLE PRECISION],
        'Test median with real values when the number of values is odd'
    );

    INSERT INTO orafce_test2 VALUES (1000);

    SELECT results_eq(
        'SELECT median(c) from orafce_test2;',
        ARRAY[2850::DOUBLE PRECISION],
        'Test median with real values when the number of values is even'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;