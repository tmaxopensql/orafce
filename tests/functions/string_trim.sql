-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(24);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    -- Test LTRIM
    SELECT is('|' || oracle.ltrim(' abcd'::char(10)) || '|', '|abcd     |');
    SELECT is('|' || oracle.ltrim(' abcd'::char(10),'a'::char(3)) || '|', '|bcd     |');
    SELECT is('|' || oracle.ltrim(' abcd'::char(10),'a'::text) || '|', '| abcd     |');
    SELECT is('|' || oracle.ltrim(' abcd'::char(10),'a'::varchar2(3)) || '|', '| abcd     |');
    SELECT is('|' || oracle.ltrim(' abcd'::char(10),'a'::nvarchar2(3)) || '|', '| abcd     |');

    SELECT is('|' || oracle.ltrim(' abcd  '::text,'a'::char(3)) || '|', '|bcd  |');
    SELECT is('|' || oracle.ltrim(' abcd  '::varchar2(10),'a'::char(3)) || '|', '|bcd  |');
    SELECT is('|' || oracle.ltrim(' abcd  '::nvarchar2(10),'a'::char(3)) || '|', '|bcd  |');

    -- Test RTRIM
    SELECT is('|' || oracle.rtrim(' abcd'::char(10)) || '|', '| abcd|');
    SELECT is('|' || oracle.rtrim(' abcd'::char(10),'d'::char(3)) || '|', '| abc|');
    SELECT is('|' || oracle.rtrim(' abcd'::char(10),'d'::text) || '|', '| abcd     |');
    SELECT is('|' || oracle.rtrim(' abcd'::char(10),'d'::varchar2(3)) || '|', '| abcd     |');
    SELECT is('|' || oracle.rtrim(' abcd'::char(10),'d'::nvarchar2(3)) || '|', '| abcd     |');

    SELECT is('|' || oracle.rtrim(' abcd  '::text,'d'::char(3)) || '|', '| abc|');
    SELECT is('|' || oracle.rtrim(' abcd  '::varchar2(10),'d'::char(3)) || '|', '| abc|');
    SELECT is('|' || oracle.rtrim(' abcd  '::nvarchar2(10),'d'::char(3)) || '|', '| abc|');

    -- Test BTRIM
    SELECT is('|' || oracle.btrim(' abcd'::char(10)) || '|', '|abcd|');
    SELECT is('|' || oracle.btrim(' abcd'::char(10),'ad'::char(3)) || '|', '|bc|');
    SELECT is('|' || oracle.btrim(' abcd'::char(10),'ad'::text) || '|', '| abcd     |');
    SELECT is('|' || oracle.btrim(' abcd'::char(10),'ad'::varchar2(3)) || '|', '| abcd     |');
    SELECT is('|' || oracle.btrim(' abcd'::char(10),'ad'::nvarchar2(3)) || '|', '| abcd     |');

    SELECT is('|' || oracle.btrim(' abcd  '::text,'d'::char(3)) || '|', '|abc|');
    SELECT is('|' || oracle.btrim(' abcd  '::varchar2(10),'d'::char(3)) || '|', '|abc|');
    SELECT is('|' || oracle.btrim(' abcd  '::nvarchar2(10),'d'::char(3)) || '|', '|abc|');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;