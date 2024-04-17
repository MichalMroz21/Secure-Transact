if(${GTest_FOUND} AND MAKE_TEST_EXE)

else()
    update_submodule("${CMAKE_CURRENT_LIST_DIR}/googletest")
    add_subdirectory(googletest)
endif()
