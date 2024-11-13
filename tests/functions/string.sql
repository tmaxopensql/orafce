-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(82);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    -- Test length 
    SELECT is(oracle.length('あbb'::char(6)), 6);
    SELECT is(oracle.length(''::char(6)), 6);

    -- Test instr
    SELECT is(instr('Tech on the net', 'e'), 2);
    SELECT is(instr('Tech on the net', 'e', 1, 1), 2);
    SELECT is(instr('Tech on the net', 'e', 1, 2), 11);
    SELECT is(instr('Tech on the net', 'e', 1, 3), 14);
    SELECT is(instr('Tech on the net', 'e', -3, 2), 2);
    SELECT is(instr('abc', NULL), NULL);
    SELECT is(1, instr('abc', ''));
    SELECT is(1, instr('abc', 'a'));
    SELECT is(3, instr('abc', 'c'));
    SELECT is(0, instr('abc', 'z'));
    SELECT is(1, instr('abcabcabc', 'abca', 1));
    SELECT is(4, instr('abcabcabc', 'abca', 2));
    SELECT is(0, instr('abcabcabc', 'abca', 7));
    SELECT is(0, instr('abcabcabc', 'abca', 9));
    SELECT is(4, instr('abcabcabc', 'abca', -1));
    SELECT is(1, instr('abcabcabc', 'abca', -8));
    SELECT is(1, instr('abcabcabc', 'abca', -9));
    SELECT is(0, instr('abcabcabc', 'abca', -10));
    SELECT is(1, instr('abcabcabc', 'abca', 1, 1));
    SELECT is(4, instr('abcabcabc', 'abca', 1, 2));
    SELECT is(0, instr('abcabcabc', 'abca', 1, 3));
    SELECT is(0,  instr('ab\;cdx', '\;', 0));

    -- Test substr 
    SELECT is(oracle.substr('This is a test', 6, 2) , 'is');
    SELECT is(oracle.substr('This is a test', 6) ,  'is a test');
    SELECT is(oracle.substr('TechOnTheNet', 1, 4) ,  'Tech');
    SELECT is(oracle.substr('TechOnTheNet', -3, 3) ,  'Net');
    SELECT is(oracle.substr('TechOnTheNet', -6, 3) ,  'The');
    SELECT is(oracle.substr('TechOnTheNet', -8, 2) ,  'On');

    set orafce.using_substring_zero_width_in_substr TO orafce;
    SELECT is(oracle.substr('TechOnTheNet', -8, 0) ,  '');

    set orafce.using_substring_zero_width_in_substr TO oracle;
    SELECT is(oracle.substr('TechOnTheNet', -8, 0), null);

    set orafce.using_substring_zero_width_in_substr TO warning_oracle;
    SELECT is(oracle.substr('TechOnTheNet', -8, 0), null);

    set orafce.using_substring_zero_width_in_substr TO default;
    SELECT is(oracle.substr('TechOnTheNet', -8, 0), null);

    SELECT is(oracle.substr('TechOnTheNet', -8, -1) ,  NULL);
    SELECT is(oracle.substr(1234567,3.6::smallint),'4567');
    SELECT is(oracle.substr(1234567,3.6::int),'4567');
    SELECT is(oracle.substr(1234567,3.6::bigint),'4567');
    SELECT is(oracle.substr(1234567,3.6::numeric),'34567');
    SELECT is(oracle.substr(1234567,-1),'7');
    SELECT is(oracle.substr(1234567,3.6::smallint,2.6),'45');
    SELECT is(oracle.substr(1234567,3.6::smallint,2.6::smallint),'456');
    SELECT is(oracle.substr(1234567,3.6::smallint,2.6::int),'456');
    SELECT is(oracle.substr(1234567,3.6::smallint,2.6::bigint),'456');
    SELECT is(oracle.substr(1234567,3.6::smallint,2.6::numeric),'45');
    SELECT is(oracle.substr(1234567,3.6::int,2.6::smallint),'456');
    SELECT is(oracle.substr(1234567,3.6::int,2.6::int),'456');
    SELECT is(oracle.substr(1234567,3.6::int,2.6::bigint),'456');
    SELECT is(oracle.substr(1234567,3.6::int,2.6::numeric),'45');
    SELECT is(oracle.substr(1234567,3.6::bigint,2.6::smallint),'456');
    SELECT is(oracle.substr(1234567,3.6::bigint,2.6::int),'456');
    SELECT is(oracle.substr(1234567,3.6::bigint,2.6::bigint),'456');
    SELECT is(oracle.substr(1234567,3.6::bigint,2.6::numeric),'45');
    SELECT is(oracle.substr(1234567,3.6::numeric,2.6::smallint),'345');
    SELECT is(oracle.substr(1234567,3.6::numeric,2.6::int),'345');
    SELECT is(oracle.substr(1234567,3.6::numeric,2.6::bigint),'345');
    SELECT is(oracle.substr(1234567,3.6::numeric,2.6::numeric),'34');
    SELECT is(oracle.substr('abcdef'::varchar,3.6::smallint),'def');
    SELECT is(oracle.substr('abcdef'::varchar,3.6::int),'def');
    SELECT is(oracle.substr('abcdef'::varchar,3.6::bigint),'def');
    SELECT is(oracle.substr('abcdef'::varchar,3.6::numeric),'cdef');
    SELECT is(oracle.substr('abcdef'::varchar,3.5::int,3.5::int),'def');
    SELECT is(oracle.substr('abcdef'::varchar,3.5::numeric,3.5::numeric),'cde');
    SELECT is(oracle.substr('abcdef'::varchar,3.5::numeric,3.5::int),'cdef');

    -- Test unistr
    SELECT is(oracle.unistr('\0441\043B\043E\043D'), 'слон');
    SELECT is(oracle.unistr('d\u0061t\U00000061'), 'data');

    -- run-time error
    SELECT throws_ok('SELECT oracle.unistr(''wrong: \db99'');', 'invalid Unicode surrogate pair');
    SELECT throws_ok('SELECT oracle.unistr(''wrong: \db99\0061'');', 'invalid Unicode surrogate pair');
    SELECT throws_ok('SELECT oracle.unistr(''wrong: \+00db99\+000061'');', 'invalid Unicode surrogate pair');
    SELECT throws_ok('SELECT oracle.unistr(''wrong: \+2FFFFF'');', 'invalid Unicode escape value');
    SELECT throws_ok('SELECT oracle.unistr(''wrong: \udb99\u0061'');', 'invalid Unicode surrogate pair');
    SELECT throws_ok('SELECT oracle.unistr(''wrong: \U0000db99\U00000061'');', 'invalid Unicode surrogate pair');
    SELECT throws_ok('SELECT oracle.unistr(''wrong: \U002FFFFF'');', 'invalid Unicode escape value');

    -- Test concat
    SELECT is(concat('Tech on', ' the Net') ,  'Tech on the Net');
    SELECT is(concat('a', 'b') ,  'ab');
    SELECT is(concat('a', NULL) , 'a');
    SELECT is(concat(NULL, 'b') , 'b');
    SELECT is(concat('a', 2) , 'a2');
    SELECT is(concat(1, 'b') , '1b');
    SELECT is(concat(1, 2) , '12');
    SELECT is(concat(1, NULL) , '1');
    SELECT is(concat(NULL, 2) , '2');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;