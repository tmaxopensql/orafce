-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(20);

    -- Write tests
    -- Test greatest
    SELECT is(oracle.greatest(2, 6, 8, 4), 8, 'Test greatest');
    SELECT is(oracle.greatest(2, NULL, 8, 4), NULL, 'Test greatest returns NULL on any single NULL input');
    SELECT is(oracle.greatest('A'::text, 'B'::text, 'C'::text, 'D'::text), 'D'::text, 'Test greatest with text');
    SELECT is(oracle.greatest('A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar), 'D'::bpchar, 'Test greatest with bpchar');
    SELECT is(oracle.greatest(1::bigint, 2::bigint, 3::bigint, 4::bigint), 4::bigint, 'Test greatest with bigint');
    SELECT is(oracle.greatest(1::integer, 2::integer, 3::integer, 4::integer), 4::integer, 'Test greatest with integer');
    SELECT is(oracle.greatest(1::smallint, 2::smallint, 3::smallint, 4::smallint), 4::smallint, 'Test greatest with smallint');
    SELECT is(oracle.greatest(1.2::numeric, 2.4::numeric, 2.3::numeric, 2.2::numeric), 2.4::numeric, 'Test greatest with numeric');
    SELECT is(oracle.greatest(1.2::double precision, 2.4::double precision, 2.3::double precision, 2.2::double precision), 2.4::double precision, 'Test greatest with double precision');
    SELECT is(oracle.greatest(1.2::real, 2.4::real, 2.2::real, 2.3::real), 2.4::real, 'Test greatest with real');

    -- Test least
    SELECT is(oracle.least(2, 6, 8, 1), 1, 'Test least');
    SELECT is(oracle.least(2, NULL, 8, 1), NULL, 'Test least returns NULL on any single NULL input');
    SELECT is(oracle.least('A'::text, 'B'::text, 'C'::text, 'D'::text), 'A'::text, 'Test least with text');
    SELECT is(oracle.least('A'::bpchar, 'B'::bpchar, 'C'::bpchar, 'D'::bpchar), 'A'::bpchar, 'Test least with bpchar');
    SELECT is(oracle.least(1::bigint, 2::bigint, 3::bigint, 4::bigint), 1::bigint, 'Test least with bigint');
    SELECT is(oracle.least(1::integer, 2::integer, 3::integer, 4::integer), 1::integer, 'Test least with integer');
    SELECT is(oracle.least(1::smallint, 2::smallint, 3::smallint, 4::smallint), 1::smallint, 'Test least with smallint');
    SELECT is(oracle.least(1.2::numeric, 2.4::numeric, 2.3::numeric, 2.2::numeric), 1.2::numeric, 'Test least with numeric');
    SELECT is(oracle.least(1.2::double precision, 2.4::double precision, 2.3::double precision, 2.2::double precision), 1.2::double precision, 'Test least with double precision');
    SELECT is(oracle.least(1.2::real, 2.4::real, 2.2::real, 2.3::real), 1.2::real, 'Test least with real');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;