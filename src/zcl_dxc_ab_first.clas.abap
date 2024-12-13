CLASS zcl_dxc_ab_first DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
    CLASS-METHODS: s1_inline_declaration IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS: s1_value_expression IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS: s1_corresponding_data IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS: s1_constructor_expression IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS: s1_table_expression IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS : s1_cond_conv_exp IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS : s1_loop_with_grouping IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    class-METHODS : s1_loop_with_single_line IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    class-METHODS : s1_loop_reduce_statement IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    CLASS-METHODS : s1_using_key_expression IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    class-METHODS : s2_sql_new_features IMPORTING  out TYPE REF TO if_oo_adt_classrun_out.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_DXC_AB_FIRST IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    "zcl_dxc_ab_first=>s1_inline_declaration( out = out ).
    "zcl_dxc_ab_first=>s1_value_expression( out = out ).
    "zcl_dxc_ab_first=>s1_corresponding_data( out = out ).
    "zcl_dxc_ab_first=>s1_constructor_expression( out = out ).
    "zcl_dxc_ab_first=>s1_table_expression( out = out ).
    "zcl_dxc_ab_first=>s1_cond_conv_exp( out = out ).
    "zcl_dxc_ab_first=>s1_loop_with_grouping( EXPORTING out = out ).
    "zcl_dxc_ab_first=>s1_loop_reduce_statement( EXPORTING out = out ).
    "zcl_dxc_ab_first=>s1_using_key_expression( EXPORTING out = out ).
    zcl_dxc_ab_first=>s2_sql_new_features( out = out ).


    ""Ctrl+Space is your best friend for code completion
    ""Shift+Enter to generate code
    ""TO print on console we use the out parameter provided by SAP
    ""PRess F9 key to test the program/class

    ""Ctrl+7 to comment and uncomment the block of code
*    out->write(
*      EXPORTING
*        data   = 'Hello ABAP Cloud Developer'
**        name   =
**      RECEIVING
**        output =
*    ).

  ENDMETHOD.


  METHOD s1_cond_conv_exp.

    DATA : lv_numc TYPE decan VALUE '0900',
           lv_num  TYPE i,
           lv_res  TYPE c.

    ""used for type casting for matching data types
    lv_num = CONV #( lv_numc ).

    "to check a simple condition - inline with program code
    lv_res = COND #( LET val = 800 IN
                      WHEN lv_num > val THEN 'X'
                      ELSE '' ) .

    ""WRITE : / 'result is ', lv_res.
    out->write(
                 EXPORTING
                   data   = lv_res
*                    name   =
*                  RECEIVING
*                    output =
                ).
  ENDMETHOD.


  METHOD s1_constructor_expression.

    DATA(lo_obj) = NEW /dmo/cm_flight_messages(
      textid                = VALUE #( msgid = 'SY' msgno = 499 )
      severity              = if_abap_behv_message=>severity-error
    ).

*    data: lo_obj type ref to /dmo/cm_flight_messages.
*    create object lo_obj
*      EXPORTING
*        textid                =  value #( msgid = 'SY' msgno = 499 )
*        severity              = if_abap_behv_message=>severity-error
*      .

  ENDMETHOD.


  METHOD s1_corresponding_data.

    TYPES: BEGIN OF ty_game,
             captain TYPE c LENGTH 10,
             team    TYPE c LENGTH 10,
             score   TYPE i,
           END OF ty_game,
           tt_game TYPE TABLE OF ty_game WITH DEFAULT KEY,
           BEGIN OF ty_game2,
             scrumlead TYPE c LENGTH 10,
             scrum     TYPE c LENGTH 10,
             goals     TYPE i,
           END OF ty_game2,
           tt_game2 TYPE TABLE OF ty_game2 WITH DEFAULT KEY.

    DATA : lt_game2 TYPE tt_game2.

    DATA(lt_game) = VALUE tt_game( ( captain = 'Dhoni'
                         team = 'CSK'
                         score = 100 )
                         ( captain = 'Virat'
                         team = 'RCB'
                         score = 90 )
                         ( captain = 'Dravid'
                         team = 'MIM'
                         score = 120 ) ).

*MOVE-CORRESPONDING source TO target.



*     lt_game2 = CORRESPONDING #( lt_game EXCEPT score ).
    lt_game2 = CORRESPONDING #( lt_game MAPPING
                                       scrumlead = captain
                                       scrum = team
                                       goals = score
                               ).

*     APPEND CORRESPONDING #( str ) to itab2.

    out->write(
              EXPORTING
                data   = lt_game2
*                    name   =
*                  RECEIVING
*                    output =
             ).


*     loop at lt_game2 into data(ls_game).
*       "" WRITE : / ls_game-scrumlead, ls_game-scrum, ls_game-goals.
*       out->write(
*                  EXPORTING
*                    data   = ls_game
**                    name   =
**                  RECEIVING
**                    output =
*                 ).
*     ENDLOOP.

  ENDMETHOD.


  METHOD s1_inline_declaration.

    "-----Old Approach
*    data: lt_travel type table of /dmo/travel,
*          ls_travel type /dmo/travel.
*
*    select * from /dmo/travel into table lt_travel.
*
*    loop at lt_mara into ls_mara.
*         WRITE : / ls_travel-travel_id, ls_travel-customer_id.
*    ENDLOOP.

    "-----New Approach
    SELECT travel_id, customer_id FROM /dmo/travel INTO TABLE @DATA(lt_bp) UP TO 10 ROWS.

*    loop at lt_travel into data(ls_travel).
*        WRITE : / ls_travel-travel_id, ls_travel-customer_id.
*    ENDLOOP.

    LOOP AT lt_bp ASSIGNING FIELD-SYMBOL(<fs>).
      out->write(
                EXPORTING
                  data   = <fs>
*                    name   =
*                  RECEIVING
*                    output =
               ).
    ENDLOOP.

    cl_uuid_factory=>create_system_uuid(  )->create_uuid_c32(
      RECEIVING
        uuid = DATA(lv_uuid)
    ).

    out->write(
                  EXPORTING
                    data   = lv_uuid
*                    name   =
*                  RECEIVING
*                    output =
                 ).

  ENDMETHOD.


  METHOD s1_loop_reduce_statement.

    types: tt_bookings type table of /dmo/booking WITH DEFAULT KEY.

    data lv_total type p DECIMALS 2.

    select * from /dmo/booking into table @data(lt_bookings) UP TO 20 rows.

*    loop at lt_bookings into data(ls_bookings).
*        lv_total = lv_total + ls_bookings-flight_price.
*    ENDLOOP.

    lv_total = REDUCE decan( INIT x = conv decan( 0 )
                                for ls_bookings in lt_bookings
                             NEXT x = x + ls_bookings-flight_price
    ).

    ""WRITE : / lv_total.
    out->write(
          EXPORTING
            data   = lv_total
*            name   =
*          RECEIVING
*            output =
        ).

  ENDMETHOD.


  METHOD s1_loop_with_grouping.

    TYPES: tt_bookings TYPE TABLE OF /dmo/booking WITH DEFAULT KEY.
    DATA : lv_total TYPE p DECIMALS 2.

    SELECT * FROM /dmo/booking INTO TABLE @DATA(lt_bookings) UP TO 20 ROWS.

    "grouping data by a key
    LOOP AT lt_bookings INTO DATA(ls_bookings) GROUP BY ls_bookings-travel_id.

      ""WRITE : / 'Travel Request' , ls_bookings-travel_id.
      ""WRITE : / 'Bookings :' .
      out->write(
        EXPORTING
          data   = | 'Travel Request'  { ls_bookings-travel_id } |
*            name   =
*          RECEIVING
*            output =
      ).

      DATA(lt_grp_book) = VALUE tt_bookings(  ).

      ""loop at all the child of that group
      LOOP AT GROUP ls_bookings INTO DATA(ls_child_rec).
        "append lines of itab1 to itab2.
        lt_grp_book = VALUE #( BASE lt_grp_book ( ls_child_rec ) ).

        ""WRITE : /(5) ls_child_rec-booking_id, ls_child_rec-carrier_id, ls_child_rec-flight_price.
        out->write(
              EXPORTING
                data   = ls_child_rec
*                    name   =
*                  RECEIVING
*                    output =
             ).

        lv_total = lv_total + ls_child_rec-flight_price.

      ENDLOOP.

      "WRITE : / 'Total Value of the Bookings :' , lv_total.
      out->write(
                EXPORTING
                  data   = lv_total
*                    name   =
*                  RECEIVING
*                    output =
               ).
      CLEAR : lv_total.
    ENDLOOP.


  ENDMETHOD.


  METHOD s1_loop_with_single_line.

    types: tt_bookings type table of /dmo/booking WITH DEFAULT KEY.
    data : lv_total type p DECIMALS 2.

    types: BEGIN OF ty_final_booking.
            INCLUDE type  /dmo/booking.
    TYPes: booking_tx TYPE p LENGTH 10 DECIMALS 2,
           END OF ty_final_booking,
           tt_final_booking type table of ty_final_booking WITH DEFAULT KEY.

    data: lv_gst type p DECIMALS 2.

    lv_gst = '1.12'.

    select * from /dmo/booking into table @data(lt_bookings) UP TO 20 rows.

    data(lt_final_booking) = value tt_final_booking( FOR wa IN lt_bookings (
                                travel_id =  wa-travel_id
                                booking_id = wa-booking_id
                                flight_price = wa-flight_price
                                booking_tx = cond #( when wa-flight_price > 430
                                                then wa-flight_price * lv_gst
                                                else wa-flight_price
                                             )
                              ) ).

    loop at lt_final_booking into data(ls_booking).
*        WRITE : / ls_booking-travel_id, ls_booking-booking_id, ls_booking-flight_price,
*                  ls_booking-booking_tx.
        out->write(
          EXPORTING
            data   = ls_booking
*            name   =
*          RECEIVING
*            output =
        ).
    ENDLOOP.

*    loop at lt_bookings into wa.
*         ---IF condition
*        ---calculations lv_amt = lv_gst * wa-booking_amt.
*        ---move corresponding wa to wa2
*        ---wa2-booking_tx = lv_amt
*        ---apend wa2 to itab2
*    endloop.


  ENDMETHOD.


  METHOD s1_table_expression.

    DATA : itab TYPE TABLE OF /dmo/booking WITH DEFAULT KEY.

    SELECT *  FROM /dmo/booking INTO TABLE @itab UP TO 20 ROWS.

    ""Read table itab into data(wa) with key travel_id = ''.
    IF NOT line_exists( itab[ travel_id = '00000001' ]  ).
      "" WRITE : / 'oops the record was not found'.
      out->write(
        EXPORTING
          data   = 'No Record was found'
*            name   =
*          RECEIVING
*            output =
      ).
      EXIT.
    ENDIF.

    DATA(wa) = itab[ travel_id = '00000001' ].

    ""WRITE : / wa-travel_id, wa-booking_date, wa-booking_id, wa-connection_id, wa-carrier_id.
    out->write(
       EXPORTING
         data   = wa
*            name   =
*          RECEIVING
*            output =
     ).

    DATA(lv_field) = itab[ travel_id = '00000001' ]-flight_price.
    out->write(
       EXPORTING
         data   = lv_field
*            name   =
*          RECEIVING
*            output =
     ).

  ENDMETHOD.


  METHOD s1_using_key_expression.

    data : itab TYPE SORTED TABLE OF /dmo/booking
                                                WITH UNIQUE KEY travel_id booking_id
                                                WITH NON-UNIQUE SORTED KEY spiderman COMPONENTS carrier_id connection_id.

    select *  from /dmo/booking  into table @itab.

    ""Table expression
    data(wa) = itab[ key spiderman carrier_id = 'AA' connection_id = 0322 ]   .

    ""Loop at itab
    loop at itab REFERENCE INTO data(lo_line) USING KEY spiderman WHERE carrier_id = 'AA'.
        out->write(
          EXPORTING
            data   = | Anubhav Data:  { lo_line->carrier_id } { lo_line->connection_id } |
*            name   =
*          RECEIVING
*            output =
        ).
    ENDLOOP.

  ENDMETHOD.


  METHOD s1_value_expression.

    TYPES: BEGIN OF ty_game,
             captain TYPE c LENGTH 10,
             team    TYPE c LENGTH 10,
             score   TYPE i,
           END OF ty_game,
           tt_game TYPE TABLE OF ty_game WITH DEFAULT KEY.

*    data: lt_game type  tt_game,
*          ls_game type  ty_game.

    DATA(lt_game) = VALUE tt_game( ( captain = 'Dhoni'
                         team = 'CSK'
                         score = 100 )
                         ( captain = 'Virat'
                         team = 'RCB'
                         score = 90 )
                         ( captain = 'Dravid'
                         team = 'MIM'
                         score = 120 ) ).

*    ls_game-captain = 'Dhoni'.
*    ls_game-team = 'CSK'.
*    ls_game-score = 100.
*    append ls_game to lt_game.
*
*    ls_game-captain = 'Virat'.
*    ls_game-team = 'RCB'.
*    ls_game-score = 80.
*    append ls_game to lt_game.
*
*    ls_game-captain = 'Dravid'.
*    ls_game-team = 'MUM'.
*    ls_game-score = 120.
*    append ls_game to lt_game.

    LOOP AT lt_game INTO DATA(ls_game).
      "" WRITE : / ls_game-captain, ls_game-team, ls_game-score.
      out->write(
                 EXPORTING
                   data   = ls_game
*                    name   =
*                  RECEIVING
*                    output =
                ).
    ENDLOOP.






  ENDMETHOD.


  METHOD s2_sql_new_features.

    "SELECT 'Mr' && ' ' && first_name as name_cust from /dmo/customer into table @data(itab).

*    SELECT concat( title, first_name ) as name_cust,
*           case country_code
*            when 'DE' then 'High'
*            else 'Low'
*            end as priority
*     from /dmo/customer into table @data(itab).

    select booking_fee, case
            when booking_fee > 100 then 'Costly'
            when booking_fee > 30 and  booking_fee <= 100 then 'Moderate'
            else 'Cheaper'
            end as ticket_type
            from /dmo/travel into table @data(itab) up to 50 rows.

    select ticket_type, sum( booking_fee ) as total_fee
            from @itab as anubhav
            group by ticket_type
             into table @data(ktab).


*    select customer_id, sum( booking_fee ) as total_fees
*                from /dmo/travel  group by customer_id
*                having sum( booking_fee ) > 2000
*                into table @data(itab) .



    out->write(
      EXPORTING
        data   = ktab
*        name   =
*      RECEIVING
*        output =
    ).



  ENDMETHOD.
ENDCLASS.
