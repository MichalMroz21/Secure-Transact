find_package(Boost COMPONENTS ${BOOST_INCLUDE_LIBRARIES})

if(NOT ${Boost_FOUND})
    update_submodule("${CMAKE_CURRENT_LIST_DIR}/boost")
    add_subdirectory(boost)
endif()

enable_testing()
find_package(GTest)

if(${GTest_FOUND})
    set(GTEST_LINK gtest gtest_main PARENT_SCOPE)
else()
    update_submodule("${CMAKE_CURRENT_LIST_DIR}/gtest")
    add_subdirectory(gtest)
    set(GTEST_LINK GTest::gtest GTest::gtest_main PARENT_SCOPE)
endif()

if(NOT ${Qt6_FOUND})
    update_submodule("${CMAKE_CURRENT_LIST_DIR}/qt")
    add_subdirectory(qt)
endif()
