# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Tries to find the clang modules
#
# Usage of this module as follows:
#
#  find_package(Clang)
#
# Variables used by this module, they can change the default behaviour and need
# to be set before calling find_package:
#
#  LLVM_PATH -
#   When set, this path is inspected instead of standard library binary locations
#   to find clang
#
# This module defines
#   CLANG_FOUND,  Whether clang was found
#   CLANG_INCLUDE_DIRS, The path to the clang include
#   CLANG_DEFINITIONS, The default cxxflags to the clang
#   CLANG_EXECUTABLE,  The path to the clang binary

function(set_clang_definitions config_cmd)
  execute_process(
    COMMAND ${config_cmd} --cppflags
    OUTPUT_VARIABLE llvm_cppflags
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REGEX MATCHALL "(-D[^ ]*)" dflags ${llvm_cppflags})
  string(REGEX MATCHALL "(-U[^ ]*)" uflags ${llvm_cppflags})
  list(APPEND cxxflags ${dflags})
  list(APPEND cxxflags ${uflags})

  set(CLANG_DEFINITIONS ${cxxflags} PARENT_SCOPE)
endfunction()

function(is_clang_installed config_cmd)
  execute_process(
    COMMAND ${config_cmd} --includedir
    OUTPUT_VARIABLE include_dirs
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  execute_process(
    COMMAND ${config_cmd} --src-root
    OUTPUT_VARIABLE llvm_src_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(FIND ${include_dirs} ${llvm_src_dir} result)

  set(CLANG_INSTALLED ${result} PARENT_SCOPE)
endfunction()

function(set_clang_include_dirs config_cmd)
  is_clang_installed(${config_cmd})
  if(CLANG_INSTALLED)
    execute_process(
      COMMAND ${config_cmd} --includedir
      OUTPUT_VARIABLE include_dirs
      OUTPUT_STRIP_TRAILING_WHITESPACE)
  else()
    execute_process(
      COMMAND ${config_cmd} --src-root
      OUTPUT_VARIABLE llvm_src_dir
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(
      COMMAND ${config_cmd} --obj-root
      OUTPUT_VARIABLE llvm_obj_dir
      OUTPUT_STRIP_TRAILING_WHITESPACE)
    list(APPEND include_dirs "${llvm_src_dir}/include")
    list(APPEND include_dirs "${llvm_obj_dir}/include")
    list(APPEND include_dirs "${llvm_src_dir}/tools/clang/include")
    list(APPEND include_dirs "${llvm_obj_dir}/tools/clang/include")
  endif()

  set(CLANG_INCLUDE_DIRS ${include_dirs} PARENT_SCOPE)
endfunction()


find_program(LLVM_CONFIG
  NAMES llvm-config-9
  llvm-config-8
  llvm-config-7.0
  llvm-config-6.0
  llvm-config-5.1
  llvm-config-5.0
  llvm-config-4.0
  llvm-config-3.9
  llvm-config-3.8
  llvm-config
  PATHS ENV LLVM_PATH
)

if(LLVM_CONFIG)
  message("llvm-config found : ${LLVM_CONFIG}")
else()
  message("Can't found program: llvm-config")
endif()

find_program(CLANG_EXECUTABLE
  NAMES clang-9
  clang-8
  clang-7.0
  clang-6.0
  clang-5.1
  clang-5.0
  clang-4.0
  clang-3.9
  clang-3.8
  clang
  PATHS ENV LLVM_PATH
)

if(CLANG_EXECUTABLE)
  message("clang found : ${CLANG_EXECUTABLE}")
else()
  message("Can't found program: clang")
endif()

set_clang_definitions(${LLVM_CONFIG})
set_clang_include_dirs(${LLVM_CONFIG})

message("llvm-config filtered cpp flags : ${CLANG_DEFINITIONS}")
message("llvm-config filtered include dirs : ${CLANG_INCLUDE_DIRS}")

set(CLANG_FOUND 1)
