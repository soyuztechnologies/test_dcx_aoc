CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS augment_create FOR MODIFY
      IMPORTING entities FOR CREATE Travel.

    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE Travel.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD augment_create.

    data: travel_create type table for create ZDXC_AB_M_TRAVEL.

     travel_create = CORRESPONDING #( entities ).

     loop at travel_create assigning field-symbol(<travel>).

        <travel>-AgencyId = '70003'.
        <travel>-OverallStatus = 'O'.
        <travel>-%control-AgencyId = if_abap_behv=>mk-on.
        <travel>-%control-OverallStatus = if_abap_behv=>mk-on.

     ENDLOOP.

     MODIFY augmenting entities of ZDXC_AB_M_TRAVEL
     entity travel
     create from travel_create.

  ENDMETHOD.

  METHOD precheck_create.
  ENDMETHOD.

ENDCLASS.
