-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(146);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    SELECT is(oracle.REGEXP_LIKE('a'||CHR(10)||'d', 'a.d'), false);
    SELECT is(oracle.REGEXP_LIKE('a'||CHR(10)||'d', 'a.d', 'm'), false);
    SELECT is(oracle.REGEXP_LIKE('a'||CHR(10)||'d', 'a.d', 'n'), true);
    SELECT is(oracle.REGEXP_LIKE('Steven', '^Ste(v|ph)en$'), true);
    SELECT is(oracle.REGEXP_LIKE('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '^bar'), false);
    SELECT is(oracle.REGEXP_LIKE('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', 'bar'), true);
    SELECT is(oracle.REGEXP_LIKE('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '^bar', 'm'), true);
    SELECT is(oracle.REGEXP_LIKE('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '^bar', 'n'), false);
    SELECT is(oracle.REGEXP_LIKE('GREEN', '([aeiou])\1'), false);
    SELECT is(oracle.REGEXP_LIKE('GREEN', '([aeiou])\1', 'i'), true);
    SELECT is(oracle.REGEXP_LIKE('ORANGE' || chr(10) || 'GREEN', '([aeiou])\1', 'i'), true);
    SELECT is(oracle.REGEXP_LIKE('ORANGE' || chr(10) || 'GREEN', '^..([aeiou])\1', 'i'), false);
    SELECT is(oracle.REGEXP_LIKE('ORANGE' || chr(10) || 'GREEN', '([aeiou])\1', 'in'), true);
    SELECT is(oracle.REGEXP_LIKE('ORANGE' || chr(10) || 'GREEN', '^..([aeiou])\1', 'in'), false);
    SELECT is(oracle.REGEXP_LIKE('ORANGE' || chr(10) || 'GREEN', '^..([aeiou])\1', 'im'), true);

    ----
    -- Tests for oracle.REGEXP_COUNT()
    ----

    SELECT is(oracle.REGEXP_COUNT('a,b' || chr(10) || 'c','[^,]+'), 2);
    SELECT is(oracle.REGEXP_COUNT('a,b' || chr(10) || 'c','b.c'), 0);
    SELECT is(oracle.REGEXP_COUNT('a'||CHR(10)||'d', 'a.d'), 0);
    SELECT is(oracle.REGEXP_COUNT('a'||CHR(10)||'d', 'a.d', 1, 'm'), 0);
    SELECT is(oracle.REGEXP_COUNT('a'||CHR(10)||'d', 'a.d', 1, 'n'), 1);
    SELECT is(oracle.REGEXP_COUNT('Steven', '^Ste(v|ph)en$'), 1);
    SELECT is(oracle.REGEXP_COUNT('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '^bar'), 0);
    SELECT is(oracle.REGEXP_COUNT('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', 'bar'), 1);
    SELECT throws_ok(
        'SELECT oracle.REGEXP_COUNT(''foo'' || chr(10) || ''bar'' || chr(10) || ''bequq'' || chr(10) || ''baz'', ''^bar'', 0, ''m'')',
        'argument ''position'' must be a number greater than 0',
        'Check negatives values that must throw an error'
    );
    SELECT is(oracle.REGEXP_COUNT('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '^bar', 1, 'm'), 1);
    SELECT is(oracle.REGEXP_COUNT('foo' || chr(10) || 'bar' || chr(10) || 'bequq' || chr(10) || 'baz', '^bar', 1, 'n'), 0);
    SELECT is(oracle.REGEXP_COUNT('GREEN', '([aeiou])\1'), 0);
    SELECT is(oracle.REGEXP_COUNT('GREEN', '([aeiou])\1', 1, 'i'), 1);
    SELECT is(oracle.REGEXP_COUNT('ORANGE' || chr(10) || 'GREEN', '([aeiou])\1', 1, 'i'), 1);
    SELECT is(oracle.REGEXP_COUNT('ORANGE' || chr(10) || 'GREEN', '^..([aeiou])\1', 1, 'i'), 0);
    SELECT is(oracle.REGEXP_COUNT('ORANGE' || chr(10) || 'GREEN', '([aeiou])\1', 1, 'in'), 1);
    SELECT is(oracle.REGEXP_COUNT('ORANGE' || chr(10) || 'GREEN', '^..([aeiou])\1', 1, 'in'), 0);
    SELECT is(oracle.REGEXP_COUNT('ORANGE' || chr(10) || 'GREEN', '^..([aeiou])\1', 1, 'im'), 1);
    SELECT is(oracle.REGEXP_COUNT('123123123123123', '(12)3', 1, 'i'), 5);
    SELECT is(oracle.REGEXP_COUNT('123123123123', '123', 3, 'i'), 3);
    SELECT is(oracle.REGEXP_COUNT('ABC123', '[A-Z]'), 3);
    SELECT is(oracle.REGEXP_COUNT('A1B2C3', '[A-Z]'), 3);
    SELECT is(oracle.REGEXP_COUNT('ABC123', '[A-Z][0-9]'), 1);
    SELECT is(oracle.REGEXP_COUNT('A1B2C3', '[A-Z][0-9]'), 3);
    SELECT is(oracle.REGEXP_COUNT('ABC123', '^[A-Z][0-9]'), 0);
    SELECT is(oracle.REGEXP_COUNT('A1B2C3', '^[A-Z][0-9]'), 1);
    SELECT is(oracle.REGEXP_COUNT('ABC123', '([A-Z][0-9]){2}'), 0);
    SELECT is(oracle.REGEXP_COUNT('A1B2C3', '([A-Z][0-9]){2}'), 1);
    SELECT throws_ok(
        'SELECT oracle.REGEXP_COUNT(''ORANGE'' || chr(10) || ''GREEN'', ''^..([aeiou])\1'', -1, ''i'');',
        'argument ''position'' must be a number greater than 0',
        'Check negatives values that must throw an error'
    );

    ----
    -- Tests for oracle.REGEXP_INSTR()
    ----

    SELECT is(oracle.REGEXP_INSTR('1234567890', '(123)(4(56)(78))'), 1);
    SELECT is(oracle.REGEXP_INSTR('1234567890', '(4(56)(78))'), 4);
    SELECT is(oracle.REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 3), 0);
    SELECT is(oracle.REGEXP_INSTR('1234567890', '(4(56)(78))', 3), 4);
    SELECT is(oracle.REGEXP_INSTR('500 Parkway, Redwood Shores, CA', '[^ ]+', 1, 6), 37);
    SELECT is(oracle.REGEXP_INSTR('500 Parkway, Redwood Shores, CA', '[S|R|P][[:alpha:]]{6}', 3, 2, 0), 21);
    SELECT is(oracle.REGEXP_INSTR('500 Parkway, Redwood Shores, CA', '[S|R|P][[:alpha:]]{6}', 3, 2, 1), 28);
    SELECT is(oracle.REGEXP_INSTR('500 Parkway, Redwood Shores, CA', '[q|r|p][[:alpha:]]{6}', 3, 2, 1, 'i'), 28);
    SELECT is(oracle.REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 0), 1);
    SELECT is(oracle.REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 1), 1);
    SELECT is(oracle.REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 2), 4);
    SELECT is(oracle.REGEXP_INSTR('1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 4), 7);
    SELECT is(oracle.REGEXP_INSTR('1234567890 1234567890', '(123)(4(56)(78))', 1, 1, 0, 'i', 4), 7);
    SELECT is(oracle.REGEXP_INSTR('1234567890 1234567890', '(123)(4(56)(78))', 1, 2, 0, 'i', 4), 18);
    SELECT is(oracle.REGEXP_INSTR('1234567890 1234567890', '(123)(4(56)(78))', 1, 2, 1, 'i', 4), 20);
    SELECT is(oracle.REGEXP_INSTR('1234567890 1234567890 1234567890', '(123)(4(56)(78))', 1, 3, 0, 'i', 4), 29);
    SELECT is(oracle.REGEXP_INSTR('1234567890 1234567890 1234567890', '(123)(4(56)(78))', 1, 3, 1, 'i', 4), 31);

    -- Check negatives values that must throw an error
    SELECT throws_ok(
        'SELECT oracle.REGEXP_INSTR(''1234567890 1234567890 1234567890'', ''(123)(4(56)(78))'', -1, 3, 1, ''i'', 4)', 
        'argument ''position'' must be a number greater than 0',
        'Check negatives values that must throw an error'
    );
    SELECT throws_ok(
        'SELECT oracle.REGEXP_INSTR(''1234567890 1234567890 1234567890'', ''(123)(4(56)(78))'', 1, -3, 1, ''i'', 4)', 
        'argument ''occurence'' must be a number greater than 0',
        'Check negatives values that must throw an error'
    );
    SELECT throws_ok(
        'SELECT oracle.REGEXP_INSTR(''1234567890 1234567890 1234567890'', ''(123)(4(56)(78))'', 1, 3, -1, ''i'', 4)', 
        'argument ''return_opt'' must be 0 or 1',
        'Check negatives values that must throw an error'
    );
    SELECT throws_ok(
        'SELECT oracle.REGEXP_INSTR(''1234567890 1234567890 1234567890'', ''(123)(4(56)(78))'', 1, 3, 1, ''i'', -4)', 
        'argument ''group'' must be a positive number',
        'Check negatives values that must throw an error'
    );

    SELECT is(oracle.REGEXP_INSTR('123 123456 1234567, 1234567 1234567 12', '[^ ]+', 1, 6) , 37);
    SELECT is(oracle.REGEXP_INSTR('123 123456 1234567, 1234567 1234567 12', '[^ ]+', 1, 6, 1) , 39);
    SELECT is(oracle.REGEXP_INSTR('123 123456 1234567, 1234567 1234567 12', '[^ ]+', 1, 6, 1, 'i') , 39);

    ----
    -- Tests for oracle.REGEXP_SUBSTR()
    ----

    SELECT is(oracle.REGEXP_SUBSTR('a,b'||chr(10)||'c','[^,]+',1,2), 'b'||chr(10)||'c');
    SELECT is(oracle.REGEXP_SUBSTR('a,b'||chr(10)||'c','.',1,4), 'c');
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',[^,]+'), ', zipcode town');
    SELECT is(oracle.REGEXP_SUBSTR('http://www.example.com/products', 'http://([[:alnum:]]+\.?){3,4}/?'), 'http://www.example.com/');
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',[^,]+', 24), ', FR');
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',[^,]+', 1, 1), ', zipcode town');
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',[^,]+', 1, 2), ', FR');
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',\s+[Zf][^,]+', 1, 1), NULL);
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',\s+[Zf][^,]+', 1, 1, 'i'), ', zipcode town');
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',\s+[Zf][^,]+', 1, 1, 'i', 0), ', zipcode town');
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',\s+[Zf][^,]+', 1, 1, 'i', 1), NULL);
    SELECT is(oracle.REGEXP_SUBSTR('number of your street, zipcode town, FR', ',\s+([Zf][^,]+)', 1, 1, 'i', 1), 'zipcode town');
    SELECT is(oracle.REGEXP_SUBSTR('1234567890 1234567890', '(123)(4(56)(78))', 1, 1, 'i', 4), '78');
    SELECT is(oracle.REGEXP_SUBSTR('1234567890 1234557890', '(123)(4(5[56])(78))', 1, 2, 'i', 3), '55');
    SELECT is(oracle.REGEXP_SUBSTR('1234567890 1234567890', '(123)(4(56)(78))', 1, 1, 'i', 0), '12345678');
    -- Check negatives values that must throw an error
    SELECT throws_ok(
        'SELECT oracle.REGEXP_SUBSTR(''1234567890 1234567890'', ''(123)(4(56)(78))'', -1, 1, ''i'', 0);',
        'argument ''position'' must be a number greater than 0',
        'Check negatives values that must throw an error'
    );
    SELECT throws_ok(
        'SELECT oracle.REGEXP_SUBSTR(''1234567890 1234567890'', ''(123)(4(56)(78))'', 1, -1, ''i'', 0);',
        'argument ''occurence'' must be a number greater than 0',
        'Check negatives values that must throw an error'
    );
    SELECT throws_ok(
        'SELECT oracle.REGEXP_SUBSTR(''1234567890 1234567890'', ''(123)(4(56)(78))'', 1, 1, ''i'', -1);', 
        'argument ''group'' must be a positive number',
        'Check negatives values that must throw an error'
    );
    ----
    -- Tests for oracle.REGEXP_REPLACE()
    ----

    SELECT is(oracle.REGEXP_REPLACE('512.123.4567', '([[:digit:]]{3})\.([[:digit:]]{3})\.([[:digit:]]{4})', '(\1) \2-\3'), '(512) 123-4567');
    SELECT is(oracle.REGEXP_REPLACE('512.123.4567 612.123.4567', '([[:digit:]]{3})\.([[:digit:]]{3})\.([[:digit:]]{4})', '(\1) \2-\3'), '(512) 123-4567 (612) 123-4567');
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,    zipcode  town, FR', '( ){2,}', ' '), 'number your street, zipcode town, FR');
    -- zipcode town, FR
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,'||CHR(10)||'    zipcode  town, FR', '( ){2,}', ' '), 'number your street,'|| chr(10)|| ' zipcode town, FR');
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,    zipcode  town, FR', '( ){2,}', ' ', 9), 'number   your street, zipcode town, FR');
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,    zipcode  town, FR', '( ){2,}', ' ', 9, 0), 'number   your street, zipcode town, FR');
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,    zipcode  town, FR', '( ){2,}', ' ', 9, 2), 'number   your     street, zipcode  town, FR');
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,    zipcode  town, FR', '( ){2,}', ' ', 9, 2, 'm'), 'number   your     street, zipcode  town, FR');
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,    zipcode  town, FR', '([EURT]){2,}', '[\1]', 9, 2, 'i'), 'number   your     s[t],    zipcode  town, FR');
    SELECT is(oracle.REGEXP_REPLACE('number   your     street,    zipcode  town, FR', '( ){2,}', ' ', 9, 2), 'number   your     street, zipcode  town, FR');

    SELECT is(oracle.REGEXP_REPLACE('A PostgreSQL function', 'A|e|i|o|u', 'X', 1, 2), 'A PXstgreSQL function');
    SELECT is(oracle.REGEXP_REPLACE('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 0, 'i'), 'X PXstgrXSQL fXnctXXn');
    SELECT is(oracle.REGEXP_REPLACE('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 1, 'i'), 'X PostgreSQL function');
    SELECT is(oracle.REGEXP_REPLACE('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 2, 'i'), 'A PXstgreSQL function');
    SELECT is(oracle.REGEXP_REPLACE('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 3, 'i'), 'A PostgrXSQL function');
    SELECT is(oracle.REGEXP_REPLACE('A PostgreSQL function', 'a|e|i|o|u', 'X', 1, 9, 'i'), 'A PostgreSQL function');
    SELECT is(oracle.REGEXP_REPLACE('A PostgreSQL function', 'A|e|i|o|u', 'X', 1, 9), 'A PostgreSQL function');
    SELECT throws_ok(
        'SELECT oracle.REGEXP_REPLACE(''A PostgreSQL function'', ''a|e|i|o|u'', ''X'', -1, 1, ''i'');', 
        'argument ''position'' must be a number greater than 0',
        'Check negatives values that must throw an error'
    );
     SELECT throws_ok(
        'SELECT oracle.REGEXP_REPLACE(''A PostgreSQL function'', ''a|e|i|o|u'', ''X'', 1, -1, ''i'');', 
        'argument ''occurrence'' must be a positive number',
        'Check negatives values that must throw an error'
    );
      SELECT throws_ok(
        'SELECT oracle.REGEXP_REPLACE(''A PostgreSQL function'', ''a|e|i|o|u'', ''X'', 1, 1, ''g'');', 
        'modifier ''g'' is not supported by this function',
        'Check unsported modifier'
    );
   
    --
    -- Test NULL input in the regexp_* functions that must returned NULL except for the modifier
    -- or regexp flag. There is an exception with regexp_replace(), if the pattern is null (second
    -- parameter) the original string is returned. We don't test functions witht the STRICT attribute
    --
    SELECT is(oracle.REGEXP_LIKE(NULL, '\d+', 'i'), NULL);
    SELECT is(oracle.REGEXP_LIKE('1234', NULL, 'i'), NULL);
    SELECT is(oracle.REGEXP_LIKE('1234', '\d+', NULL), true);
    SELECT is(oracle.REGEXP_LIKE('1234', '\d+', ''), true);
    SELECT is(oracle.REGEXP_COUNT('1234', '\d', NULL), NULL);
    SELECT is(oracle.REGEXP_COUNT('1234', '\d', 1, NULL), 4);
    SELECT is(oracle.REGEXP_COUNT('1234', '\d', 1, ''), 4);
    SELECT is(oracle.REGEXP_COUNT('1234', '\d', NULL, NULL), NULL);
    SELECT is(oracle.REGEXP_COUNT(NULL, '4', 1, 'i'), NULL);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', NULL), NULL);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', 1, NULL), NULL);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', 1, 1, NULL), NULL);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', 1, 1, 1, NULL), 5);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', 1, 1, 1, NULL, 0), 5);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', 1, 1, 0, NULL), 4);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', 1, 1, 0, 'i', NULL), NULL);
    SELECT is(oracle.REGEXP_INSTR('1234', '4', 1, 1, 0, '', NULL), NULL);
    SELECT is(oracle.REGEXP_INSTR(NULL, '4', 1, 1, 0, 'i', 2), NULL);
    SELECT is(oracle.REGEXP_INSTR(NULL, '4', 1, 1, 0, 'i', 2), NULL);
    SELECT is(oracle.REGEXP_SUBSTR('1234', '1(.*)', null), NULL);
    SELECT is(oracle.REGEXP_SUBSTR('1234', '234', 1, null), NULL);
    SELECT is(oracle.REGEXP_SUBSTR('1234', '234', 1, 1, null), '234');
    SELECT is(oracle.REGEXP_SUBSTR('1234', '234', 1, 1, ''), '234');
    SELECT is(oracle.REGEXP_SUBSTR('1234', '234', 1, 1, 'i', null), NULL);
    -- test for capture group
    SELECT is(oracle.REGEXP_SUBSTR('1234', '2(3)(4)', 1, 1, 'i', 1), '3');
    SELECT is(oracle.REGEXP_SUBSTR('1234', '2(3)(4)', 1, 1, 'i', 2), '4');
    SELECT is(oracle.REGEXP_SUBSTR('1234', '2(3)(4)', 1, 1, 'i', 0), '234');

    SELECT is(oracle.REGEXP_REPLACE(null, '\d', 'a'), NULL);
    SELECT is(oracle.REGEXP_REPLACE('1234', null, 'a'), '1234');
    SELECT is(oracle.REGEXP_REPLACE('1234', null, null), '1234');
    SELECT is(oracle.REGEXP_REPLACE('1234', '\d', null), NULL);
    SELECT is(oracle.REGEXP_REPLACE('1234', '\d', 'a', null), NULL);
    SELECT is(oracle.REGEXP_REPLACE('1234', null, 'a', 2), '1234');
    SELECT is(oracle.REGEXP_REPLACE('1234', null, 'a', null), NULL);
    SELECT is(oracle.REGEXP_REPLACE('1234', null, 'a', 1), '1234');
    SELECT is(oracle.REGEXP_REPLACE('1234', null, 'a', 1, null), NULL);
    SELECT is(oracle.REGEXP_REPLACE('1234', '\d', 'a', 1, null), NULL);
    SELECT is(oracle.REGEXP_REPLACE('1234', '\d', 'a', 1, 1, null), 'a234');
    SELECT is(oracle.REGEXP_REPLACE('1234', '\d', 'a', 1, NULL, 'i'), NULL);
    SELECT is(oracle.REGEXP_REPLACE('1234', null, 'a', 1, 1, 'i'), '1234');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;
