SET(SOURCE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")
SET(TMAX_ORAFCE_SOURCES_TP
    ${SOURCE_PATH}/parse_keyword.c
    ${SOURCE_PATH}/plunit.c
    ${SOURCE_PATH}/plvdate.c
#   ${SOURCE_PATH}/plvlex.c
    ${SOURCE_PATH}/plvstr.c
    ${SOURCE_PATH}/plvsubst.c
#   ${SOURCE_PATH}/sqlparse.c
#   ${SOURCE_PATH}/sqlscan.c

    PARENT_SCOPE
)