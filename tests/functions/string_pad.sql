-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(29);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    /* cases where one or more arguments are of type CHAR */
    SELECT is('|' || oracle.rpad('あbcd'::char(8), 10) || '|', '|あbcd     |');
    SELECT is('|' || oracle.rpad('あbcd'::char(8),  5) || '|', '|あbcd|');
    SELECT is('|' || oracle.rpad('あbcd'::char(8), 1) || '|', '| |');

    SELECT is('|' || oracle.rpad('あbcd'::char(5), 10, 'xい'::char(3)) || '|', '|あbcd xい |');
    SELECT is('|' || oracle.rpad('あbcd'::char(5),  5, 'xい'::char(3)) || '|', '|あbcd|');

    SELECT is('|' || oracle.rpad('あbcd'::char(5), 10, 'xい'::text) || '|', '|あbcd xいx|');
    SELECT is('|' || oracle.rpad('あbcd'::char(5), 10, 'xい'::varchar2(5)) || '|', '|あbcd xいx|');
    SELECT is('|' || oracle.rpad('あbcd'::char(5), 10, 'xい'::nvarchar2(3)) || '|', '|あbcd xいx|');

    SELECT is('|' || oracle.rpad('あbcd'::text, 10, 'xい'::char(3)) || '|', '|あbcdxい x|');
    SELECT is('|' || oracle.rpad('あbcd'::text,  5, 'xい'::char(3)) || '|', '|あbcd|');

    SELECT is('|' || oracle.rpad('あbcd'::varchar2(5), 10, 'xい'::char(3)) || '|', '|あbcxい x |');
    SELECT is('|' || oracle.rpad('あbcd'::varchar2(5),  5, 'xい'::char(3)) || '|', '|あbcx|');

    SELECT is('|' || oracle.rpad('あbcd'::nvarchar2(5), 10, 'xい'::char(3)) || '|', '|あbcdxい x|');
    SELECT is('|' || oracle.rpad('あbcd'::nvarchar2(5),  5, 'xい'::char(3)) || '|', '|あbcd|');

    /* test oracle.lpad(text, int [, text]) */
    SELECT is('|' || oracle.rpad('あbcd'::text, 10) || '|', '|あbcd     |');
    SELECT is('|' || oracle.rpad('あbcd'::text,  5) || '|', '|あbcd|');

    SELECT is('|' || oracle.rpad('あbcd'::varchar2(10), 10) || '|', '|あbcd     |');
    SELECT is('|' || oracle.rpad('あbcd'::varchar2(10), 5) || '|', '|あbcd|');

    SELECT is('|' || oracle.rpad('あbcd'::nvarchar2(10), 10) || '|', '|あbcd     |');
    SELECT is('|' || oracle.rpad('あbcd'::nvarchar2(10), 5) || '|', '|あbcd|');

    SELECT is('|' || oracle.rpad('あbcd'::text, 10, 'xい'::text) || '|', '|あbcdxいx |');
    SELECT is('|' || oracle.rpad('あbcd'::text, 10, 'xい'::varchar2(5)) || '|', '|あbcdxいx |');
    SELECT is('|' || oracle.rpad('あbcd'::text, 10, 'xい'::nvarchar2(3)) || '|', '|あbcdxいx |');

    SELECT is('|' || oracle.rpad('あbcd'::varchar2(5), 10, 'xい'::text) || '|', '|あbcxいxい|');
    SELECT is('|' || oracle.rpad('あbcd'::varchar2(5), 10, 'xい'::varchar2(5)) || '|', '|あbcxいxい|');
    SELECT is('|' || oracle.rpad('あbcd'::varchar2(5), 10, 'xい'::nvarchar2(5)) || '|', '|あbcxいxい|');

    SELECT is('|' || oracle.rpad('あbcd'::nvarchar2(5), 10, 'xい'::text) || '|', '|あbcdxいx |');
    SELECT is('|' || oracle.rpad('あbcd'::nvarchar2(5), 10, 'xい'::varchar2(5)) || '|', '|あbcdxいx |');
    SELECT is('|' || oracle.rpad('あbcd'::nvarchar2(5), 10, 'xい'::nvarchar2(5)) || '|', '|あbcdxいx |');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;