-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(1);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    select PLVstr.betwn('Harry and Sally are very happy', 7, 9);
    select PLVstr.betwn('Harry and Sally are very happy', 7, 9, FALSE);
    select PLVstr.betwn('Harry and Sally are very happy', -3, -1);
    select PLVstr.betwn('Harry and Sally are very happy', 'a', 'ry');
    select PLVstr.betwn('Harry and Sally are very happy', 'a', 'ry', 1,1,FALSE,FALSE);
    select PLVstr.betwn('Harry and Sally are very happy', 'a', 'ry', 2,1,TRUE,FALSE);
    select PLVstr.betwn('Harry and Sally are very happy', 'a', 'y', 2,1);
    select PLVstr.betwn('Harry and Sally are very happy', 'a', 'a', 2, 2);
    select PLVstr.betwn('Harry and Sally are very happy', 'a', 'a', 2, 3, FALSE,FALSE);

    select plvsubst.string('My name is %s %s.', ARRAY['Pavel','Stěhule']);
    select plvsubst.string('My name is % %.', ARRAY['Pavel','Stěhule'], '%');
    select plvsubst.string('My name is %s.', ARRAY['Stěhule']);
    select plvsubst.string('My name is %s %s.', 'Pavel,Stěhule');
    select plvsubst.string('My name is %s %s.', 'Pavel|Stěhule','|');
    select plvsubst.string('My name is %s.', 'Stěhule');
    select plvsubst.string('My name is %s.', '');
    select plvsubst.string('My name is empty.', '');

    select PLVstr.rvrs ('Jumping Jack Flash') ='hsalF kcaJ gnipmuJ';
    select PLVstr.rvrs ('Jumping Jack Flash', 9) = 'hsalF kcaJ';
    select PLVstr.rvrs ('Jumping Jack Flash', 4, 6) = 'nip';
    select PLVstr.rvrs (NULL, 10, 20);
    select PLVstr.rvrs ('alphabet', -2, -5);
    select PLVstr.rvrs ('alphabet', -2);
    select PLVstr.rvrs ('alphabet', 2, 200);
    select PLVstr.rvrs ('alphabet', 20, 200);
    select PLVstr.lstrip ('*val1|val2|val3|*', '*') = 'val1|val2|val3|*';
    select PLVstr.lstrip (',,,val1,val2,val3,', ',', 3)= 'val1,val2,val3,';
    select PLVstr.lstrip ('WHERE WHITE = ''FRONT'' AND COMP# = 1500', 'WHERE ') = 'WHITE = ''FRONT'' AND COMP# = 1500';
    select plvstr.left('Příliš žluťoučký kůň',4) = pg_catalog.substr('Příl', 1, 4);

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;