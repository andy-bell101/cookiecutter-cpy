cmake_minimum_required(VERSION 3.31)

# Project name is not the Python module name; we'll set output explicitly.
project(_core LANGUAGES CXX)
enable_testing()

set(SKBUILD_PROJECT_NAME "{{ cookiecutter.python_binding }}" CACHE STRING "Project name")
set(SKBUILD_PROJECT_VERSION "0.1.0" CACHE STRING "Project version")
set(SKBUILD_SABI_MODULE "Development.SABIModule" CACHE STRING "Stable ABI")

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# --- Dependencies ---
# When building via pip, scikit-build-core will ensure Python is available.
find_package(Python COMPONENTS Interpreter Development.Module ${SKBUILD_SABI_MODULE} REQUIRED)

# nanobind is expected to be installed in the build env (pip build isolation).
# It ships a CMake config package.
include(FetchContent)
FetchContent_Declare(
  nanobind
  GIT_REPOSITORY https://github.com/wjakob/nanobind.git
  GIT_TAG v2.10.2
)
FetchContent_MakeAvailable(nanobind)

FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG v1.17.0
)
FetchContent_MakeAvailable(googletest)

# --- Main library ---
set(SOURCE_FILES
  src/lib.cpp
)
set(TEST_FILES
  tests/test_lib.cpp
)
add_library({{ cookiecutter.python_binding }}_lib STATIC ${SOURCE_FILES})
target_include_directories({{ cookiecutter.python_binding }}_lib PUBLIC .)
set_target_properties({{ cookiecutter.python_binding }}_lib PROPERTIES POSITION_INDEPENDENT_CODE ON)

# --- Extension module ---
set(BINDING_FILES src/bindings.cpp)
# Name here is the CMake target name. Output name controls the import name.
nanobind_add_module(_core
  STABLE_ABI           # comment out if you don't want the limited API wheel behavior
  NB_STATIC            # avoids a runtime dependency on a shared nanobind library
  ${BINDING_FILES}
)

include(cmake/features.cmake)
include(cmake/warnings.cmake)
apply_features(_core)
apply_warnings(_core)

# Place the compiled module inside your Python package directory at build/install time.
# scikit-build-core will install from the CMake install rules.
set_target_properties(_core PROPERTIES
  OUTPUT_NAME "_core"
)

target_compile_features(_core PRIVATE cxx_std_17)

# Good cross-platform hygiene
target_compile_definitions(_core PRIVATE
  # Avoid Windows macro collisions
  $<$<BOOL:${WIN32}>:NOMINMAX>
  SKBUILD_PROJECT_VERSION=${SKBUILD_PROJECT_VERSION}
)

target_link_libraries(_core PRIVATE {{ cookiecutter.python_binding }}_lib)

# --- Install ---
# Install into the Python package "yourpkg" so import yourpkg._core works.
install(TARGETS _core
  LIBRARY DESTINATION ${SKBUILD_PROJECT_NAME}
  RUNTIME DESTINATION ${SKBUILD_PROJECT_NAME}   # Windows .pyd
  ARCHIVE DESTINATION ${SKBUILD_PROJECT_NAME}   # rarely used for extensions, harmless
)

# --- Tests ---
add_executable(
  tests
  ${TEST_FILES}
)

target_link_libraries(
  tests
  PRIVATE
  GTest::gtest_main
  {{ cookiecutter.python_binding }}_lib
)
include(GoogleTest)
gtest_discover_tests(tests)
