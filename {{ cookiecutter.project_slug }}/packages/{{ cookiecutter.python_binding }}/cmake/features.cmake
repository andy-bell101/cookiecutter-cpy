include(CheckIPOSupported)

option(ENABLE_LTO        "Enable IPO/LTO" OFF)
option(ENABLE_ASAN_UBSAN "Enable ASan+UBSan" OFF)
option(ENABLE_TSAN       "Enable TSan" OFF) # mutually exclusive with ASan

function(apply_features tgt)
  # LTO (portable via property)
  if(ENABLE_LTO)
    check_ipo_supported(RESULT ok OUTPUT msg)
    if(ok)
      set_property(TARGET ${tgt} PROPERTY INTERPROCEDURAL_OPTIMIZATION TRUE)
    else()
      message(STATUS "IPO/LTO not supported: ${msg}")
    endif()
  endif()

  # Sanitizers (dev only; generally not for distribution builds)
  if(ENABLE_ASAN_UBSAN AND ENABLE_TSAN)
    message(FATAL_ERROR "ENABLE_ASAN_UBSAN and ENABLE_TSAN are mutually exclusive")
  endif()

  if(NOT MSVC)
    if(ENABLE_ASAN_UBSAN)
      target_compile_options(${tgt} PRIVATE
        -fsanitize=address,undefined
        -fno-omit-frame-pointer
      )
      target_link_options(${tgt} PRIVATE -fsanitize=address,undefined)
    endif()
    if(ENABLE_TSAN)
      target_compile_options(${tgt} PRIVATE
        -fsanitize=thread
        -fno-omit-frame-pointer
      )
      target_link_options(${tgt} PRIVATE -fsanitize=thread)
    endif()
  endif()
endfunction()

