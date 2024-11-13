-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(12);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    SELECT is(dump('Yellow dog'::text) ~ E'^Typ=25 Len=(\\d+): \\d+(,\\d+)*$', true);
    SELECT is(dump('Yellow dog'::text, 10) ~ E'^Typ=25 Len=(\\d+): \\d+(,\\d+)*$', true);
    SELECT is(dump('Yellow dog'::text, 17) ~ E'^Typ=25 Len=(\\d+): .(,.)*$', true);
    SELECT is(dump(10::int2) ~ E'^Typ=21 Len=2: \\d+(,\\d+){1}$', true);
    SELECT is(dump(10::int4) ~ E'^Typ=23 Len=4: \\d+(,\\d+){3}$', true);
    SELECT is(dump(10::int8) ~ E'^Typ=20 Len=8: \\d+(,\\d+){7}$', true);
    SELECT is(dump(10.23::float4) ~ E'^Typ=700 Len=4: \\d+(,\\d+){3}$', true);
    SELECT is(dump(10.23::float8) ~ E'^Typ=701 Len=8: \\d+(,\\d+){7}$', true);
    SELECT is(dump(10.23::numeric) ~ E'^Typ=1700 Len=(\\d+): \\d+(,\\d+)*$', true);
    SELECT is(dump('2008-10-10'::date) ~ E'^Typ=1082 Len=4: \\d+(,\\d+){3}$', true);
    SELECT is(dump('2008-10-10'::timestamp) ~ E'^Typ=1114 Len=8: \\d+(,\\d+){7}$', true);
    SELECT is(dump('2009-10-10'::timestamp) ~ E'^Typ=1114 Len=8: \\d+(,\\d+){7}$', true);

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;