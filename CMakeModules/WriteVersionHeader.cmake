#
#  This program source code file is part of KICAD, a free EDA CAD application.
#
#  Copyright (C) 2015 Wayne Stambaugh <stambaughw@verizon.net>
#  Copyright (C) 2015-2016 KiCad Developers, see AUTHORS.txt for contributors.
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, you may find one here:
#  http://www.gnu.org/licenses/old-licenses/gpl-2.0.html
#  or you may search the http://www.gnu.org website for the version 2 license,
#  or you may write to the Free Software Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
#

# Automagically create version header file if the version string was not defined during
# the build configuration.  If CreateBzrVersionHeader or CreateGitVersionHeader cannot
# determine the current repo version, a version.h file is still created with
# KICAD_BUILD_VERSION set to "no-vcs-found".
if( NOT KICAD_BUILD_VERSION )
    include( ${CMAKE_MODULE_PATH}/KiCadVersion.cmake )

    # Detect the appropiate VCS and set the version string.
    if( EXISTS "${SRC_PATH}/.bzr" )
        message( STATUS "Using Bazaar to determine build version string." )
        include( ${CMAKE_MODULE_PATH}/CreateBzrVersionHeader.cmake )
        create_bzr_version_header( ${SRC_PATH} )
        set( _wvh_version_str ${KICAD_BUILD_VERSION} )
    elseif( EXISTS "${SRC_PATH}/.git" )
        message( STATUS "Using Git to determine build version string." )
        include( ${CMAKE_MODULE_PATH}/CreateGitVersionHeader.cmake )
        create_git_version_header( ${SRC_PATH} )
        set( _wvh_version_str ${KICAD_BUILD_VERSION} )
    endif()
else()
    set( _wvh_version_str ${KICAD_BUILD_VERSION} )
endif()

set( _wvh_write_version_file ON )

# Compare the version argument against the version in the existing header file for a mismatch.
if( EXISTS ${OUTPUT_FILE} )
    file( STRINGS ${OUTPUT_FILE} _current_version_str
        REGEX "^#define[\t ]+KICAD_FULL_VERSION[\t ]+.*" )
    string( REGEX REPLACE "^#define KICAD_FULL_VERSION \"([()a-zA-Z0-9 -.]+)\".*"
        "\\1" _wvh_last_version "${_current_version_str}" )

    # No change, do not write version.h
    if( _wvh_version_str STREQUAL _wvh_last_version )
        message( STATUS "Not updating ${OUTPUT_FILE}" )
        set( _wvh_write_version_file OFF )
    endif()
endif()

if( _wvh_write_version_file )
    message( STATUS "Writing ${OUTPUT_FILE} file with version: ${_wvh_version_str}" )

    file( WRITE ${OUTPUT_FILE}
"/* Do not modify this file, it was automatically generated by CMake. */

/*
 * Define the KiCad build version string.
 */
#ifndef __KICAD_VERSION_H__
#define __KICAD_VERSION_H__

#define KICAD_BUILD_VERSION \"${_wvh_version_str}\"
#define KICAD_BRANCH_NAME \"${KICAD_BRANCH_NAME}\"
#define KICAD_FULL_VERSION \"${KICAD_FULL_VERSION}\"

#endif  /* __KICAD_VERSION_H__ */
"
    )

endif()

# There should always be a valid version.h file.  Otherwise, the build will fail.
if( NOT EXISTS ${OUTPUT_FILE} )
    message( FATAL_ERROR "Configuration failed to write file ${OUTPUT_FILE}." )
endif()
