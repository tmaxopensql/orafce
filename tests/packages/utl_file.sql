-- Start transaction and plan the tests.
BEGIN;

    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS pgtap;
    CREATE EXTENSION IF NOT EXISTS orafce;

    -- Plan the number of tests to execute
    SELECT PLAN(17);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    SELECT has_relation('utl_file', 'utl_file_dir', 'Test utl_file_dir is created');
    SELECT has_type('utl_file', 'file_type', 'Test file_type is created');

    SELECT throws_ok(
        $$SELECT utl_file.fopen(utl_file.tmpdir(), 'sample.txt', 'r');$$,
        'UTL_FILE_INVALID_PATH',
        'Error when accessing a file in an unregistered path'
    );

    INSERT INTO utl_file.utl_file_dir(dir) VALUES('test_tmp_dir');
    SELECT throws_ok(
        $$SELECT utl_file.fopen('test_tmp_dir', 'file.txt.','w');$$,
        'UTL_FILE_INVALID_PATH',
        'Error when accessing a file in a directory that does not exist'
    );

    DELETE FROM utl_file.utl_file_dir WHERE dir like 'test_tmp_dir';
    SELECT lives_ok(
        $$INSERT INTO utl_file.utl_file_dir(dir, dirname) VALUES (utl_file.tmpdir(), 'TMPDIR');$$,
        'Test utl_file.tmpdir()'
    );

    SELECT throws_ok(
        $$SELECT utl_file.fopen(utl_file.tmpdir(), 'invalid_file_name.txt', 'r');$$,
        'UTL_FILE_INVALID_PATH',
        'Error when accessing a file that does not exist'
    );

    DO
    $$
    DECLARE
        ftest utl_file.file_type;
        pgtap_ok text; -- dummy return for pgtap to work inside anon block
    BEGIN
        ftest := utl_file.fopen('TMPDIR', 'test.txt', 'w');

        -- Put a line into a txt file
        PERFORM utl_file.put_line(ftest, '1234567890');

        -- Put numeric into a txt file
        PERFORM utl_file.put_line(ftest, 1234567890::numeric);
        
        -- Put a new line into a txt file
        PERFORM utl_file.new_line(ftest);

        -- Place a marker to check the number of new lines
        PERFORM utl_file.put_line(ftest, '@@ NEW LINE MARKER @@');

        -- Passing 0 to utl_file.new_line should place no new line
        PERFORM utl_file.new_line(ftest, 0);
        
        PERFORM utl_file.put_line(ftest, '@@ NEW LINE MARKER @@');

        -- Passing 2 to utl_file.new_line should place two new lines
        PERFORM utl_file.new_line(ftest, 2);
        
        -- Put a string into a txt file without a new line
        PERFORM utl_file.put(ftest, 'ABC ');
        PERFORM utl_file.put(ftest, '@@ END OF LINE @@');
        PERFORM utl_file.new_line(ftest);

        -- Test formatted put
        PERFORM utl_file.putf(ftest, '[1=%s, 2=%s, 3=%s, 4=%s, 5=%s]', '1', '2', '3', '4', '5');
        PERFORM utl_file.new_line(ftest);

        PERFORM utl_file.fclose(ftest);
    END;
    $$;

    -- Test validity of the generated file
    SELECT results_eq(
        $$SELECT * FROM utl_file.fgetattr('TMPDIR', 'test.txt');$$,
        $$VALUES (true,117::bigint,4096::integer)$$,
        'File is successfully generated'
    );

    -- Test fcopy, frename, fremove
    SELECT lives_ok(
        $$SELECT utl_file.fcopy('TMPDIR', 'test.txt', 'TMPDIR', 'test2.txt');$$,
        'Test fcopy'
    );

    SELECT results_eq(
        $$SELECT * FROM utl_file.fgetattr('TMPDIR', 'test.txt');$$,
        $$SELECT * FROM utl_file.fgetattr('TMPDIR', 'test2.txt');$$,
        'Copied file has the same attributes as the original'
    );

    SELECT lives_ok(
        $$SELECT utl_file.frename('TMPDIR', 'test2.txt', 'TMPDIR', 'test3.txt', true);$$,
        'Test frename'
    );

    SELECT results_eq(
        $$SELECT utl_file.fgetattr('TMPDIR', 'test.txt');$$,
        $$SELECT utl_file.fgetattr('TMPDIR', 'test3.txt');$$,
        'Renamed file has the same attributes as the original'
    );

    SELECT lives_ok(
        $$SELECT utl_file.fremove('TMPDIR', 'test3.txt');$$,
        'Test fremove'
    );

    SELECT results_eq(
        $$SELECT * FROM utl_file.fgetattr('TMPDIR', 'test3.txt');$$,
        $$VALUES (false,NULL::bigint,NULL::integer)$$,
        'File is successfully removed'
    );

    -- Test contents of the file
    CREATE OR REPLACE FUNCTION read_file(dir text, fname text, maxlength int default 0)
    RETURNS text
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        f utl_file.file_type;
        stack text := '';
        line text;
    BEGIN
        f := utl_file.fopen(dir, fname, 'r');
        WHILE utl_file.is_open(f)
        LOOP
            IF maxlength > 0 THEN 
                SELECT utl_file.get_line(f, maxlength) INTO line;
            ELSE
                SELECT utl_file.get_line(f) INTO line;
            END IF;
            
            stack := stack || line || E'\n';
        END LOOP;

        EXCEPTION WHEN others THEN
            PERFORM utl_file.fclose_all();
        
        RETURN stack;
    END;
    $$;

    SELECT is(
        read_file('TMPDIR', 'test.txt'),
        E'1234567890\n'
         '1234567890\n'
         '\n'
         '@@ NEW LINE MARKER @@\n'
         '@@ NEW LINE MARKER @@\n'
         '\n'
         '\n'
         'ABC @@ END OF LINE @@\n'
         '[1=1, 2=2, 3=3, 4=4, 5=5]\n',
         'The content of the test file matches the expected'
    );

    -- Test fflush
    CREATE OR REPLACE FUNCTION flush_file_test()
    RETURNS text
    LANGUAGE plpgsql
    AS
    $$
    DECLARE
        writefile utl_file.file_type;
        stack text;
    BEGIN
        writefile := utl_file.fopen('TMPDIR', 'test.txt', 'w');
        PERFORM utl_file.put_line(writefile, 'ABCDEFG');
        PERFORM utl_file.fflush(writefile);

        stack := read_file('TMPDIR', 'test.txt');
        RETURN stack;
    END;
    $$;

    SELECT is(
        flush_file_test(),
        E'ABCDEFG\n',
        'Test the contents were written to the file after flush'
    );

    -- Test write in append mode
    DO
    $$
    DECLARE
        appendfile utl_file.file_type;
    BEGIN
        appendfile := utl_file.fopen('TMPDIR', 'test.txt', 'a');
        PERFORM utl_file.put_line(appendfile, 'HIJKLMN');
        PERFORM utl_file.fclose(appendfile);
    END;
    $$;
    
    SELECT is(
        read_file('TMPDIR', 'test.txt'),
        E'ABCDEFG\n'
         'HIJKLMN\n',
        'Test the contents were appended to the test file'
    );

    -- Test utl_file.get_line with maxlength
    SELECT is(
        read_file('TMPDIR', 'test.txt', 4),
        E'ABCD\n'
         'EFG\n'
         'HIJK\n'
         'LMN\n',
        'Test the files are read according to the maxlength'
    );

    SELECT utl_file.fremove('TMPDIR', 'test.txt');

    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;