class ZCL_CUTE_LISTBOX_HELPER definition
  public
  final
  create public .

public section.

  class-methods GET_LISTBOX_FOR_FIX_VALUES
    importing
      !DOMNAME type DOMNAME
      !HANDLE type I
      !TYPE type ZCUTE_FIELD_DISPLAY_TYPE
      !OBLIGATORY type FLAG optional
    returning
      value(LISTBOX_ALIAS) type LVC_T_DRAL .
protected section.
private section.
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
        WHEN 'LK'. "Listbox only key
          listbox_alias = VALUE #( FOR value IN fix_values ( handle = handle int_value = value-domvalue_l value = value-domvalue_l ) ).
        WHEN 'LT'. "Listbox only text
          listbox_alias = VALUE #( FOR value IN fix_values ( handle = handle int_value = value-domvalue_l value = value-ddtext ) ).
        WHEN 'LB'. "Listbox key + text
          listbox_alias = VALUE #( FOR value IN fix_values ( handle = handle int_value = value-domvalue_l value = |{ value-domvalue_l } { value-ddtext }| ) ).
      ENDCASE.
      IF obligatory IS INITIAL.
        "insert initial value
        INSERT VALUE #( handle = handle int_value = space value = space ) INTO listbox_alias INDEX 1.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
