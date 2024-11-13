# Copyright 2020 Mats Kindahl
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

cmake_minimum_required(VERSION 3.10)
project(orafce VERSION 1.0)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

find_package(PostgreSQL REQUIRED)

set(CMAKE_CXX_STANDARD 14)

include_directories(
    ${PostgreSQL_INCLUDE_DIRS}
    ${PostgreSQL_SERVER_INCLUDE_DIRS})

include_directories(${CMAKE_SOURCE_DIR}/include)
add_subdirectory(src)
add_subdirectory(updates)

add_postgresql_extension(
  ${CMAKE_PROJECT_NAME}
  VERSION ${CMAKE_PROJECT_VERSION}
  SOURCES ${TMAX_ORAFCE_SOURCES}
  SCRIPTS ${TMAX_ORAFCE_UPDATES}
  COMMENT "Functions and operators that emulate a subset of functions and packages from the Oracle RDBMS"
  RELOCATABLE false
)