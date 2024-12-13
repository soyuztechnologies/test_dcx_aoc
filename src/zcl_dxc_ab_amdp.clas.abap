CLASS zcl_dxc_ab_amdp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_amdp_marker_hdb .
    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS add_numbers IMPORTING value(x) TYPE i
                                        VALUE(y) TYPE i
                              EXPORTING
                                        value(res) TYPE i.
    CLASS-METHODS even_odd IMPORTING
                            VALUE(x) type i
                           EXPORTING
                            VALUE(res) type char10.

    CLASS-METHODS loop_example IMPORTING VALUE(times) type i
                               EXPORTING value(res) TYPE i
    .
    CLASS-METHODS array_example
                               EXPORTING value(res) TYPE char10
    .
    CLASS-METHODS cursor_with_array
                               IMPORTING VALUE(cat) type char10
                               EXPORTING value(otab) TYPE ZATS_AB_PRODUCT_TT
    .
    CLASS-METHODS working_with_itab
                               EXPORTING value(otab) TYPE ZATS_AB_PRODUCT_TT
    .

    class-METHODS get_customer_rank
                    for table FUNCTION ZDXC_AB_TF.

    class-METHODS anubhav
                    for scalar FUNCTION zget_mrp.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dxc_ab_amdp IMPLEMENTATION.

  METHOD loop_example BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY.

     --Conditional loop - while
     declare i integer;
     res := 0;

     for i in 1..:times do
        res := res + ( :i * 10 );
     END FOR ;

*     i = times;
*     res = 0;
*
*     while i > 0 do
*        res := res + :i;
*        i := :i - 1;
*     END WHILE ;

  ENDMETHOD.

  METHOD even_odd BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY.
    if mod( X, 2 ) = 0 then
        res = 'Even';
    ELSE
        res = 'Odd';
    END IF ;
  ENDMethod.
  METHOD add_numbers BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY .

    res := :x + :y ;

  ENDMETHOD.

  METHOD array_example BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY .

    ---we use declare statement like DATA statement in ABAP
    declare arr_int integer array := array( 3,2,1 );
    declare arr_fruits varchar( 10 ) array := array( 'Apple','Cherry','Banana' );

    ---fetch the data for that array
    res := :arr_fruits[:arr_int[2]];


  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    zcl_dxc_ab_amdp=>working_with_itab(
      IMPORTING
        otab = data(itab)
    ).


    out->write(
      EXPORTING
        data   = itab
*        name   =
*      RECEIVING
*        output =
    ).
  ENDMETHOD.

  METHOD cursor_with_array BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY USING zats_ab_product.

    DECLARE arr_pid nvarchar( 32 ) array;
    DECLARE arr_cat varchar( 10 ) array;
    DECLARE arr_name varchar( 256 ) array;
    DECLARE arr_price SMALLDECIMAL array;

    declare CURSOR cur_product for
        select product_id, name, category, price
        from zats_ab_product where category = :cat;

    --it will open cursor and start loop at record one by one
    for wa as cur_product do

       arr_pid[cur_product::rowcount] := wa.product_id;
       arr_cat[cur_product::rowcount] := wa.category;
       arr_name[cur_product::rowcount] := wa.name;
       arr_price[cur_product::rowcount] := wa.price * 1.18;

    end for;


    otab = unnest( :arr_pid, :arr_name, :arr_cat,  :arr_price )
                as ( product_id, name, category, price );


  ENDMETHOD.

  METHOD working_with_itab BY DATABASE PROCEDURE FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY USING zats_ab_product.

    declare lv_count integer;
    declare i integer;
    declare lv_price_d decimal( 10,2 );

    --Get all the products in an implicit table
    lt_products = select product_id, price, name, category from zats_ab_product;

    --Get the record count in the table
    lv_count := record_count( :lt_products );

    ---Loop at each of the record one by one
    for i in 1..:lv_count do

        ---Provide a flat discount of 5%
        if( :lt_products.price[i] > 1000 ) then
            lv_price_d := :lt_products.price[i] * 0.95;
        else
            lv_price_d := :lt_products.price[i] * 0.98;
        end if;

        if( :lt_products.category[i] = 'Software' ) then
            lv_price_d := :lv_price_d * 1.18;
        elseif( :lt_products.category[i] = 'PCs' ) then
            lv_price_d := :lv_price_d * 1.12;
        else
            lv_price_d := :lv_price_d * 1.06;
        end if;

        :otab.insert( ( :lt_products.product_id[i], :lt_products.name[i],
                        :lt_products.category[i], :lv_price_d ), i );
    END FOR ;

  ENDMETHOD.

  METHOD get_customer_rank BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY USING zats_ab_bpa zats_ab_so_hdr.

    return select bpa.client as client,
                  bpa.company_name as company_name,
                  sum( gross_amount ) as total_sales,
                  so.currency_code,
                  rank(  ) over ( order by sum( gross_amount ) desc ) as customer_rank
                from zats_ab_bpa as bpa
                inner join zats_ab_so_hdr as so
                on bpa.bp_id = so.buyer
                group by bpa.client,
                bpa.company_name, so.currency_code;

  ENDMETHOD.

  METHOD anubhav BY DATABASE FUNCTION FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY.

    if( category = 'PCs' ) then
        result = price * 1.18;
    else
        result = price * 1.10;
    END IF ;

  ENDMETHOD.

ENDCLASS.









