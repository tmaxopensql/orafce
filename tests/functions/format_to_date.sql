-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(107);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    SET DATESTYLE TO SQL, MDY;
    SELECT is(to_date('2009-01-02'), '01/02/2009 00:00:00');
    SELECT is(to_date('January 8,1999'), '01/08/1999 00:00:00');
    SET DATESTYLE TO POSTGRES, MDY;
    SELECT is(to_date('1999-01-08'), 'Fri Jan 08 00:00:00 1999');
    SELECT is(to_date('1/12/1999'), 'Tue Jan 12 00:00:00 1999');
    SET DATESTYLE TO SQL, DMY;
    SELECT is(to_date('01/02/03'), '01/02/2003 00:00:00');
    SELECT is(to_date('1999-Jan-08'), '08/01/1999 00:00:00');
    SELECT is(to_date('Jan-08-1999'), '08/01/1999 00:00:00');
    SELECT is(to_date('08-Jan-1999'), '08/01/1999 00:00:00');
    SET DATESTYLE TO ISO, YMD;
    SELECT is(to_date('99-Jan-08'), '1999-01-08 00:00:00');
    SET DATESTYLE TO ISO, DMY;
    SELECT is(to_date('08-Jan-99'), '1999-01-08 00:00:00');
    SELECT is(to_date('Jan-08-99'), '1999-01-08 00:00:00');
    SELECT is(to_date('19990108'), '1999-01-08 00:00:00');
    SELECT is(to_date('990108'), '1999-01-08 00:00:00');
    SELECT is(to_date('J2451187'), '1999-01-08 00:00:00');
    set orafce.nls_date_format='YY-MonDD HH24:MI:SS';
    SELECT is(to_date('14-Jan08 11:44:49+05:30'), '2014-01-08 11:44:49');
    set orafce.nls_date_format='YY-DDMon HH24:MI:SS';
    SELECT is(to_date('14-08Jan 11:44:49+05:30'), '2014-01-08 11:44:49');
    set orafce.nls_date_format='DDMMYYYY HH24:MI:SS';
    SELECT is(to_date('21052014 12:13:44+05:30'), '2014-05-21 12:13:44');
    set orafce.nls_date_format='DDMMYY HH24:MI:SS';
    SELECT is(to_date('210514 12:13:44+05:30'), '2014-05-21 12:13:44');
    set orafce.nls_date_format='DDMMYY HH24:MI:SS.MS';
    SELECT is(oracle.orafce__obsolete_to_date('210514 12:13:44.55'), '2014-05-21 12:13:44.55');
    SELECT is(oracle.to_date('210514 12:13:44.55'), '2014-05-21 12:13:45');

    -- Tests for oracle.to_date(text,text)
    SET search_path TO oracle,"$user", public, pg_catalog;
    SELECT is(to_date('2014/04/25 10:13', 'YYYY/MM/DD HH:MI'), '2014-04-25 10:13:00');
    SELECT is(to_date('16-Feb-09 10:11:11', 'DD-Mon-YY HH:MI:SS'), '2009-02-16 10:11:11');
    SELECT is(to_date('02/16/09 04:12:12', 'MM/DD/YY HH24:MI:SS'), '2009-02-16 04:12:12');
    SELECT is(to_date('021609 111213', 'MMDDYY HHMISS'), '2009-02-16 11:12:13');
    SELECT is(to_date('16-Feb-09 11:12:12', 'DD-Mon-YY HH:MI:SS'), '2009-02-16 11:12:12');
    SELECT is(to_date('Feb/16/09 11:21:23', 'Mon/DD/YY HH:MI:SS'), '2009-02-16 11:21:23');
    SELECT is(to_date('February.16.2009 10:11:12', 'Month.DD.YYYY HH:MI:SS'), '2009-02-16 10:11:12');
    SELECT is(to_date('20020315111212', 'yyyymmddhh12miss'), '2002-03-15 11:12:12');
    SELECT is(to_date('January 15, 1989, 11:00 A.M.','Month dd, YYYY, HH:MI A.M.'), '1989-01-15 11:00:00');
    SELECT is(to_date('14-Jan08 11:44:49+05:30' ,'YY-MonDD HH24:MI:SS'), '2014-01-08 11:44:49');
    SELECT is(to_date('14-08Jan 11:44:49+05:30','YY-DDMon HH24:MI:SS'), '2014-01-08 11:44:49');
    SELECT is(to_date('21052014 12:13:44+05:30','DDMMYYYY HH24:MI:SS'), '2014-05-21 12:13:44');
    SELECT is(to_date('210514 12:13:44+05:30','DDMMYY HH24:MI:SS'), '2014-05-21 12:13:44');

    -- Tests for + operator with DATE and number(smallint,integer,bigint,numeric)
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') + 9::smallint, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') + 9::smallint, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') + 9::smallint, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') + 9, '2014-07-11 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') + 9::smallint, '2014-07-11 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') + 9::smallint, '2014-07-11 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') + 9::smallint, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') + 9::bigint, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') + 9::bigint, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') + 9::bigint, '2014-07-11 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') + 9::bigint, '2014-07-11 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') + 9::bigint, '2014-07-11 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') + 9::bigint, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') + 9::integer, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') + 9::integer, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') + 9::integer, '2014-07-11 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') + 9::integer, '2014-07-11 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') + 9::integer, '2014-07-11 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') + 9::integer, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') + 9::numeric, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') + 9::numeric, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') + 9::numeric, '2014-07-11 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') + 9::numeric, '2014-07-11 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') + 9::numeric, '2014-07-11 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') + 9::numeric, '2014-07-11 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-01-01 00:00:00') + 1.5, '2014-01-02 12:00:00');
    SELECT is(to_date('2014-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss') + 1.5, '2014-01-02 12:00:00');

    -- Tests for - operator with DATE and number(smallint,integer,bigint,numeric)
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') - 9::smallint, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') - 9::smallint, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') - 9::smallint, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') - 9, '2014-06-23 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') - 9::smallint, '2014-06-23 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') - 9::smallint, '2014-06-23 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') - 9::smallint, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') - 9::bigint, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') - 9::bigint, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') - 9::bigint, '2014-06-23 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') - 9::bigint, '2014-06-23 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') - 9::bigint, '2014-06-23 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') - 9::bigint, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') - 9::integer, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') - 9::integer, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') - 9::integer, '2014-06-23 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') - 9::integer, '2014-06-23 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') - 9::integer, '2014-06-23 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') - 9::integer, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-07-02 10:08:55') - 9::numeric, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='MM-DD-YYYY HH24:MI:SS';
    SELECT is(to_date('07-02-2014 10:08:55') - 9::numeric, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='DD-MM-YYYY HH24:MI:SS';
    SELECT is(to_date('02-07-2014 10:08:55') - 9::numeric, '2014-06-23 10:08:55');
    SELECT is(to_date('2014-07-02 10:08:55','YYYY-MM-DD HH:MI:SS') - 9::numeric, '2014-06-23 10:08:55');
    SELECT is(to_date('02-07-2014 10:08:55','DD-MM-YYYY HH:MI:SS') - 9::numeric, '2014-06-23 10:08:55');
    SELECT is(to_date('07-02-2014 10:08:55','MM-DD-YYYY HH:MI:SS') - 9::numeric, '2014-06-23 10:08:55');
    SET orafce.nls_date_format='YYYY-MM-DD HH24:MI:SS';
    SELECT is(to_date('2014-01-01 00:00:00') - 1.5, '2013-12-30 12:00:00');
    SELECT is(to_date('2014-01-01 00:00:00','yyyy-mm-dd hh24:mi:ss') - 1.5, '2013-12-30 12:00:00');

    SELECT is(oracle.to_date('', 'yyyy-mm-dd'), NULL);
    
    SELECT throws_ok(
        'SELECT oracle.to_date(''112012'', ''J'');',
        'Dates before 1582-10-05 (''J2299159'') cannot be verified due to a bug in Oracle.'
    );
    SELECT throws_ok(
        'SELECT oracle.to_date(''1003-03-15'', ''yyyy-mm-dd'');',
        'Dates before 1100-03-01 cannot be verified due to a bug in Oracle.'
    );

    SET orafce.oracle_compatibility_date_limit TO off;
    SELECT is(oracle.to_date('112012', 'J'), '4407-07-30 00:00:00 BC');
    SELECT is(oracle.to_date('1003/03/15', 'yyyy/mm/dd'), '1003-03-15 00:00:00');

    --Tests for oracle.-(oracle.date,oracle.date)
    SELECT is((to_date('2014-07-17 11:10:15', 'yyyy-mm-dd hh24:mi:ss') - to_date('2014-02-01 10:00:00', 'yyyy-mm-dd hh24:mi:ss'))::numeric(10,4), 166.0488::numeric);
    SELECT is((to_date('2014-07-17 13:14:15', 'yyyy-mm-dd hh24:mi:ss') - to_date('2014-02-01 10:00:00', 'yyyy-mm-dd hh24:mi:ss'))::numeric(10,4), 166.1349::numeric);
    SELECT is((to_date('07-17-2014 13:14:15', 'mm-dd-yyyy hh24:mi:ss') - to_date('2014-02-01 10:00:00', 'yyyy-mm-dd hh24:mi:ss'))::numeric(10,4), 166.1349::numeric);
    SELECT is((to_date('07-17-2014 13:14:15', 'mm-dd-yyyy hh24:mi:ss') - to_date('2015-02-01 10:00:00', 'yyyy-mm-dd hh24:mi:ss'))::numeric(10,4), -198.8651::numeric);
    SELECT is((to_date('07-17-2014 13:14:15', 'mm-dd-yyyy hh24:mi:ss') - to_date('01-01-2013 10:00:00', 'mm-dd-yyyy hh24:mi:ss'))::numeric(10,4), 562.1349::numeric);
    SELECT is((to_date('17-07-2014 13:14:15', 'dd-mm-yyyy hh24:mi:ss') - to_date('01-01-2013 10:00:00', 'dd--mm-yyyy hh24:mi:ss'))::numeric(10,4), 562.1349::numeric);
    SELECT is((to_date('2014/02/01 10:11:12', 'YYYY/MM/DD hh12:mi:ss') - to_date('2013/02/01 10:11:12', 'YYYY/MM/DD hh12:mi:ss'))::numeric(10,4), 365.0000::numeric);
    SELECT is((to_date('17-Jul-14 10:11:11', 'DD-Mon-YY HH:MI:SS') - to_date('17-Jan-14 00:00:00', 'DD-Mon-YY HH24:MI:SS'))::numeric(10,4), 181.4244::numeric);
    SELECT is((to_date('July.17.2014 10:11:12', 'Month.DD.YYYY HH:MI:SS') - to_date('February.16.2014 10:21:12', 'Month.DD.YYYY HH:MI:SS'))::numeric(10,4), 150.9931::numeric);
    SELECT is((to_date('20140717111211', 'yyyymmddhh12miss') - to_date('20140315111212', 'yyyymmddhh12miss'))::numeric(10,4), 124.0000::numeric);
    SELECT is((to_date('January 15, 1990, 11:00 A.M.','Month dd, YYYY, HH:MI A.M.') - to_date('January 15, 1989, 10:00 A.M.','Month dd, YYYY, HH:MI A.M.'))::numeric(10,4), 365.0417::numeric);
    SELECT is((to_date('14-Jul14 11:44:49' ,'YY-MonDD HH24:MI:SS') - to_date('14-Jan14 12:44:49' ,'YY-MonDD HH24:MI:SS'))::numeric(10,4), 180.9583::numeric);
    SELECT is((to_date('210514 12:13:44','DDMMYY HH24:MI:SS') - to_date('210114 10:13:44','DDMMYY HH24:MI:SS'))::numeric(10,4), 120.0833::numeric);
    SELECT is(trunc((to_date('210514 12:13:44','DDMMYY HH24:MI:SS'))), '2014-05-21 00:00:00');
    SELECT is(round((to_date('210514 12:13:44','DDMMYY HH24:MI:SS'))), '2014-05-22 00:00:00');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;