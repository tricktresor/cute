CLASS zcl_cute_source_info_view DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_cute_source_info.

    DATA header TYPE dd25v.
    DATA technical TYPE dd09l.
    DATA components TYPE STANDARD TABLE OF dd27p.
    DATA selection_criteria TYPE STANDARD TABLE OF dd28v.
    DATA joins TYPE STANDARD TABLE OF dd28j.
    DATA base_tables TYPE STANDARD TABLE OF dd26v.

ENDCLASS.



CLASS ZCL_CUTE_SOURCE_INFO_VIEW IMPLEMENTATION.


  METHOD zif_cute_source_info~get_field_info.

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
        IMPORTING
          dfies_wa       = fieldinfo-dfies
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc = 0.
        INSERT fieldinfo INTO TABLE zif_cute_source_info~fieldinfos.
      ENDIF.

    ENDIF.

  ENDMETHOD.


  METHOD zif_cute_source_info~read.

    zif_cute_source_info~class = 'VIEW'.
    zif_cute_source_info~name  = source.
    SELECT SINGLE * FROM zcute_tech INTO zif_cute_source_info~cute_tech WHERE typename = source.
    IF sy-subrc > 0.
      RAISE EXCEPTION TYPE zcx_cute_not_defined.
    ELSE.
      SELECT * FROM zcute_field INTO TABLE zif_cute_source_info~cute_fields
       WHERE typename = source.
    ENDIF.

    CALL FUNCTION 'DDIF_VIEW_GET'
      EXPORTING
        name          = zif_cute_source_info~name
        state         = 'A'
        langu         = sy-langu
      IMPORTING
        dd25v_wa      = header
        dd09l_wa      = technical
      TABLES
        dd26v_tab     = base_tables
        dd27p_tab     = components
        dd28j_tab     = joins
        dd28v_tab     = selection_criteria
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_cute_get_type.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
