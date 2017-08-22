function (sprokit_symlink_install)
  # """
  # Mimics a sprokit_install, but will symlink each file in `FILES` directly to
  # the directory `DESTINATION`.  This should only be used for dynamic
  # languages like python
  # """

  # FIXME: this is not working for the python tests
  # should no_install be used?
  if (no_install)
    return()
  endif ()

  # MIMIC the signature of `install`
  set(options)
  set(oneValueArgs DESTINATION COMPONENT)
  set(multiValueArgs FILES)
  cmake_parse_arguments(MY "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

  foreach(source_fpath ${MY_FILES})
      # Build abspath of the destination file
      get_filename_component(fname ${source_fpath} NAME)
      set(dest_fpath "${CMAKE_INSTALL_PREFIX}/${MY_DESTINATION}/${fname}")

      message(STATUS "Symlink-Install")
      message(STATUS " * source_fpath = ${source_fpath}")
      message(STATUS " * dest_fpath = ${dest_fpath}")

      # References:
      # https://github.com/bro/cmake/blob/master/InstallSymlink.cmake
      install(CODE "
        execute_process(COMMAND \"${CMAKE_COMMAND}\" -E create_symlink
          ${source_fpath}
          ${dest_fpath})
      "
      #COMPONENT ${MY_COMPONENT}
      )
  endforeach()

endfunction ()
