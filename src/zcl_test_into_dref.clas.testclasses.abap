CLASS testclass DEFINITION FINAL
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.

  PRIVATE SECTION.
    DATA environment TYPE REF TO if_osql_test_environment.
    DATA cut         TYPE REF TO zcl_test_into_dref.

    METHODS setup.
    METHODS teardown.
    METHODS one FOR TESTING.
ENDCLASS.


CLASS testclass IMPLEMENTATION.
  METHOD one.
    DATA t_vbap TYPE TABLE OF vbap.
    DATA t_vbkd TYPE TABLE OF vbkd.

    t_vbap = VALUE #( vbeln = '0000000001'
                      ( posnr = '000010' matnr = 'MAT001' )
                      ( posnr = '000020' matnr = 'MAT002' ) ).

    environment->insert_test_data( t_vbap ).

    t_vbkd = VALUE #( vbeln = '0000000001'
                      ( posnr = '000010' bzirk = '000001' )
                      ( posnr = '000020' bzirk = '000002' ) ).
    environment->insert_test_data( t_vbkd ).

    DATA(result) = cut->go( ).
    cl_abap_unit_assert=>assert_equals( exp = 2
                                        act = lines( result )
                                        msg = 'record count mismatch' ).

    cl_abap_unit_assert=>assert_equals(
        exp = VALUE zcl_test_into_dref=>_orders(
                        vbeln = '0000000001'
                        ( posnr = '000010' matnr = 'MAT001' bzirk = '000001' )
                        ( posnr = '000020' matnr = 'MAT002' bzirk = '000002' ) )
        act = result
        msg = 'data incorrect' ).
  ENDMETHOD.

  METHOD setup.
    environment = cl_osql_test_environment=>create(
                      VALUE #( ( 'VBAP' ) ( 'VBKD' ) ) ).
    cut = NEW #( ).
  ENDMETHOD.

  METHOD teardown.
    environment->clear_doubles( ).
  ENDMETHOD.
ENDCLASS.
