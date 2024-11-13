-- Skip this test unless it's a Linux/glibc system with the "en_US.utf8" locale installed.
SELECT getdatabaseencoding() <> 'UTF8' OR
       NOT EXISTS (SELECT 1 FROM pg_collation WHERE collname = 'en_US' AND collencoding = pg_char_to_encoding('UTF8')) OR
       version() !~ 'linux-gnu'
       AS skip_test \gset
\if :skip_test
DO $$ BEGIN RAISE NOTICE 'Skip this test unless it is a Linux/glibc system with the "en_US.utf8" locale installed.'; END; $$;
\quit
\endif

-- For PG >= 15 explicitly set the locale provider libc when creating the
-- database with SQL_ASCII encoding. Otherwise during installcheck the new
-- database may use the ICU locale provider (from template0) which does not
-- support this encoding.
DROP DATABASE IF EXISTS regression_sort;
SELECT current_setting('server_version_num')::integer >= 150000
    AS set_libc_locale_provider \gset

\if :set_libc_locale_provider
CREATE DATABASE regression_sort WITH TEMPLATE = template0 ENCODING='SQL_ASCII' LC_COLLATE='C' LC_CTYPE='C' LOCALE_PROVIDER='libc';
\else
CREATE DATABASE regression_sort WITH TEMPLATE = template0 ENCODING='SQL_ASCII' LC_COLLATE='C' LC_CTYPE='C';
\endif

\c regression_sort

-- Start transaction and plan the tests.
BEGIN;
    -- Create pgtap and orafce in case
    CREATE EXTENSION IF NOT EXISTS orafce;
    CREATE EXTENSION IF NOT EXISTS pgtap;
    
    -- Plan the number of tests to execute
    SELECT PLAN(8);

    -- Set search_path to oracle to prevent using "oracle.*" prefixes on everything
    SET search_path to public, oracle;

    -- Write tests
    CREATE TABLE test_sort (name TEXT);
    INSERT INTO test_sort VALUES ('red'), ('brown'), ('yellow'), ('Purple');
    
    SELECT results_eq(
        'SELECT * FROM test_sort ORDER BY NLSSORT(name, '''');',
        ARRAY['Purple', 'brown', 'red', 'yellow']
    );

    SELECT lives_ok('SELECT oracle.set_nls_sort(''invalid'')');

    SELECT throws_ok(
        'SELECT * FROM test_sort ORDER BY NLSSORT(name);',
        'failed to set the requested LC_COLLATE value [invalid]'
    );

    SELECT lives_ok('SELECT set_nls_sort('''');');
    
    SELECT results_eq(
        'SELECT * FROM test_sort ORDER BY NLSSORT(name);',
        ARRAY['Purple', 'brown', 'red', 'yellow']
    );

    SELECT lives_ok('SELECT set_nls_sort(''en_US.utf8'');');
    
    SELECT results_eq(
        'SELECT * FROM test_sort ORDER BY NLSSORT(name);',
        ARRAY['brown', 'Purple', 'red', 'yellow']
    );

    INSERT INTO test_sort VALUES(NULL);
    
    SELECT results_eq(
        'SELECT * FROM test_sort ORDER BY NLSSORT(name);',
        ARRAY['brown', 'Purple', 'red', 'yellow', NULL]
    );
    
    -- Clean up and finish the test
    SELECT * FROM finish();

ROLLBACK;

\c template0
DROP DATABASE IF EXISTS regression_sort;