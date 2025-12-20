# Cache-driven warning policy (set in presets)
set(WARNING_LEVEL "DEFAULT" CACHE STRING "DEFAULT|STRICT|OFF")
set_property(CACHE WARNING_LEVEL PROPERTY STRINGS DEFAULT STRICT OFF)
option(ENABLE_WERROR "Warnings as errors" OFF)

function(apply_warnings tgt)
  if(WARNING_LEVEL STREQUAL "OFF")
    return()
  endif()

  if(MSVC)
    target_compile_options(${tgt} PRIVATE /W4 /permissive- /Zc:__cplusplus /utf-8)
    # Useful noise reduction for template-heavy codebases (optional):
    # target_compile_options(${tgt} PRIVATE /wd4251 /wd4275)
    if(WARNING_LEVEL STREQUAL "STRICT")
      target_compile_options(${tgt} PRIVATE /w14242 /w14254 /w14263 /w14265 /w14287)
    endif()
    if(ENABLE_WERROR)
      target_compile_options(${tgt} PRIVATE /WX)
    endif()
  else()
    target_compile_options(${tgt} PRIVATE -Wall -Wextra -Wpedantic)
    if(WARNING_LEVEL STREQUAL "STRICT")
      target_compile_options(${tgt} PRIVATE
        -Wshadow
        -Wconversion -Wsign-conversion
        -Wformat=2
        -Wnon-virtual-dtor
        -Woverloaded-virtual
      )
    endif()
    if(ENABLE_WERROR)
      target_compile_options(${tgt} PRIVATE -Werror)
    endif()
  endif()
endfunction()

