-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(75);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    -- Test add_months
    SELECT is(add_months(date '2003-08-01', 3), '2003-11-01');
    SELECT is(add_months(date '2003-08-01', -3), '2003-05-01');
    SELECT is(add_months(date '2003-08-21', -3), '2003-05-21');
    SELECT is(add_months(date '2003-01-31', 1), '2003-02-28', 'Test last day of Jan. to Feb.');
    SELECT is(add_months(date '2008-02-28', 1), '2008-03-28', 'Test 28th of Feb. to Mar. in leap year');
    SELECT is(add_months(date '2008-02-29', 1), '2008-03-31', 'Test last day of Feb to Mar. in leap year');
    SELECT is(add_months(date '2008-01-31', 12),'2009-01-31', 'Test adding one year');
    SELECT is(add_months(date '2008-01-31', -12), '2007-01-31', 'Test subtracting one year');
    SELECT is(add_months(date '2008-01-31', 95903), '9999-12-31', 'Test maximum date');
    SELECT is(add_months(date '2008-01-31', -80640), '4712-01-31 BC', 'Text minimum date');

    SELECT is(add_months('2003-08-01 10:12:21', 3), '2003-11-01 10:12:21');
    SELECT is(add_months('2003-08-01 10:21:21', -3), '2003-05-01 10:21:21');
    SELECT is(add_months('2003-08-21 12:21:21', -3), '2003-05-21 12:21:21');
    SELECT is(add_months('2003-01-31 01:12:45', 1), '2003-02-28 01:12:45');
    SELECT is(add_months('2008-02-28 02:12:12', 1), '2008-03-28 02:12:12');
    SELECT is(add_months('2008-02-29 12:12:12', 1), '2008-03-31 12:12:12');
    SELECT is(add_months('2008-01-31 11:11:21', 12), '2009-01-31 11:11:21');
    SELECT is(add_months('2008-01-31 11:21:21', -12),'2007-01-31 11:21:21');
    SELECT is(add_months('2008-01-31 12:12:12', 95903), '9999-12-31 12:12:12');
    SELECT is(add_months('2008-01-31 11:32:12', -80640), '4712-01-31 11:32:12 BC');

    -- Test last_day
    SELECT is(last_day(date '2007-03-01'), '2007-03-31');
    SELECT is(last_day(date '2007-04-01'), '2007-04-30');
    SELECT is(last_day(date '2007-02-01'), '2007-02-28', 'Test non leap year');
    SELECT is(last_day(date '2008-02-01'), '2008-02-29', 'Test leap year');

    SELECT is(last_day('2007-03-01 12:21:33'), '2007-03-31 12:21:33');
    SELECT is(last_day('2007-04-01 12:21:33'), '2007-04-30 12:21:33');
    SELECT is(last_day('2007-02-01 12:21:33'), '2007-02-28 12:21:33');
    SELECT is(last_day('2008-02-01 12:21:33'), '2008-02-29 12:21:33');

    -- Test next_day
    SELECT is(next_day(date '2003-08-06', 'WEDNESDAY'), '2003-08-13');
    SELECT is(next_day(date '2003-08-06', 'SUNDAY'), '2003-08-10');
    SELECT is(next_day(date '2003-08-06', 'sun'), '2003-08-10');
    SELECT is(next_day(date '2003-08-06', 'sunAAA'), '2003-08-10');
    SELECT is(next_day(date '2003-08-06', 3), '2003-08-13');
    SELECT is(next_day(date '2003-08-06', 7), '2003-08-10');

    SELECT is(next_day('2003-08-06 11:22:33', 'WEDNESDAY'), '2003-08-13 11:22:33');
    SELECT is(next_day('2003-08-06 11:22:33', 'SUNDAY'), '2003-08-10 11:22:33');
    SELECT is(next_day('2003-08-06 11:22:33', 'sun'), '2003-08-10 11:22:33');
    SELECT is(next_day('2003-08-06 11:22:33', 'sunAAA'), '2003-08-10 11:22:33');
    SELECT is(next_day('2003-08-06 11:22:33', 3), '2003-08-13 11:22:33');
    SELECT is(next_day('2003-08-06 11:22:33', 7), '2003-08-10 11:22:33');

    -- Test months_between
    SELECT is(months_between(to_date('2003/01/01', 'yyyy/mm/dd'), to_date('2003/03/14', 'yyyy/mm/dd')), -2.41935483870968);
    SELECT is(months_between(to_date('2003/07/01', 'yyyy/mm/dd'), to_date('2003/03/14', 'yyyy/mm/dd')), 3.58064516129032);
    SELECT is(months_between(to_date('2003/07/02', 'yyyy/mm/dd'), to_date('2003/07/02', 'yyyy/mm/dd')), 0::numeric);
    SELECT is(months_between(to_date('2003/08/02', 'yyyy/mm/dd'), to_date('2003/06/02', 'yyyy/mm/dd')), 2::numeric);
    SELECT is(months_between('2007-02-28', '2007-04-30'), -2::numeric);
    SELECT is(months_between('2008-01-31', '2008-02-29'), -1::numeric);
    SELECT is(months_between('2008-02-29', '2008-03-31'), -1::numeric);
    SELECT is(months_between('2008-02-29', '2008-04-30'), -2::numeric);

    SELECT is(months_between(to_date('2003/01/01 12:12:12', 'yyyy/mm/dd h24:mi:ss'), to_date('2003/03/14 11:11:11', 'yyyy/mm/dd h24:mi:ss')), -2.41935483870968);
    SELECT is(months_between(to_date('2003/07/01 10:11:11', 'yyyy/mm/dd h24:mi:ss'), to_date('2003/03/14 10:12:12', 'yyyy/mm/dd h24:mi:ss')), 3.58064516129032);
    SELECT is(months_between(to_date('2003/07/02 11:21:21', 'yyyy/mm/dd h24:mi:ss'), to_date('2003/07/02 11:11:11', 'yyyy/mm/dd h24:mi:ss')), 0::numeric);
    SELECT is(months_between(to_timestamp('2003/08/02 10:11:12', 'yyyy/mm/dd h24:mi:ss'), to_date('2003/06/02 10:10:11', 'yyyy/mm/dd h24:mi:ss')), 2::numeric);
    SELECT is(months_between('2007-02-28 111111', '2007-04-30 112121'), -2::numeric);
    SELECT is(months_between('2008-01-31 11:32:11', '2008-02-29 11:12:12'), -1::numeric);
    SELECT is(months_between('2008-02-29 10:11:13', '2008-03-31 10:12:11'), -1::numeric);
    SELECT is(months_between('2008-02-29 111111', '2008-04-30 12:12:12'), -2::numeric);

    -- Test sys_extract_utc
    SELECT is(sys_extract_utc(timestamptz '2024-08-17 00:41:26.655376+02'), '2024-08-16 22:41:26.655376');

    SET timezone to 'europe/prague';
    SELECT is(sys_extract_utc(oracle.date '2024-08-17 00:41:26.655376'), '2024-08-16 22:41:27');
    SET timezone to default;

    -- Test round
    SELECT is(round(to_date ('22-AUG-03', 'DD-MON-YY'),'YEAR'), to_date ('01-JAN-04', 'DD-MON-YY'));
    SELECT is(round(to_date ('22-AUG-03', 'DD-MON-YY'),'Q'), to_date ('01-OCT-03', 'DD-MON-YY'));
    SELECT is(round(to_date ('22-AUG-03', 'DD-MON-YY'),'MONTH'), to_date ('01-SEP-03', 'DD-MON-YY'));
    SELECT is(round(to_date ('22-AUG-03', 'DD-MON-YY'),'DDD'), to_date ('22-AUG-03', 'DD-MON-YY'));
    SELECT is(round(to_date ('22-AUG-03', 'DD-MON-YY'),'DAY'), to_date ('24-AUG-03', 'DD-MON-YY'));

    -- Test trunc
    SELECT is(trunc(to_date('22-AUG-03', 'DD-MON-YY'), 'YEAR'), to_date ('01-JAN-03', 'DD-MON-YY'));
    SELECT is(trunc(to_date('22-AUG-03', 'DD-MON-YY'), 'Q'), to_date ('01-JUL-03', 'DD-MON-YY'));
    SELECT is(trunc(to_date('22-AUG-03', 'DD-MON-YY'), 'MONTH'), to_date ('01-AUG-03', 'DD-MON-YY'));
    SELECT is(trunc(to_date('22-AUG-03', 'DD-MON-YY'), 'DDD'), to_date ('22-AUG-03', 'DD-MON-YY'));
    SELECT is(trunc(to_date('22-AUG-03', 'DD-MON-YY'), 'DAY'), to_date ('17-AUG-03', 'DD-MON-YY'));

    SELECT is(trunc(TIMESTAMP WITH TIME ZONE '2004-10-19 10:23:54+02','YEAR'), '2004-01-01 00:00:00-08');
    SELECT is(trunc(TIMESTAMP WITH TIME ZONE '2004-10-19 10:23:54+02','Q'), '2004-10-01 00:00:00-07');
    SELECT is(trunc(TIMESTAMP WITH TIME ZONE '2004-10-19 10:23:54+02','MONTH'), '2004-10-01 00:00:00-07');
    SELECT is(trunc(TIMESTAMP WITH TIME ZONE '2004-10-19 10:23:54+02','DDD'), '2004-10-19 00:00:00-07');
    SELECT is(trunc(TIMESTAMP WITH TIME ZONE '2004-10-19 10:23:54+02','DAY'), '2004-10-17 00:00:00-07');
    SELECT is(trunc(TIMESTAMP WITH TIME ZONE '2004-10-19 10:23:54+02','HH'), '2004-10-19 01:00:00-07');
    SELECT is(trunc(TIMESTAMP WITH TIME ZONE '2004-10-19 10:23:54+02','MI'), '2004-10-19 01:23:00-07');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;