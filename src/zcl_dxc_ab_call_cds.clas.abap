CLASS zcl_dxc_ab_call_cds DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DXC_AB_CALL_CDS IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.


    select * from ZDXC_AB_BPA( p_ctry = 'US' ) into table
    @data(itab).

    ""Ctrl+Space and Shift+Enter to generate the code
    out->write(
      EXPORTING
        data   = itab
*        name   =
*      RECEIVING
*        output =
    ).




  ENDMETHOD.
ENDCLASS.
