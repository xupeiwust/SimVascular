# Copyright (c) Stanford University, The Regents of the University of
#               California, and others.
#
# All Rights Reserved.
#
# See Copyright-SimVascular.txt for additional details.
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject
# to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
# PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
# OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# - Find Tcl includes and libraries.
# This module finds if Tcl is installed and determines where the
# include files and libraries are. It also determines what the name of
# the library is. This code sets the following variables:
#  TCL_FOUND              = Tcl was found
#  TK_FOUND               = Tk was found
#  TCLTK_FOUND            = Tcl and Tk were found
#  TCL_LIBRARY            = path to Tcl library (tcl tcl80)
#  TCL_INCLUDE_PATH       = path to where tcl.h can be found
#  TCL_TCLSH              = path to tclsh binary (tcl tcl80)
#  TK_LIBRARY             = path to Tk library (tk tk80 etc)
#  TK_INCLUDE_PATH        = path to where tk.h can be found
#  TK_WISH                = full path to the wish executable
#
# In an effort to remove some clutter and clear up some issues for people
# who are not necessarily Tcl/Tk gurus/developpers, some variables were
# moved or removed. Changes compared to CMake 2.4 are:
# - The stub libraries are now found in FindTclStub.cmake
#   => they were only useful for people writing Tcl/Tk extensions.
# - TCL_LIBRARY_DEBUG and TK_LIBRARY_DEBUG were removed.
#   => these libs are not packaged by default with Tcl/Tk distributions.
#      Even when Tcl/Tk is built from source, several flavors of debug libs
#      are created and there is no real reason to pick a single one
#      specifically (say, amongst tcl84g, tcl84gs, or tcl84sgx).
#      Let's leave that choice to the user by allowing him to assign
#      TCL_LIBRARY to any Tcl library, debug or not.
# - TK_INTERNAL_PATH was removed.
#   => this ended up being only a Win32 variable, and there is a lot of
#      confusion regarding the location of this file in an installed Tcl/Tk
#      tree anyway (see 8.5 for example). If you need the internal path at
#      this point it is safer you ask directly where the *source* tree is
#      and dig from there.

include(CMakeFindFrameworks)
find_package(TclSh)
find_package(Wish)


get_filename_component(TCL_TCLSH_PATH "${TCL_TCLSH}" PATH)
get_filename_component(TCL_TCLSH_PATH_PARENT "${TCL_TCLSH_PATH}" PATH)
string(REGEX REPLACE
  "^.*tclsh([0-9]\\.*[0-9]).*$" "\\1" TCL_TCLSH_VERSION "${TCL_TCLSH}")

get_filename_component(TK_WISH_PATH "${TK_WISH}" PATH)
get_filename_component(TK_WISH_PATH_PARENT "${TK_WISH_PATH}" PATH)
string(REGEX REPLACE
  "^.*wish([0-9]\\.*[0-9]).*$" "\\1" TK_WISH_VERSION "${TK_WISH}")

get_filename_component(TCL_INCLUDE_PATH_PARENT "${TCL_INCLUDE_PATH}" PATH)
get_filename_component(TK_INCLUDE_PATH_PARENT "${TK_INCLUDE_PATH}" PATH)

get_filename_component(TCL_LIBRARY_PATH "${TCL_LIBRARY}" PATH)
get_filename_component(TCL_LIBRARY_PATH_PARENT "${TCL_LIBRARY_PATH}" PATH)
string(REGEX REPLACE
  "^.*tcl([0-9]\\.*[0-9]).*$" "\\1" TCL_LIBRARY_VERSION "${TCL_LIBRARY}")

get_filename_component(TK_LIBRARY_PATH "${TK_LIBRARY}" PATH)
get_filename_component(TK_LIBRARY_PATH_PARENT "${TK_LIBRARY_PATH}" PATH)
string(REGEX REPLACE
  "^.*tk([0-9]\\.*[0-9]).*$" "\\1" TK_LIBRARY_VERSION "${TK_LIBRARY}")

set(TCLTK_POSSIBLE_LIB_PATHS
  "${TCL_DIR}/lib"
  "${TCL_INCLUDE_PATH_PARENT}/lib"
  "${TK_INCLUDE_PATH_PARENT}/lib"
  "${TCL_LIBRARY_PATH}"
  "${TK_LIBRARY_PATH}"
  "${TCL_TCLSH_PATH_PARENT}/lib"
  "${TK_WISH_PATH_PARENT}/lib"
  /usr/lib
  /usr/local/lib
  )

if(WIN32)
  get_filename_component(
    ActiveTcl_CurrentVersion
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\ActiveState\\ActiveTcl;CurrentVersion]"
    NAME)
  set(TCLTK_POSSIBLE_LIB_PATHS ${TCLTK_POSSIBLE_LIB_PATHS}
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\ActiveState\\ActiveTcl\\${ActiveTcl_CurrentVersion}]/lib"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.6;Root]/lib"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.5;Root]/lib"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.4;Root]/lib"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.3;Root]/lib"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.2;Root]/lib"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.0;Root]/lib"
    "$ENV{ProgramFiles}/Tcl/Lib"
    "C:/Program Files/Tcl/lib"
    "C:/Tcl/lib"
    )
endif(WIN32)

if(EXISTS "${TCL_DIR}/lib")
  unset(TCL_LIBRARY CACHE)
  unset(TK_LIBRARY CACHE)
  find_library(TCL_LIBRARY
    NAMES
    tcl
    tcl${TK_LIBRARY_VERSION} tcl${TCL_TCLSH_VERSION} tcl${TK_WISH_VERSION}
    tcl86 tcl8.6
    tcl85 tcl8.5
    tcl84 tcl8.4
    tcl83 tcl8.3
    tcl82 tcl8.2
    tcl80 tcl8.0
    PATHS ${TCL_DIR}/lib
    NO_DEFAULT_PATH
    )
  find_library(TK_LIBRARY
    NAMES
    tk
    tk${TCL_LIBRARY_VERSION} tk${TCL_TCLSH_VERSION} tk${TK_WISH_VERSION}
    tk86 tk8.6
    tk85 tk8.5
    tk84 tk8.4
    tk83 tk8.3
    tk82 tk8.2
    tk80 tk8.0
    PATHS ${TCL_DIR}/lib
    NO_DEFAULT_PATH
    )
endif()

find_library(TCL_LIBRARY
  NAMES
  tcl
  tcl${TK_LIBRARY_VERSION} tcl${TCL_TCLSH_VERSION} tcl${TK_WISH_VERSION}
  tcl86 tcl8.6
  tcl85 tcl8.5
  tcl84 tcl8.4
  tcl83 tcl8.3
  tcl82 tcl8.2
  tcl80 tcl8.0
  PATHS ${TCLTK_POSSIBLE_LIB_PATHS}
  NO_DEFAULT_PATH
  )

find_library(TK_LIBRARY
  NAMES
  tk
  tk${TCL_LIBRARY_VERSION} tk${TCL_TCLSH_VERSION} tk${TK_WISH_VERSION}
  tk86 tk8.6
  tk85 tk8.5
  tk84 tk8.4
  tk83 tk8.3
  tk82 tk8.2
  tk80 tk8.0
  PATHS ${TCLTK_POSSIBLE_LIB_PATHS}
  NO_DEFAULT_PATH
  )

cmake_find_frameworks(Tcl)
cmake_find_frameworks(Tk)

set(TCL_FRAMEWORK_INCLUDES)
if(Tcl_FRAMEWORKS)
  if(NOT TCL_INCLUDE_PATH)
    foreach(dir ${Tcl_FRAMEWORKS})
      set(TCL_FRAMEWORK_INCLUDES ${TCL_FRAMEWORK_INCLUDES} ${dir}/Headers)
    endforeach(dir)
  endif(NOT TCL_INCLUDE_PATH)
endif(Tcl_FRAMEWORKS)

set(TK_FRAMEWORK_INCLUDES)
if(Tk_FRAMEWORKS)
  if(NOT TK_INCLUDE_PATH)
    foreach(dir ${Tk_FRAMEWORKS})
      set(TK_FRAMEWORK_INCLUDES ${TK_FRAMEWORK_INCLUDES}
        ${dir}/Headers ${dir}/PrivateHeaders)
    endforeach(dir)
  endif(NOT TK_INCLUDE_PATH)
endif(Tk_FRAMEWORKS)

set(TCLTK_POSSIBLE_INCLUDE_PATHS
  "${TCL_DIR}/include"
  "${TCL_LIBRARY_PATH_PARENT}/include"
  "${TK_LIBRARY_PATH_PARENT}/include"
  "${TCL_INCLUDE_PATH}"
  "${TK_INCLUDE_PATH}"
  ${TCL_FRAMEWORK_INCLUDES}
  ${TK_FRAMEWORK_INCLUDES}
  "${TCL_TCLSH_PATH_PARENT}/include"
  "${TK_WISH_PATH_PARENT}/include"
  /usr/include
  /usr/local/include
  /usr/include/tcl${TK_LIBRARY_VERSION}
  /usr/include/tcl${TCL_LIBRARY_VERSION}
  /usr/include/tcl8.6
  /usr/include/tcl8.5
  /usr/include/tcl8.4
  /usr/include/tcl8.3
  /usr/include/tcl8.2
  /usr/include/tcl8.0
  )

if(WIN32)
  set(TCLTK_POSSIBLE_INCLUDE_PATHS ${TCLTK_POSSIBLE_INCLUDE_PATHS}
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\ActiveState\\ActiveTcl\\${ActiveTcl_CurrentVersion}]/include"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.6;Root]/include"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.5;Root]/include"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.4;Root]/include"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.3;Root]/include"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.2;Root]/include"
    "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Scriptics\\Tcl\\8.0;Root]/include"
    "$ENV{ProgramFiles}/Tcl/include"
    "C:/Program Files/Tcl/include"
    "C:/Tcl/include"
    )
endif(WIN32)

if(EXISTS "${TCL_DIR}/include")
  unset(TCL_INCLUDE_PATH CACHE)
  unset(TK_INCLUDE_PATH CACHE)
  find_path(TCL_INCLUDE_PATH
    NAMES tcl.h
    PATHS ${TCL_DIR}/include
    NO_DEFAULT_PATH
    )
  find_path(TK_INCLUDE_PATH
    NAMES tk.h
    PATHS ${TCL_DIR}/include
    NO_DEFAULT_PATH
    )
endif()
find_path(TCL_INCLUDE_PATH
  NAMES tcl.h
  PATHS ${TCLTK_POSSIBLE_INCLUDE_PATHS}
  NO_DEFAULT_PATH
  )
find_path(TCL_INCLUDE_PATH
  NAMES tcl.h
  PATHS ${TCLTK_POSSIBLE_INCLUDE_PATHS}
  )

find_path(TK_INCLUDE_PATH
  NAMES tk.h
  PATHS ${TCLTK_POSSIBLE_INCLUDE_PATHS}
  NO_DEFAULT_PATH
  )
find_path(TK_INCLUDE_PATH
  NAMES tk.h
  PATHS ${TCLTK_POSSIBLE_INCLUDE_PATHS}
  )

# handle the QUIETLY and REQUIRED arguments and set TCL_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)

set(TCL_DIR "${TCL_DIR}" CACHE PATH "Path to top level libraries.  Specify this if TCL cannot be found.")
find_package_handle_standard_args(TCL FOUND_VAR TCL_FOUND
                                  REQUIRED_VARS TCL_LIBRARY TCL_INCLUDE_PATH
                                  FAIL_MESSAGE "Could NOT find Tcl")
find_package_handle_standard_args(TCLTK FOUND_VAR TCLTK_FOUND
                                  REQUIRED_VARS TCL_LIBRARY TCL_INCLUDE_PATH TK_LIBRARY TK_INCLUDE_PATH
                                  FAIL_MESSAGE "Could NOT find TclTk")
find_package_handle_standard_args(TK FOUND_VAR TK_FOUND
                                  REQUIRED_VARS TK_LIBRARY TK_INCLUDE_PATH
                                  FAIL_MESSAGE "Could NOT find Tk")

mark_as_advanced(
  TCL_INCLUDE_PATH
  TK_INCLUDE_PATH
  TCL_LIBRARY
  TK_LIBRARY
  )
