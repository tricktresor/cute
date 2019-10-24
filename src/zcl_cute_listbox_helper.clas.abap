CLASS zcl_cute_listbox_helper DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS get_listbox_for_fix_values
      IMPORTING
        domname              TYPE domname
        handle               TYPE i
        type                 TYPE zcute_field_display_type
      RETURNING
        VALUE(listbox_alias) TYPE lvc_t_dral.
ENDCLASS.



CLASS ZCL_CUTE_LISTBOX_HELPER IMPLEMENTATION.


  METHOD get_listbox_for_fix_values.
    DATA fix_values     TYPE STANDARD TABLE OF dd07v.

    CALL FUNCTION 'DD_DOMVALUES_GET'
      EXPORTING
        domname        = domname
        text           = 'X'
        langu          = sy-langu
      TABLES
        dd07v_tab      = fix_values
      EXCEPTIONS
        wrong_textflag = 1
        OTHERS         = 2.
    IF sy-subrc = 0.
      CASE type.
        WHEN 'LK'.
          listbox_alias = VALUE #( FOR value IN fix_values ( handle = handle int_value = value-domvalue_l value = value-domvalue_l ) ).
        WHEN 'LT'.
          listbox_alias = VALUE #( FOR value IN fix_values ( handle = handle int_value = value-domvalue_l value = value-ddtext ) ).
        WHEN 'LB'.
          listbox_alias = VALUE #( FOR value IN fix_values ( handle = handle int_value = value-domvalue_l value = |{ value-domvalue_l } { value-ddtext }| ) ).
      ENDCASE.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
