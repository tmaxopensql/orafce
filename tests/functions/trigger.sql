-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(4);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    CREATE TABLE trg_test(a varchar, b int, c varchar, d date, e int);

    SELECT lives_ok(
        'CREATE TRIGGER trg_test_xx BEFORE INSERT OR UPDATE
        ON trg_test FOR EACH ROW EXECUTE PROCEDURE oracle.replace_empty_strings(true);',
        'Test creating trigger replace_empty_strings with true input'
    );

    INSERT INTO trg_test VALUES('',10, 'AHOJ', NULL, NULL);
    INSERT INTO trg_test VALUES('AHOJ', NULL, '', '2020-01-01', 100);

    SELECT results_eq(
        'SELECT * FROM trg_test;',
        $$VALUES (NULL, 10, 'AHOJ'::varchar, NULL, NULL), ('AHOJ'::varchar, NULL, NULL, '2020-01-01'::date, 100) $$,
        'Test replace_empty_strings outcome with true input'
    );

    DELETE FROM trg_test;
    DROP TRIGGER trg_test_xx ON trg_test;

    SELECT lives_ok(
        'CREATE TRIGGER trg_test_xx BEFORE INSERT OR UPDATE
        ON trg_test FOR EACH ROW EXECUTE PROCEDURE oracle.replace_null_strings();',
        'Test creating trigger replace_empty_strings with default'
    );

    INSERT INTO trg_test VALUES(NULL, 10, 'AHOJ', NULL, NULL);
    INSERT INTO trg_test VALUES('AHOJ', NULL, NULL, '2020-01-01', 100);

    SELECT results_eq(
        'SELECT * FROM trg_test;',
        $$VALUES ('', 10, 'AHOJ'::varchar, NULL, NULL), ('AHOJ'::varchar, NULL, '', '2020-01-01'::date, 100)$$,
        'Test replace_empty_strings outcome with default input'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;