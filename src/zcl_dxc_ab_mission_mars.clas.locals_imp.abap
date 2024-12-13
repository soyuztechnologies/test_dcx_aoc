*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
class lcl_earth DEFINITION.
    PUBLIC SECTION.
    METHODS takeoff RETURNING VALUE(r_value) type string.
    METHODS leave_orbit RETURNING VALUE(r_value) type string.
ENDCLASS.

class lcl_earth IMPLEMENTATION.

  METHOD takeoff.
    r_value = |Roger we are launching the shuttle|.
  ENDMETHOD.

  METHOD leave_orbit.
    r_value = |Roger we are leaving earth orbit|.
  ENDMETHOD.

ENDCLASS.

class lcl_implanet DEFINITION.
    PUBLIC SECTION.
    METHODS enter_orbit RETURNING VALUE(r_value) type string.
    METHODS leave_orbit RETURNING VALUE(r_value) type string.
ENDCLASS.

class lcl_implanet IMPLEMENTATION.

  METHOD enter_orbit.
    r_value = |Enter the orbit of intermediatery planet|.
  ENDMETHOD.

  METHOD leave_orbit.
    r_value = |Leave from the intermediatery planet|.
  ENDMETHOD.

ENDCLASS.

class lcl_mars DEFINITION.
    PUBLIC SECTION.
    METHODS enter_orbit RETURNING VALUE(r_value) type string.
    METHODS land_exploration RETURNING VALUE(r_value) type string.
ENDCLASS.

class lcl_mars IMPLEMENTATION.

  METHOD enter_orbit.
    r_value = |Enter the orbit of Mars|.
  ENDMETHOD.

  METHOD land_exploration.
    r_value = |Madee we found water on mars|.
  ENDMETHOD.

ENDCLASS.
