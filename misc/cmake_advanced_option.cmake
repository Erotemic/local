# FIXME: breaks in the case that {varname} should be set to FALSE whenever it
# is not relevant. Currently, if its cached value is true it will still use it.


function(advanced_option varname docstring default is_relevant)
  # Allows advanced options to be shown in the gui only when appropriate
  # Once an variable is set as CACHE INTERAL, it seems the only way to make it
  # visible in the gui again is to unset it.
  if (DEFINED ${varname})
    # Remember the previous value of the variable
    set(value ${${varname}})
    unset(${varname} CACHE)
  else()
    # Use the default on the first call or if the var has been externally unset
    set(value ${default})
  endif()

  if (${is_relevant})
    # Show the last known value of the variable, but only in advanced mode
    option(${varname} ${docstring} ${value})
    mark_as_advanced(${varname})
  else()
    # Keep the variable around in internal cache, but dont show it even in
    # advanced mode.
    set(${varname} ${value} CACHE INTERNAL ${docstring})
  endif()
endfunction()

