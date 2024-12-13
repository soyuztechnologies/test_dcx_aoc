CLASS zcl_dxc_ab_mission_mars DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dxc_ab_mission_mars IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    data itab type table of string.
    data(lo_earth) = new lcl_earth(  ).
    data(lo_implanet) = new lcl_implanet(  ).
    data(lo_mars) = new lcl_mars(  ).

    append lo_earth->takeoff(  ) to itab.
    append lo_earth->leave_orbit( ) to itab.

    append lo_implanet->enter_orbit(  ) to itab.
    append lo_implanet->leave_orbit(  ) to itab.

    append lo_mars->enter_orbit(  ) to itab.
    append lo_mars->land_exploration(  ) to itab.

    out->write(
      EXPORTING
        data   = itab
*        name   =
*      RECEIVING
*        output =
    ).

  ENDMETHOD.
ENDCLASS.















