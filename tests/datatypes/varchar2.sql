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
    SELECT throws_ok(
        'CREATE TABLE orafce_test(c VARCHAR2(0));',
        'length for type varchar must be at least 1',
        'Type modifier needs to be greater than 0'
    );

    SELECT throws_ok(
        'CREATE TABLE orafce_test(c VARCHAR2(10485761));',
        'length for type varchar cannot exceed 10485760',
        'Type modifier cannot exceed 10485760'
    );

    SELECT throws_ok(
        'CREATE TABLE orafce_test(c VARCHAR2(1, 1));',
        'invalid type modifier',
        'Number of type modifer needs to be 1'
    );

    SELECT lives_ok(
        'CREATE TABLE orafce_test(c VARCHAR2(5));',
        'Test a table is created with a varchar2 type column'
    );

    SELECT lives_ok(
        'CREATE INDEX ON orafce_test(c);',
        'Test an index is created with a varchar2 type column'
    );

    SELECT throws_ok(
        'INSERT INTO orafce_test VALUES (''abcdef'');',
        'input value length is 6; too long for type varchar2(5)',
        'A value cannot be longer than the type modifier'
    );

    SELECT throws_ok(
        'INSERT INTO orafce_test VALUES (''abcde '');',
        'input value length is 6; too long for type varchar2(5)',
        'VARCHAR2 does not truncate whitespaces on implicit coercion'
    );

    SELECT lives_ok(
        'INSERT INTO orafce_test VALUES (''abcde'');',
        'Test a value is inserted with a varchar2 type column'
    );

    SELECT lives_ok(
        'INSERT INTO orafce_test VALUES (''abcdef''::VARCHAR2(5));',
        'Test a value is truncated on implcit type casting'
    );

    SELECT lives_ok(
        'INSERT INTO orafce_test VALUES (''abcde ''::VARCHAR2(5));',
        'Test a whitespace is truncated on implicit type casting'
    );

    SELECT is(
        'abcde   '::VARCHAR2(10),
        'abcde   '::VARCHAR2(10),
        'Same number of whitespaces'
    );

    SELECT isnt(
        'abcde   '::VARCHAR2(10),
        'abcde  '::VARCHAR2(10),
        'Different number of whitespaces'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;