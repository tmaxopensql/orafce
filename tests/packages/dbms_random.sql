-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(21);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    SELECT lives_ok(
        $$select dbms_random.initialize(8);$$,
        'Test dbms_random.initialize'
    );
    
    SELECT is(
        dbms_random.normal()::numeric(10, 8),
        -0.37787769::numeric,
        'Test#1 dbms_random.normal with numeric type'
    );

    SELECT is(
        dbms_random.normal()::numeric(10, 8),
        0.80499804::numeric,
        'Test#2 dbms_random.normal with numeric type'
    );
    
    SELECT lives_ok(
        $$select dbms_random.seed(8)$$,
        'Test dbms_random.seed'
    );
    
    SELECT is(
        dbms_random.random(),
        -632387854,
        'Test dbms_random.random'
    );

    SELECT lives_ok(
        $$select dbms_random.seed('test');$$,
        'Test dbms_random.seed with string value'
    );

    SELECT is(
        dbms_random.string('U',5),
        'XEJGE',
        'Test dbms_random.string with U'
    );

    SELECT is(
        dbms_random.string('P',2),
        'Y9',
        'Test dbms_random.string with P'
    );

    SELECT is(
        dbms_random.string('x',4),
        'FVGL',
        'Test dbms_random.string with x'
    );

    SELECT is(
        dbms_random.string('a',2),
        'AZ',
        'Test dbms_random.string with a'
    );

    SELECT is(
        dbms_random.string('l',3),
        'hmo',
        'Test dbms_random.string with l'
    );

    select dbms_random.seed(5);
    
    SELECT is(
        dbms_random.value()::numeric(10, 8),
        0.27474560::numeric,
        'Test#1 dbms_random.value with precision'
    );

    SELECT is(
        dbms_random.value(10,15)::numeric(10, 8),
        10.23233882::numeric,
        'Test#2 dbms_random.value with precision'
    );

    SELECT lives_ok(
        $$select dbms_random.terminate();$$,
        'Test dbms_random.terminate'
    );

    SELECT is(
        dbms_random.string('u', 10),
        'ZCDCHLMXAH',
        'Test dbms_random.string with u after ternminate'
    );
    
    SELECT is(
        dbms_random.string('l', 10),
        'zfkgjhkghl',
        'Test dbms_random.string with l after terminate'
    );

    SELECT is(
        dbms_random.string('a', 10),
        'xodQYutYyH',
        'Test dbms_random.string with a after terminate'
    );

    SELECT is(
        dbms_random.string('x', 10),
        '0GQ5J0M1WM',
        'Test dbms_random.string with x after terminate'
    );

    SELECT is(
        dbms_random.string('p', 10),
        'hX"|=i1&/h',
        'Test dbms_random.string with p after terminate'
    );
    
    SELECT throws_ok(
        $$select dbms_random.string('uu', 10);$$,
        'this first parameter value is more than 1 characters long',
        'Test dbms_random.string with invalid argument'
    );
    
    SELECT is(
        dbms_random.string('w', 10),
        'AXPCTOMDNY',
        'Test dbms_random.string with w after terminate'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;