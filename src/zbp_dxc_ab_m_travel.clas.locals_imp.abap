CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR travel RESULT result.
    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION travel~copytravel.
    METHODS recalctotalprice FOR MODIFY
      IMPORTING keys FOR ACTION travel~recalctotalprice.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR travel~calculatetotalprice.
    METHODS validateheaderdata FOR VALIDATE ON SAVE
      IMPORTING keys FOR travel~validateheaderdata.
    METHODS precheck_create FOR PRECHECK
      IMPORTING entities FOR CREATE travel.

    METHODS precheck_update FOR PRECHECK
      IMPORTING entities FOR UPDATE travel.
    METHODS earlynumbering_cba_bookings FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_bookings.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

     types:  t_entity_create type table for create ZDXC_AB_M_TRAVEL,
             t_entity_update TYPE table for update ZDXC_AB_M_TRAVEL,
             t_entity_rep type table for REPORTED ZDXC_AB_M_TRAVEL,
             t_entity_err type table for FAILED ZDXC_AB_M_TRAVEL.

    methods precheck_anubhav_reuse
        importing
            entities_u type t_entity_update optional
            entities_c type t_entity_create optional
         exporting
            reported type t_entity_rep
            failed type t_entity_err.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.


    data : ls_result like line of result.

    "Step 1: Get the data of my instance
    READ ENTITIES OF ZDXC_AB_M_TRAVEL in LOCAL MODE
        ENTITY travel
            fields ( travelid OverallStatus )
                WITH CORRESPONDING #( keys )
                    RESULT data(lt_travel)
                    FAILED data(ls_failed).

    "Step 2: loop at the data
    loop at lt_travel into data(ls_travel).

        "Step 3: Check if the instance was having status = cancelled
        if ( ls_travel-OverallStatus = 'X' ).
            data(lv_auth) = abap_false.

            "Step 4: Check for authorization in org
            """IF my user have auth object permission he/she is a manager
            AUTHORITY-CHECK OBJECT 'ZDXC_AB'
                ID 'ACTVT' FIELD '03' .

            IF sy-subrc = 0.
                lv_auth = abap_true.
            ENDIF.
        else.
            lv_auth = abap_true.
        ENDIF.

        ls_result = value #( TravelId = ls_travel-TravelId
                             %update = COND #( when lv_auth eq abap_false
                                                    then if_abap_behv=>auth-unauthorized
                                                    else    if_abap_behv=>auth-allowed
                                             )
                             %action-copyTravel = COND #( when lv_auth eq abap_false
                                                    then if_abap_behv=>auth-unauthorized
                                                    else    if_abap_behv=>auth-allowed
                                             )
        ).

        ""Finally send the result out to RAP
        APPEND ls_result to result.

    ENDLOOP.


  ENDMETHOD.

  METHOD earlynumbering_create.

    data: entity type STRUCTURE FOR CREATE ZDXC_AB_M_TRAVEL,
          travel_id_max type /dmo/travel_id.

    ""Step 1: Ensure that Travel id is not set for the record which is coming
    loop at entities into entity where TravelId is not initial.
        APPEND CORRESPONDING #( entity ) to mapped-travel.
    ENDLOOP.

    data(entities_wo_travelid) = entities.
    delete entities_wo_travelid where TravelId is not INITIAL.

    ""Step 2: Get the seuquence numbers from the SNRO
    try.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = CONV #( '/DMO/TRAVL' )
            quantity          =  conv #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = data(number_range_key)
            returncode        = data(number_range_return_code)
            returned_quantity = data(number_range_returned_quantity)
        ).
*        CATCH cx_nr_object_not_found.
*        CATCH cx_number_ranges.

      catch cx_number_ranges into data(lx_number_ranges).
        ""Step 3: If there is an exception, we will throw the error
        loop at entities_wo_travelid into entity.
            append value #( %cid = entity-%cid %key = entity-%key %msg = lx_number_ranges )
                to reported-travel.
            append value #( %cid = entity-%cid %key = entity-%key ) to failed-travel.
        ENDLOOP.
        exit.
    endtry.

    case number_range_return_code.
        when '1'.
            ""Step 4: Handle especial cases where the number range exceed critical %
            loop at entities_wo_travelid into entity.
                append value #( %cid = entity-%cid %key = entity-%key
                                %msg = new /dmo/cm_flight_messages(
                                            textid = /dmo/cm_flight_messages=>number_range_depleted
                                            severity = if_abap_behv_message=>severity-warning
                                ) )
                    to reported-travel.
            ENDLOOP.
        when '2' OR '3'.
            ""Step 5: The number range return last number, or number exhaused
            append value #( %cid = entity-%cid %key = entity-%key
                                %msg = new /dmo/cm_flight_messages(
                                            textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                            severity = if_abap_behv_message=>severity-warning
                                ) )
                    to reported-travel.
            append value #( %cid = entity-%cid
                            %key = entity-%key
                            %fail-cause = if_abap_behv=>cause-conflict
                             ) to failed-travel.
    ENDCASE.

    ""Step 6: Final check for all numbers
    ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).

    ""Step 7: Loop over the incoming travel data and asign the numbers from number range and
    ""        return MAPPED data which will then go to RAP framework
    travel_id_max = number_range_key - number_range_returned_quantity.

    loop at entities_wo_travelid into entity.

        travel_id_max += 1.
        entity-TravelId = travel_id_max.

        reported-%other = VALUE #( ( new_message_with_text(
                                 severity = if_abap_behv_message=>severity-success
                                 text     = 'Travel id has been created now!' ) ) ).

        append value #( %cid = entity-%cid
                        %is_draft = entity-%is_draft
                        %key = entity-%key ) to mapped-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Bookings.

    data max_booking_id type /dmo/booking_id.

    ""Step 1: get all the travel requests and their booking data
    read ENTITIES OF ZDXC_AB_M_TRAVEL in local mode
        ENTITY travel by \_Bookings
        from CORRESPONDING #( entities )
        link data(bookings).

    ""Loop at unique travel ids
    loop at entities ASSIGNING FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelId.
    ""Step 2: get the highest booking number which is already there
        loop at bookings into data(ls_booking) using key entity
            where source-TravelId = <travel_group>-TravelId.
                if max_booking_id < ls_booking-target-BookingId.
                    max_booking_id = ls_booking-target-BookingId.
                ENDIF.
        ENDLOOP.
    ""Step 3: get the asigned booking numbers for incoming request
        loop at entities into data(ls_entity) using key entity
            where TravelId = <travel_group>-TravelId.
                loop at ls_entity-%target into data(ls_target).
                    if max_booking_id < ls_target-BookingId.
                        max_booking_id = ls_target-BookingId.
                    ENDIF.
                ENDLOOP.
        ENDLOOP.
    ""Step 4: loop over all the entities of travel with same travel id
        loop at entities ASSIGNING FIELD-SYMBOL(<travel>)
            USING KEY entity where TravelId = <travel_group>-TravelId.
    ""Step 5: assign new booking IDs to the booking entity inside each travel
            LOOP at <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
                append CORRESPONDING #( <booking_wo_numbers> ) to mapped-booking
                ASSIGNING FIELD-SYMBOL(<mapped_booking>).
                if <mapped_booking>-BookingId is INITIAL.
                    max_booking_id += 10.
                    <mapped_booking>-BookingId = max_booking_id.
                ENDIF.
            ENDLOOP.
        ENDLOOP.
    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_features.

    ""Step 1: Read the data of selected travel request from EML
    "Step 1: Read the travel data with status
    READ ENTITIES OF ZDXC_AB_M_TRAVEL in local mode
        ENTITY travel
            FIELDS ( travelid overallstatus )
            with     CORRESPONDING #( keys )
        RESULT data(travels)
        FAILED failed.

    "Step 2: return the result with booking creation possible or not
    read table travels into data(ls_travel) index 1.

    if ( ls_travel-OverallStatus = 'X' ).
        data(lv_allow) = if_abap_behv=>fc-o-disabled.
    else.
        lv_allow = if_abap_behv=>fc-o-enabled.
    ENDIF.

    result = value #( for travel in travels
                        ( %tky = travel-%tky
                          %assoc-_Bookings = lv_allow
                        )
                    ).


  ENDMETHOD.

  METHOD copyTravel.


    data: travels type table for create ZDXC_AB_M_TRAVEL\\Travel,
          bookings_cba type table for create ZDXC_AB_M_TRAVEL\\Travel\_Bookings,
          booksuppl_cba type table for create ZDXC_AB_M_TRAVEL\\Booking\_Supplement.

    "Step 1: Remove the travel instances with initial %cid
    read table keys with key %cid = '' into data(key_with_initial_cid).
    ASSERT key_with_initial_cid is initial.

    "Step 2: Read all travel, booking and booking supplement using EML
    read entities of ZDXC_AB_M_TRAVEL in local mode
    entity Travel
        ALL FIELDS WITH CORRESPONDING #( keys )
        RESULT DATA(travel_read_result)
        FAILED failed.

    read entities of ZDXC_AB_M_TRAVEL in local mode
    entity Travel by \_Bookings
        ALL FIELDS WITH CORRESPONDING #( travel_read_result )
        RESULT DATA(book_read_result)
        FAILED failed.

    read entities of ZDXC_AB_M_TRAVEL in local mode
    entity booking by \_Supplement
        ALL FIELDS WITH CORRESPONDING #( book_read_result )
        RESULT DATA(booksuppl_read_result)
        FAILED failed.

    "Step 3: Fill travel internal table for travel data creation - %cid - abc123
    loop at travel_read_result ASSIGNING FIELD-SYMBOL(<travel>).

         "Travel data prepration
         append value #( %cid = keys[ %tky = <travel>-%tky ]-%cid
                        %data = CORRESPONDING #( <travel> except travelId )
         ) to travels ASSIGNING FIELD-SYMBOL(<new_travel>).

         <new_travel>-BeginDate = cl_abap_context_info=>get_system_date( ).
         <new_travel>-EndDate = cl_abap_context_info=>get_system_date( ) + 30.
         <new_travel>-OverallStatus = 'O'.

        "Step 3: Fill booking internal table for booking data creation - %cid_ref - abc123
        append value #( %cid_ref = keys[ key entity %tky = <travel>-%tky ]-%cid )
          to bookings_cba ASSIGNING FIELD-SYMBOL(<bookings_cba>).

        loop at  book_read_result ASSIGNING FIELD-SYMBOL(<booking>) where TravelId = <travel>-TravelId.

            append value #( %cid = keys[ key entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId
                            %data = CORRESPONDING #( book_read_result[ key entity %tky = <booking>-%tky ] EXCEPT travelid )
            )
                to <bookings_cba>-%target ASSIGNING FIELD-SYMBOL(<new_booking>).

            <new_booking>-BookingStatus = 'N'.

            "Step 4: Fill booking supplement internal table for booking suppl data creation
            append value #( %cid_ref = keys[ key entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId )
                    to booksuppl_cba ASSIGNING FIELD-SYMBOL(<booksuppl_cba>).

            loop at booksuppl_read_result ASSIGNING FIELD-SYMBOL(<booksuppl>)
                using KEY entity where TravelId = <travel>-TravelId and
                                       BookingId = <booking>-BookingId.

                append value #( %cid = keys[ key entity %tky = <travel>-%tky ]-%cid && <booking>-BookingId && <booksuppl>-BookingSupplementId
                            %data = CORRESPONDING #( <booksuppl> EXCEPT travelid bookingid )
                )
                to <booksuppl_cba>-%target.

            ENDLOOP.
        ENDLOOP.


    ENDLOOP.

    "Step 5: MODIFY ENTITY EML to create new BO instance using existing data
    MODIFY ENTITIES OF ZDXC_AB_M_TRAVEL IN LOCAL MODE
        ENTITY travel
            CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus )
                with travels
                    create by \_Bookings FIELDS ( Bookingid BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus )
                        with bookings_cba
                            ENTITY Booking
                                create by \_Supplement FIELDS ( bookingsupplementid supplementid price currencycode )
                                    WITH booksuppl_cba
        MAPPED data(mapped_create).

     mapped-travel = mapped_create-travel.


  ENDMETHOD.

  METHOD reCalcTotalPrice.


*    Define a structure where we can store all the booking fees and currency code
    TYPES : BEGIN OF ty_amount_per_currency,
              amount        TYPE /dmo/total_price,
              currency_code TYPE /dmo/currency_code,
            END OF ty_amount_per_currency.

    DATA : amounts_per_currencycode TYPE STANDARD TABLE OF ty_amount_per_currency.

*    Read all travel instances, subsequent bookings using EML
    READ ENTITIES OF ZDXC_AB_M_TRAVEL IN LOCAL MODE
       ENTITY Travel
       FIELDS ( BookingFee CurrencyCode )
       WITH CORRESPONDING #( keys )
       RESULT DATA(travels).

    READ ENTITIES OF ZDXC_AB_M_TRAVEL IN LOCAL MODE
       ENTITY Travel BY \_Bookings
       FIELDS ( FlightPrice CurrencyCode )
       WITH CORRESPONDING #( travels )
       RESULT DATA(bookings).

    READ ENTITIES OF ZDXC_AB_M_TRAVEL IN LOCAL MODE
       ENTITY Booking BY \_Supplement
       FIELDS ( price CurrencyCode )
       WITH CORRESPONDING #( bookings )
       RESULT DATA(bookingsupplements).

*    Delete the values w/o any currency
    DELETE travels WHERE CurrencyCode IS INITIAL.
    DELETE bookings WHERE CurrencyCode IS INITIAL.
    DELETE bookingsupplements WHERE CurrencyCode IS INITIAL.

*    Total all booking and supplement amounts which are in common currency
    LOOP AT travels ASSIGNING FIELD-SYMBOL(<travel>).
      "Set the first value for total price by adding the booking fee from header
      amounts_per_currencycode = VALUE #( ( amount = <travel>-BookingFee
                                          currency_code = <travel>-CurrencyCode ) ).

*    Loop at all amounts and compare with target currency
      LOOP AT bookings INTO DATA(booking) WHERE TravelId = <travel>-TravelId.

        COLLECT VALUE ty_amount_per_currency( amount = booking-FlightPrice
                                              currency_code = booking-CurrencyCode
        ) INTO amounts_per_currencycode.

      ENDLOOP.

      LOOP AT bookingsupplements INTO DATA(bookingsupplement) WHERE TravelId = <travel>-TravelId.

        COLLECT VALUE ty_amount_per_currency( amount = bookingsupplement-Price
                                              currency_code = booking-CurrencyCode
        ) INTO amounts_per_currencycode.

      ENDLOOP.

      CLEAR <travel>-TotalPrice.
*    Perform currency conversion
      LOOP AT amounts_per_currencycode INTO DATA(amount_per_currencycode).

        IF amount_per_currencycode-currency_code = <travel>-CurrencyCode.
          <travel>-TotalPrice += amount_per_currencycode-amount.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = amount_per_currencycode-amount
              iv_currency_code_source = amount_per_currencycode-currency_code
              iv_currency_code_target = <travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = DATA(total_booking_amt)
          ).

          <travel>-TotalPrice = <travel>-TotalPrice + total_booking_amt.
        ENDIF.

      ENDLOOP.
*    Put back the total amount

    ENDLOOP.
*    Return the total amount in mapped so the RAP will modify this data to DB
    MODIFY ENTITIES OF    ZDXC_AB_M_TRAVEL IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( travels ).

  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF ZDXC_AB_M_TRAVEL IN LOCAL MODE
        ENTITY travel
            EXECUTE reCalcTotalPrice
            FROM CORRESPONDING #( keys ).

  ENDMETHOD.

  METHOD validateHeaderData.

    "Step 1: Read the travel data
    read entities of ZDXC_AB_M_TRAVEL in local mode
        ENTITY travel
        FIELDS ( CustomerId BeginDate )
        WITH CORRESPONDING #( keys )
        RESULT data(lt_travel).

    "Step 2: Declare a sorted table for holding customer ids
    data customers type SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    "Step 3: Extract the unique customer IDs in our table
    customers = CORRESPONDING #( lt_travel discarding duplicates mapping
                                       customer_id = CustomerId EXCEPT *
     ).
    delete customers where customer_id is INITIAL.

    ""Get the validation done to get all customer ids from db
    ""these are the IDs which are present
    if customers is not initial.

        select from /dmo/customer FIELDS customer_id
        FOR ALL ENTRIES IN @customers
        where customer_id = @customers-customer_id
        into table @data(lt_cust_db).

    ENDIF.

    ""loop at travel data
    loop at lt_travel into data(ls_travel).

        if ( ls_travel-BeginDate < cl_abap_context_info=>get_system_date( ) ).

            ""Inform the RAP framework to terminate the create
            append value #( %tky = ls_travel-%tky ) to failed-travel.
            append value #( %tky = ls_travel-%tky
                            %element-customerid = if_abap_behv=>mk-on
                            %msg = new /dmo/cm_flight_messages(
                                          textid                = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                          begin_date = ls_travel-BeginDate
                                          severity              = if_abap_behv_message=>severity-error

            )
            ) to reported-travel.

        ENDIF.

        if ( ls_travel-CustomerId is initial OR
             NOT  line_exists(  lt_cust_db[ customer_id = ls_travel-CustomerId ] ) ).

            ""Inform the RAP framework to terminate the create
            append value #( %tky = ls_travel-%tky ) to failed-travel.
            append value #( %tky = ls_travel-%tky
                            %element-customerid = if_abap_behv=>mk-on
                            %msg = new /dmo/cm_flight_messages(
                                          textid                = /dmo/cm_flight_messages=>customer_unkown
                                          customer_id           = ls_travel-CustomerId
                                          severity              = if_abap_behv_message=>severity-error

            )
            ) to reported-travel.

        ENDIF.

    ENDLOOP.
  ENDMETHOD.
 METHOD precheck_create.

    precheck_anubhav_reuse(
      EXPORTING
*        entities_u =
         entities_c = entities
      IMPORTING
        reported   = reported-travel
        failed     = failed-travel
    ).

  ENDMETHOD.

  METHOD precheck_update.

    precheck_anubhav_reuse(
      EXPORTING
          entities_u = entities
*         entities_c =
      IMPORTING
        reported   = reported-travel
        failed     = failed-travel
    ).

  ENDMETHOD.

  METHOD precheck_anubhav_reuse.

    ""Step 1: Data declaration
    data: entities type t_entity_update,
           operation type if_abap_behv=>t_char01,
           agencies type sorted table of /dmo/agency WITH UNIQUE KEY agency_id,
           customers type sorted table of /dmo/customer WITH UNIQUE key customer_id.

    ""Step 2: Check either entity_c was passed or entity_u was passed
    ASSERT not ( entities_c is initial equiv entities_u is initial ).

    ""Step 3: Perform validation only if agency OR customer was changed
    if entities_c is not initial.
        entities = CORRESPONDING #( entities_c ).
        operation = if_abap_behv=>op-m-create.
    else.
        entities = CORRESPONDING #( entities_u ).
        operation = if_abap_behv=>op-m-update.
    ENDIF.

    delete entities where %control-AgencyId = if_abap_behv=>mk-off and %control-CustomerId = if_abap_behv=>mk-off.

    ""Step 4: get all the unique agencies and customers in a table
    agencies = CORRESPONDING #( entities discarding DUPLICATES MAPPING agency_id = AgencyId EXCEPT * ).
    customers = CORRESPONDING #( entities discarding DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).

    ""Step 5: Select the agency and customer data from DB tables
    select from /dmo/agency fields agency_id, country_code
    for all ENTRIES IN @agencies where agency_id = @agencies-agency_id
    into table @data(agency_country_codes).

    select from /dmo/customer fields customer_id, country_code
    for all ENTRIES IN @customers where customer_id = @customers-customer_id
    into table @data(customer_country_codes).

    ""Step 6: Loop at incoming entities and compare each agency and customer country
    loop at entities into data(entity).
        read table agency_country_codes with key agency_id = entity-AgencyId into data(ls_agency).
        CHECK sy-subrc = 0.
        read table customer_country_codes with key customer_id = entity-CustomerId into data(ls_customer).
        CHECK sy-subrc = 0.
        if ls_agency-country_code <> ls_customer-country_code.
            ""Step 7: if country doesnt match, throw the error
            append value #(    %cid = cond #( when operation = if_abap_behv=>op-m-create then entity-%cid_ref )
                                      %is_draft = entity-%is_draft
                                      %fail-cause = if_abap_behv=>cause-conflict
              ) to failed.

            append value #(    %cid = cond #( when operation = if_abap_behv=>op-m-create then entity-%cid_ref )
                                      %is_draft = entity-%is_draft
                                      %msg = new /dmo/cm_flight_messages(
                                                                                              textid                = value #(
                                                                                                                                     msgid = 'SY'
                                                                                                                                     msgno = 499
                                                                                                                                     attr1 = 'The country codes for agency and customer not matching'
                                                                                                                                  )
                                                                                              agency_id             = entity-AgencyId
                                                                                              customer_id           = entity-CustomerId
                                                                                              severity  = if_abap_behv_message=>severity-error
                                                                                            )
                                      %element-agencyid = if_abap_behv=>mk-on
              ) to reported.

        ENDIF.
    ENDLOOP.


  ENDMETHOD.

ENDCLASS.
