class ZCL_CUTE_SOURCE_INFO_TABL definition
  public
  final
  create public .

public section.

  interfaces ZIF_CUTE_SOURCE_INFO .

  data HEADER type DD02V .
  data TECHNICAL type DD09V .
  data:
    components TYPE STANDARD TABLE OF dd03p .
ENDCLASS.



CLASS ZCL_CUTE_SOURCE_INFO_TABL IMPLEMENTATION.


  METHOD zif_cute_source_info~get_field_info.

    DATA dfies_table TYPE STANDARD TABLE OF dfies.

    READ TABLE zif_cute_source_info~fieldinfos WITH TABLE KEY fieldname = fieldname INTO fieldinfo.
    IF sy-subrc > 0.
      fieldinfo-fieldname = fieldname.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = zif_cute_source_info~name
          fieldname      = CONV fieldname( fieldname )
          langu          = sy-langu
          all_types      = 'X'
          group_names    = ' '
          do_not_write   = 'X'
        TABLES
          dfies_tab      = dfies_table
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        "dfies dictionary definition
        READ TABLE dfies_table INTO fieldinfo-dfies INDEX 1.
        IF sy-subrc > 0.
          fieldinfo-dfies-fieldname = '%%%'.
        ENDIF.
        "get cute definition
        READ TABLE zif_cute_source_info~cute_fields INTO fieldinfo-cute WITH TABLE KEY fieldname = fieldname.
        IF sy-subrc > 0.
          fieldinfo-cute-fieldname = '%%%'.
        ENDIF.
        "insert field information
        INSERT fieldinfo INTO TABLE zif_cute_source_info~fieldinfos.

      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD zif_cute_source_info~read.

    DATA source_name TYPE typename.
    zif_cute_source_info~class = 'TRANSP'.
    zif_cute_source_info~name  = source.

    SELECT SINGLE * FROM zcute_tech INTO zif_cute_source_info~cute_tech WHERE typename = source.
    IF sy-subrc > 0.
      RAISE EXCEPTION TYPE zcx_cute_not_defined.
    ELSE.
      SELECT * FROM zcute_field INTO TABLE zif_cute_source_info~cute_fields
       WHERE typename = source.
    ENDIF.

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = zif_cute_source_info~name
        state         = 'A'
        langu         = sy-langu
      IMPORTING
        dd02v_wa      = header
      TABLES
        dd03p_tab     = components
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc > 0.
      RAISE EXCEPTION TYPE zcx_cute_get_type.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
