-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(57);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    -- Test to_char
    SET lc_numeric TO 'C';
    select is(to_char(22), '22');
    select is(to_char(99::smallint), '99');
    select is(to_char(-44444), '-44444');
    select is(to_char(1234567890123456::bigint), '1234567890123456');
    select is(to_char(123.456::real), '123.456');
    select is(to_char(1234.5678::double precision), '1234.5678');
    select is(to_char(12345678901234567890::numeric), '12345678901234567890');
    select is(to_char(1234567890.12345), '1234567890.12345');
    select is(to_char('4.00'::numeric), '4');
    select is(to_char('4.0010'::numeric), '4.001');

    select is(to_char('-44444'), '-44444');
    select is(to_char('1234567890123456'), '1234567890123456');
    select is(to_char('123.456'), '123.456');
    select is(to_char('123abc'), '123abc');
    select is(to_char('你好123@$%abc'), '你好123@$%abc');
    select is(to_char('1234567890123456789012345678901234567890123456789012345678901234567890'), '1234567890123456789012345678901234567890123456789012345678901234567890');
    select is(to_char(''), '');
    select is(to_char(' '), ' ');
    select is(to_char(null), NULL);
 
    --Tests for oracle.to_char(timestamp)-used to set the DATE output format
    SET search_path to oracle, "$user", public, pg_catalog;
    SET orafce.nls_date_format to default;
    SELECT is(oracle.to_char(to_date('19-APR-16 21:41:48')), '2016-04-19 21:41:48');
    set orafce.nls_date_format='YY-MonDD HH24:MI:SS';
    SELECT is(oracle.to_char(to_date('14-Jan08 11:44:49+05:30')), '14-Jan08 11:44:49');
    set orafce.nls_date_format='YY-DDMon HH24:MI:SS';
    SELECT is(oracle.to_char(to_date('14-08Jan 11:44:49+05:30')), '14-08Jan 11:44:49');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(oracle.to_char(to_date('21052014 12:13:44+05:30')), '21052014 12:13:44');
    set orafce.nls_date_format='DDMMYY HH24:MI:SS';
    SELECT is(oracle.to_char(to_date('210514 12:13:44+05:30')), '210514 12:13:44');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('2014/04/25 10:13', 'YYYY/MM/DD HH:MI')), '25042014 10:13:00');
    set orafce.nls_date_format='YY-DDMon HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('16-Feb-09 10:11:11', 'DD-Mon-YY HH:MI:SS')), '09-16Feb 10:11:11');
    set orafce.nls_date_format='YY-DDMon HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('02/16/09 04:12:12', 'MM/DD/YY HH24:MI:SS')), '09-16Feb 04:12:12');
    set orafce.nls_date_format='YY-MonDD HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('021609 111213', 'MMDDYY HHMISS')), '09-Feb16 11:12:13');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('16-Feb-09 11:12:12', 'DD-Mon-YY HH:MI:SS')), '16022009 11:12:12');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('Feb/16/09 11:21:23', 'Mon/DD/YY HH:MI:SS')), '16022009 11:21:23');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('February.16.2009 10:11:12', 'Month.DD.YYYY HH:MI:SS')), '16022009 10:11:12');
    set orafce.nls_date_format='YY-MonDD HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('20020315111212', 'yyyymmddhh12miss')), '02-Mar15 11:12:12');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('January 15, 1989, 11:00 A.M.','Month dd, YYYY, HH:MI A.M.')), '15011989 11:00:00');
    set orafce.nls_date_format='DDMMYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('14-Jan08 11:44:49+05:30' ,'YY-MonDD HH24:MI:SS')), '080114 11:44:49');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('14-08Jan 11:44:49+05:30','YY-DDMon HH24:MI:SS')), '08012014 11:44:49');
    set orafce.nls_date_format='YY-MonDD HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('21052014 12:13:44+05:30','DDMMYYYY HH24:MI:SS')), '14-May21 12:13:44');
    set orafce.nls_date_format='DDMMYY HH24:MI:SS';
    SELECT is(oracle.to_char(oracle.to_date('210514 12:13:44+05:30','DDMMYY HH24:MI:SS')), '210514 12:13:44');

    -- Test to_number
    SELECT is(to_number('123'::text), 123::numeric);
    SELECT is(to_number('123.456'::text), 123.456::numeric);
    SELECT is(to_number(123), 123::numeric);
    SELECT is(to_number(123::smallint), 123::numeric);
    SELECT is(to_number(123::int), 123::numeric);
    SELECT is(to_number(123::bigint), 123::numeric);
    SELECT is(to_number(123::numeric), 123::numeric);
    SELECT is(to_number(123.456), 123.456::numeric);
    SELECT is(to_number(1210.73, 9999.99), 1210.73::numeric);
    SELECT is(to_number(1210::smallint, 9999::smallint), 1210::numeric);
    SELECT is(to_number(1210::int, 9999::int), 1210::numeric);
    SELECT is(to_number(1210::bigint, 9999::bigint), 1210::numeric);
    SELECT is(to_number(1210.73::numeric, 9999.99::numeric), 1210.73::numeric);

    -- Tests for to_multi_byte
    SELECT is(to_multi_byte('123$test'), '１２３＄ｔｅｓｔ');
    -- Check internal representation difference
    SELECT is(octet_length('abc'), 3);
    SELECT is(octet_length(to_multi_byte('abc')), 9);

    -- Tests for to_single_byte
    SELECT is(to_single_byte('123$test'), '123$test');
    SELECT is(to_single_byte('１２３＄ｔｅｓｔ'), '123$test');
    -- Check internal representation difference
    SELECT is(octet_length('ａｂｃ'), 9);
    SELECT is(octet_length(to_single_byte('ａｂｃ')), 3);

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;