CLASS zcl_cute_source_info_tabl DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_cute_source_info .

    DATA header TYPE dd02v .
    DATA technical TYPE dd09v .
    DATA:
      components TYPE STANDARD TABLE OF dd03p WITH DEFAULT KEY.
protected section.
private section.
ENDCLASS.



CLASS ZCL_CUTE_SOURCE_INFO_TABL IMPLEMENTATION.


  METHOD zif_cute_source_info~determine_text_table.

    DATA texttable TYPE tabname.
    DATA checkfield TYPE dd08v-fieldname.

    "Get texttable for current table
    CALL FUNCTION 'DDUT_TEXTTABLE_GET'
      EXPORTING
        tabname    = zif_cute_source_info~name
      IMPORTING
        texttable  = texttable
        checkfield = checkfield.

    IF texttable IS NOT INITIAL.
      "store info in internal table
      INSERT VALUE #( name = texttable )
      INTO TABLE zif_cute_source_info~text_tables
      ASSIGNING FIELD-SYMBOL(<texttable>).
    ENDIF.

    "Now get all fields of the text table
    DATA dfies_table TYPE STANDARD TABLE OF dfies.

    CALL FUNCTION 'DDIF_FIELDINFO_GET'
      EXPORTING
        tabname        = texttable
        fieldname      = space
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
      LOOP AT dfies_table INTO DATA(dfies).
        IF dfies-keyflag = abap_true.
          "add key fields
          APPEND dfies-fieldname TO <texttable>-keyfields.
        ELSE.
          "first non-key field should be the description field
          <texttable>-description = dfies.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.


  METHOD zif_cute_source_info~get_field_info.

    DATA dfies_table TYPE STANDARD TABLE OF dfies.

    READ TABLE zif_cute_source_info~fieldinfos
    WITH TABLE KEY fieldname = fieldname INTO fieldinfo.
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


  METHOD zif_cute_source_info~get_text_table.

    " nothing to do if no text table specified
    CHECK zif_cute_source_info~text_tables IS NOT INITIAL.

    IF name IS INITIAL.
      " texttable is not initial: for TABL there is only 1 (if there is)
      texttable = zif_cute_source_info~text_tables[ 1 ].
    ELSE.
      " if table name specified, then use it for access
      READ TABLE zif_cute_source_info~text_tables
      INTO texttable WITH TABLE KEY name = name.
    ENDIF.

  ENDMETHOD.


  METHOD zif_cute_source_info~read.

    DATA source_name TYPE typename.
    zif_cute_source_info~class = 'TRANSP'.
    zif_cute_source_info~name  = source.

    "read technical cute settings
    SELECT SINGLE * FROM zcute_tech INTO zif_cute_source_info~cute_tech WHERE typename = source.
    IF sy-subrc > 0.
      RAISE EXCEPTION TYPE zcx_cute_not_defined.
    ELSE.
      "read technical cute field settings
      SELECT * FROM zcute_field INTO TABLE zif_cute_source_info~cute_fields
       WHERE typename = source.
    ENDIF.

    "read table definition
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
    ELSE.
      "add components
      SORT components BY position.
      LOOP AT components INTO DATA(component).
        zif_cute_source_info~get_field_info( component-fieldname ).
      ENDLOOP.
    ENDIF.

    "get text table
    zif_cute_source_info~determine_text_table( ).

  ENDMETHOD.
ENDCLASS.
