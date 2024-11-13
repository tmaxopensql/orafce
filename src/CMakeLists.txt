# Append source files to TMAX_ORAFCE_SOURCES
# These will be compiled into one single outfile by the CMakeLists in the root directory
add_subdirectory(datatypes)
add_subdirectory(functions)
add_subdirectory(init)
add_subdirectory(packages)
add_subdirectory(third-party)

SET(TMAX_ORAFCE_SOURCES 
    ${TMAX_ORAFCE_SOURCES_DT}
    ${TMAX_ORAFCE_SOURCES_FN}
    ${TMAX_ORAFCE_SOURCES_IN}
    ${TMAX_ORAFCE_SOURCES_PK}
    ${TMAX_ORAFCE_SOURCES_TP}
    PARENT_SCOPE
)