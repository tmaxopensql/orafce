# Creating Test Cases
## Use Template
Use ```testcase.sql.template``` in ```tests``` directory as a template for your new test cases.

## Write Descriptions
Every ```pgtap``` functions provide the interface for creating descriptions of your test cases.

If you wish to find which test cases are failing, the descriptions are going to be very helpful since the tests are not indexed. Use ```pg_prove --verbose``` command.

## Avoid Testing inside Procedures
It looks like ```pgtap``` functions cannot be used inside procedures such as UDF, anonymous block, and so on.

If you need to use procedures for your test, the tip is to use a text stack to collect the outcomes and compare it outside the procedures. Refer to ```tests/packages/utl_file.sql read_file``` function for a sample.