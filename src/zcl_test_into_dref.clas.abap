CLASS zcl_test_into_dref DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF _order,
             vbeln TYPE vbap-vbeln,
             posnr TYPE vbap-posnr,
             matnr TYPE vbap-matnr,
             bzirk TYPE vbkd-bzirk,
           END OF _order,
           _orders TYPE STANDARD TABLE OF _order WITH DEFAULT KEY.

    METHODS go
      RETURNING
        VALUE(result) TYPE _orders.

  PRIVATE SECTION.
    METHODS select_vbap
      IMPORTING
        i_vbeln       TYPE vbap-vbeln
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS select_vbkd
      IMPORTING
        i_vbeln       TYPE vbap-vbeln
      RETURNING
        VALUE(result) TYPE REF TO data.

    METHODS assign_local_table_to_result
      IMPORTING
        i_table       TYPE ANY TABLE
      RETURNING
        VALUE(result) TYPE REF TO data.

ENDCLASS.


CLASS zcl_test_into_dref IMPLEMENTATION.
  METHOD go.
    DATA(dref_vbap) = select_vbap( '0000000001' ).
    DATA(dref_vbkd) = select_vbkd( '0000000001' ).

    FIELD-SYMBOLS <generic_table> TYPE ANY TABLE.
    ASSIGN dref_vbap->* TO <generic_table>.

    result = CORRESPONDING #( <generic_table> ).

    ASSIGN dref_vbkd->* TO <generic_table>.
    result = CORRESPONDING #( DEEP <generic_table> ).

*    loop at all_orders ASSIGNING FIELD-SYMBOL(<order>).
*      <order> = CORRESPONDING #( deep <generic_table> ).
**      <order> = CORRESPONDING #( BASE ( <order> ) <generic_table>[ vbeln = <order>-vbeln posnr = <order>-posnr ] ).
*    endloop.
  ENDMETHOD.

  METHOD select_vbap.
    SELECT vbeln, posnr, matnr FROM vbap
      INTO TABLE @DATA(t_vbap)
      WHERE vbeln = @i_vbeln.

    result = assign_local_table_to_result( t_vbap ).
  ENDMETHOD.

  METHOD select_vbkd.
    SELECT vbeln, posnr, bzirk FROM vbkd
      INTO TABLE @DATA(t_vbkd)
      WHERE vbeln = @i_vbeln.

    result = assign_local_table_to_result( t_vbkd ).
  ENDMETHOD.

  METHOD assign_local_table_to_result.
    FIELD-SYMBOLS <result> TYPE ANY TABLE.

    DATA(tab_info) = CAST cl_abap_tabledescr( cl_abap_typedescr=>describe_by_data(
                                                  i_table ) ).
    TRY.
        DATA(tab) = cl_abap_tabledescr=>create(
                        p_line_type  = tab_info->get_table_line_type( )
                        p_table_kind = cl_abap_tabledescr=>tablekind_std  ).
        CREATE DATA result TYPE HANDLE tab.
        ASSIGN result->* TO <result>.
        <result> = i_table.
      CATCH cx_sy_table_creation ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
