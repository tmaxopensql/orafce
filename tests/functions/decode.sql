-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(54);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    -- Tests for decode
    SELECT is(decode(1, 1, 100, 2, 200), 100);
    SELECT is(decode(2, 1, 100, 2, 200), 200);
    SELECT is(decode(3, 1, 100, 2, 200), NULL);
    SELECT is(decode(3, 1, 100, 2, 200, 300), 300);
    SELECT is(decode(NULL, 1, 100, NULL, 200, 300), 200);
    SELECT is(decode('1'::text, '1', 100, '2', 200), 100);
    SELECT is(decode(2, 1, 'ABC', 2, 'DEF'), 'DEF');
    SELECT is(decode('2009-02-05'::date, '2009-02-05', 'ok'), 'ok');
    SELECT is(decode('2009-02-05 01:02:03'::timestamp, '2009-02-05 01:02:03', 'ok'), 'ok');

    -- For type 'bpchar'
    SELECT is(decode('a'::bpchar, 'a'::bpchar, 'postgres'::bpchar, 'b'::bpchar, 'database'::bpchar), 'postgres');
    SELECT is(decode('d'::bpchar, 'a'::bpchar, 'postgres'::bpchar, 'b'::bpchar, 'database'::bpchar), NULL);
    SELECT is(decode('d'::bpchar, 'a'::bpchar, 'postgres'::bpchar, 'b'::bpchar, 'database'::bpchar, 'default'::bpchar), 'default');

    SELECT is(decode(NULL, 'a'::bpchar, 'postgres'::bpchar, NULL, 'database'::bpchar), 'database');
    SELECT is(decode(NULL, 'a'::bpchar, 'postgres'::bpchar, 'b'::bpchar, 'database'::bpchar), NULL);
    SELECT is(decode(NULL, 'a'::bpchar, 'postgres'::bpchar, 'b'::bpchar, 'database'::bpchar, 'default'::bpchar), 'default');

    -- For type 'bigint'
    SELECT is(decode(2147483651::bigint, 2147483651::bigint, 2147483650::bigint, 2147483652::bigint, 2147483651::bigint), 2147483650::bigint);
    SELECT is(decode(2147483654::bigint, 2147483651::bigint, 2147483650::bigint, 2147483652::bigint, 2147483651::bigint), NULL);
    SELECT is(decode(2147483654::bigint, 2147483651::bigint, 2147483650::bigint, 2147483652::bigint, 2147483651::bigint, 9999999999::bigint), 9999999999::bigint);

    SELECT is(decode(NULL, 2147483651::bigint, 2147483650::bigint, NULL, 2147483651::bigint), 2147483651::bigint);
    SELECT is(decode(NULL, 2147483651::bigint, 2147483650::bigint, 2147483652::bigint, 2147483651::bigint), NULL);
    SELECT is(decode(NULL, 2147483651::bigint, 2147483650::bigint, 2147483652::bigint, 2147483651::bigint, 9999999999::bigint), 9999999999::bigint);

    -- For type 'numeric'
    SELECT is(decode(12.001::numeric(5,3), 12.001::numeric(5,3), 214748.3650::numeric(10,4), 12.002::numeric(5,3), 214748.3651::numeric(10,4)), 214748.3650::numeric(10,4));
    SELECT is(decode(12.004::numeric(5,3), 12.001::numeric(5,3), 214748.3650::numeric(10,4), 12.002::numeric(5,3), 214748.3651::numeric(10,4)), NULL);
    SELECT is(decode(12.004::numeric(5,3), 12.001::numeric(5,3), 214748.3650::numeric(10,4), 12.002::numeric(5,3), 214748.3651::numeric(10,4), 999999.9999::numeric(10,4)), 999999.9999::numeric(10,4));

    SELECT is(decode(NULL, 12.001::numeric(5,3), 214748.3650::numeric(10,4), NULL, 214748.3651::numeric(10,4)), 214748.3651::numeric(10,4));
    SELECT is(decode(NULL, 12.001::numeric(5,3), 214748.3650::numeric(10,4), 12.002::numeric(5,3), 214748.3651::numeric(10,4)), NULL);
    SELECT is(decode(NULL, 12.001::numeric(5,3), 214748.3650::numeric(10,4), 12.002::numeric(5,3), 214748.3651::numeric(10,4), 999999.9999::numeric(10,4)), 999999.9999::numeric(10,4));

    --For type 'date'
    SELECT is(decode('2020-01-01'::date, '2020-01-01'::date, '2012-12-20'::date, '2020-01-02'::date, '2012-12-21'::date), '2012-12-20'::date);
    SELECT is(decode('2020-01-04'::date, '2020-01-01'::date, '2012-12-20'::date, '2020-01-02'::date, '2012-12-21'::date), NULL);
    SELECT is(decode('2020-01-04'::date, '2020-01-01'::date, '2012-12-20'::date, '2020-01-02'::date, '2012-12-21'::date, '2012-12-31'::date), '2012-12-31'::date);

    SELECT is(decode(NULL, '2020-01-01'::date, '2012-12-20'::date, NULL, '2012-12-21'::date), '2012-12-21'::date);
    SELECT is(decode(NULL, '2020-01-01'::date, '2012-12-20'::date, '2020-01-02'::date, '2012-12-21'::date), NULL);
    SELECT is(decode(NULL, '2020-01-01'::date, '2012-12-20'::date, '2020-01-02'::date, '2012-12-21'::date, '2012-12-31'::date), '2012-12-31'::date);

    -- For type 'time'
    SELECT is(decode('01:00:01'::time, '01:00:01'::time, '09:00:00'::time, '01:00:02'::time, '12:00:00'::time), '09:00:00'::time);
    SELECT is(decode('01:00:04'::time, '01:00:01'::time, '09:00:00'::time, '01:00:02'::time, '12:00:00'::time), NULL);
    SELECT is(decode('01:00:04'::time, '01:00:01'::time, '09:00:00'::time, '01:00:01'::time, '12:00:00'::time, '00:00:00'::time), '00:00:00'::time);

    SELECT is(decode(NULL, '01:00:01'::time, '09:00:00'::time, NULL, '12:00:00'::time), '12:00:00'::time);
    SELECT is(decode(NULL, '01:00:01'::time, '09:00:00'::time, '01:00:02'::time, '12:00:00'::time), NULL);
    SELECT is(decode(NULL, '01:00:01'::time, '09:00:00'::time, '01:00:02'::time, '12:00:00'::time, '00:00:00'::time), '00:00:00'::time);

    -- For type 'timestamp'
    SELECT is(decode('2020-01-01 01:00:01'::timestamp, '2020-01-01 01:00:01'::timestamp, '2012-12-20 09:00:00'::timestamp, '2020-01-02 01:00:01'::timestamp, '2012-12-20 12:00:00'::timestamp, '2012-12-20 09:00:00'::timestamp), '2012-12-20 09:00:00'::timestamp);
    SELECT is(decode('2020-01-04 01:00:01'::timestamp, '2020-01-01 01:00:01'::timestamp, '2012-12-20 09:00:00'::timestamp, '2020-01-02 01:00:01'::timestamp, '2012-12-20 12:00:00'::timestamp), NULL);
    SELECT is(decode('2020-01-04 01:00:01'::timestamp, '2020-01-01 01:00:01'::timestamp, '2012-12-20 09:00:00'::timestamp, '2020-01-02 01:00:01'::timestamp, '2012-12-20 12:00:00'::timestamp, '2012-12-20 00:00:00'::timestamp), '2012-12-20 00:00:00'::timestamp);

    SELECT is(decode(NULL, '2020-01-01 01:00:01'::timestamp, '2012-12-20 09:00:00'::timestamp, NULL, '2012-12-20 12:00:00'::timestamp), '2012-12-20 12:00:00'::timestamp);
    SELECT is(decode(NULL, '2020-01-01 01:00:01'::timestamp, '2012-12-20 09:00:00'::timestamp, '2020-01-02 01:00:01'::timestamp, '2012-12-20 12:00:00'::timestamp), NULL);
    SELECT is(decode(NULL, '2020-01-01 01:00:01'::timestamp, '2012-12-20 09:00:00'::timestamp, '2020-01-02 01:00:01'::timestamp, '2012-12-20 12:00:00'::timestamp, '2012-12-20 00:00:00'::timestamp), '2012-12-20 00:00:00'::timestamp);

    -- For type 'timestamptz'
    SELECT is(decode('2020-01-01 01:00:01-08'::timestamptz, '2020-01-01 01:00:01-08'::timestamptz, '2012-12-20 09:00:00-08'::timestamptz, '2020-01-02 01:00:01-08'::timestamptz, '2012-12-20 12:00:00-08'::timestamptz), '2012-12-20 09:00:00-08'::timestamptz);
    SELECT is(decode('2020-01-04 01:00:01-08'::timestamptz, '2020-01-01 01:00:01-08'::timestamptz, '2012-12-20 09:00:00-08'::timestamptz, '2020-01-02 01:00:01-08'::timestamptz, '2012-12-20 12:00:00-08'::timestamptz), NULL);
    SELECT is(decode('2020-01-04 01:00:01-08'::timestamptz, '2020-01-01 01:00:01-08'::timestamptz, '2012-12-20 09:00:00-08'::timestamptz, '2020-01-02 01:00:01-08'::timestamptz, '2012-12-20 12:00:00-08'::timestamptz, '2012-12-20 00:00:00-08'::timestamptz), '2012-12-20 00:00:00-08'::timestamptz);

    SELECT is(decode(NULL, '2020-01-01 01:00:01-08'::timestamptz, '2012-12-20 09:00:00-08'::timestamptz, NULL, '2012-12-20 12:00:00-08'::timestamptz), '2012-12-20 12:00:00-08'::timestamptz);
    SELECT is(decode(NULL, '2020-01-01 01:00:01-08'::timestamptz, '2012-12-20 09:00:00-08'::timestamptz, '2020-01-02 01:00:01-08'::timestamptz, '2012-12-20 12:00:00-08'::timestamptz), NULL);
    SELECT is(decode(NULL, '2020-01-01 01:00:01-08'::timestamptz, '2012-12-20 09:00:00-08'::timestamptz, '2020-01-02 01:00:01-08'::timestamptz, '2012-12-20 12:00:00-08'::timestamptz, '2012-12-20 00:00:00-08'::timestamptz), '2012-12-20 00:00:00-08'::timestamptz);

    CREATE OR REPLACE FUNCTION five() RETURNS integer AS $$
    BEGIN
        RETURN 5;
    END; 
    $$ LANGUAGE plpgsql;

    SELECT is(
        decode(five(), 1, 'one', 2, 'two', 5, 'five'),
        'five',
        'Test decode accepts other expressions as a key'
    );

    SELECT is(
        decode(1, 1, 'one', 2, 'two', 1, 'one-again'),
        'one',
        'Test to check duplicate keys in search list'
    );

    SELECT is(
        decode('2012-01-01', '2012-01-01'::date, 'result-1', '2012-01-02', 'result-2'),
        'result-1',
        'Test check explicit type casting of keys in search list'
    );

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;