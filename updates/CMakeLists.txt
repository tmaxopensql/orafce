# Append source files to TMAX_ORAFCE_UPDATES
# These will be compiled into one single outfile by the CMakeLists in the root directory
SET(SCRIPT_PATH ${CMAKE_CURRENT_SOURCE_DIR})
SET(TMAX_ORAFCE_UPDATES 
    ${SCRIPT_PATH}/orafce--1.0.sql
    PARENT_SCOPE
)