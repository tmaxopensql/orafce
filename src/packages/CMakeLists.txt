SET(SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
SET(TMAX_ORAFCE_SOURCES_PK
    ${SOURCE_PATH}/dbms_alert.c
    ${SOURCE_PATH}/dbms_assert.c
    ${SOURCE_PATH}/dbms_output.c
    ${SOURCE_PATH}/dbms_pipe.c
    ${SOURCE_PATH}/dbms_random.c
    ${SOURCE_PATH}/dbms_sql.c
    ${SOURCE_PATH}/dbms_utility.c
    ${SOURCE_PATH}/utl_file.c
    PARENT_SCOPE
)