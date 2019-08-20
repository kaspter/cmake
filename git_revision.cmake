
# Find Git Version Patch
IF(EXISTS "${CMAKE_SOURCE_DIR}/.git")

    find_package(Git)

    if(GIT_FOUND)
        execute_process(
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            COMMAND ${GIT_EXECUTABLE} describe --always --tags --dirty --long
            OUTPUT_VARIABLE GIT_REVISION OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        string(STRIP ${GIT_REVISION} GIT_REVISION)
        message(STATUS "Current git revision is ${GIT_REVISION}")
    else()
        set(GIT_REVISION "${PROJECT_VERSION}")
    endif()
ENDIF()
