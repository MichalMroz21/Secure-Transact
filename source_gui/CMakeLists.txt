file(GLOB_RECURSE GUI_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} *.qml)

foreach(QML_FILE ${GUI_FILES})
    add_files(${QML_FILE} "QML_FILES")
endforeach()
