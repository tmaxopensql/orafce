-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(1);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;
    SELECT dbms_random.initialize(8);
    SELECT dbms_random.normal()::numeric(10, 8);
    SELECT dbms_random.normal()::numeric(10, 8);
    SELECT dbms_random.seed(8);
    SELECT dbms_random.random();
    SELECT dbms_random.seed('test');
    SELECT dbms_random.string('U',5);
    SELECT dbms_random.string('P',2);
    SELECT dbms_random.string('x',4);
    SELECT dbms_random.string('a',2);
    SELECT dbms_random.string('l',3);
    SELECT dbms_random.seed(5);
    SELECT dbms_random.value()::numeric(10, 8);
    SELECT dbms_random.value(10,15)::numeric(10, 8);
    SELECT dbms_random.terminate();

    SELECT dbms_random.string('u', 10);
    SELECT dbms_random.string('l', 10);
    SELECT dbms_random.string('a', 10);
    SELECT dbms_random.string('x', 10);
    SELECT dbms_random.string('p', 10);
    SELECT dbms_random.string('uu', 10); -- error
    SELECT dbms_random.string('w', 10);

    -- Write tests
    SELECT pass('My test passed!');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;