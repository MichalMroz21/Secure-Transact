find_package(Boost COMPONENTS ${BOOST_INCLUDE_LIBRARIES})

if(${Boost_FOUND})
    include_directories(${Boost_INCLUDE_DIRS})
else()
    update_submodule("${CMAKE_CURRENT_LIST_DIR}/boost")
    add_subdirectory(boost)
endif()

list(TRANSFORM BOOST_INCLUDE_LIBRARIES PREPEND "Boost::")

enable_testing()
find_package(GTest)

if(${GTest_FOUND})
    set(GTEST_LINK GTest::GTest GTest::Main)
else()
    update_submodule("${CMAKE_CURRENT_LIST_DIR}/gtest")
    add_subdirectory(gtest)
    set(GTEST_LINK GTest::gtest GTest::gtest_main)
endif()

