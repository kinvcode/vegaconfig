cmake_minimum_required(VERSION 3.16)

project(vegaconfig VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick QuickControls2 Widgets)

qt_standard_project_setup(REQUIRES 6.5)

set(APP_ICON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/app.ico")
string(REPLACE "\\" "/" APP_ICON_PATH "${APP_ICON_PATH}")
configure_file(appicon.rc.in "${CMAKE_CURRENT_BINARY_DIR}/appicon.rc" @ONLY)

qt_add_executable(appvegaconfig
    main.cpp
    "${CMAKE_CURRENT_BINARY_DIR}/appicon.rc"
)

qt_add_resources(appvegaconfig "app_icons"
    PREFIX "/icons"
    FILES app.ico
)

qt_add_qml_module(appvegaconfig
    URI vegaconfig
    VERSION 1.0
    QML_FILES
        Main.qml
    SOURCES
        configstore.h
        configstore.cpp
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appvegaconfig PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appvegaconfig
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appvegaconfig
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::Widgets
)

include(GNUInstallDirs)
install(TARGETS appvegaconfig
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
