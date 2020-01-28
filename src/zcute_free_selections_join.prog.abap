REPORT zcute_free_selections_join.
" test report to select data with dynamic selections via join of base tab and text table

PARAMETERS p_tabnam TYPE tabname DEFAULT 'ZCUTE_TEST'.
PARAMETERS p_tabtxt TYPE tabname MODIF ID dsp.

CLASS main DEFINITION.
  PUBLIC SECTION.
    TYPES tt_dd03p TYPE STANDARD TABLE OF dd03p WITH EMPTY KEY.
    TYPES tt_where TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    METHODS get_fields
      IMPORTING
                name           TYPE tabname
      RETURNING VALUE(dd03p_t) TYPE tt_dd03p.
    METHODS translate_expressions
      IMPORTING
                name         TYPE tabname
                expr         TYPE rsds_texpr
      RETURNING VALUE(where) TYPE tt_where.
  PRIVATE SECTION.
    DATA and TYPE string.

ENDCLASS.

CLASS main IMPLEMENTATION.
  METHOD get_fields.
    DATA dd03p_tab TYPE STANDARD TABLE OF dd03p.

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = name
        state         = 'A'       " Read Status of the Table
        langu         = ' '       " Language in which Texts are Read
      TABLES
        dd03p_tab     = dd03p_t " Table Fields
      EXCEPTIONS
        illegal_input = 1         " Value not Allowed for Parameter
        OTHERS        = 2.
    DELETE dd03p_t WHERE datatype = space OR datatype = 'CLNT'.

  ENDMETHOD.
  METHOD translate_expressions.
    LOOP AT expr
    INTO DATA(exprtab)
    WHERE tablename = name.
      LOOP AT exprtab-expr_tab INTO DATA(exprline).
        CASE exprline-option.
          WHEN 'EQ'.
            APPEND |{ and } { exprtab-tablename }~{ exprline-fieldname } = '{ exprline-low }'| TO where.
          WHEN 'CP'.
            REPLACE ALL OCCURRENCES OF '*' IN exprline-low WITH '%'.
            REPLACE ALL OCCURRENCES OF '+' IN exprline-low WITH '_'.
            APPEND |{ and } { exprtab-tablename }~{ exprline-fieldname } LIKE '{ exprline-low }'| TO where.
          WHEN 'BT'.
            APPEND |{ and } { exprtab-tablename }~{ exprline-fieldname } between '{ exprline-low }' and '{ exprline-high }'| TO where.
        ENDCASE.
        and = `AND`.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'DSP'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.
  CALL FUNCTION 'DDUT_TEXTTABLE_GET'
    EXPORTING
      tabname   = p_tabnam
    IMPORTING
      texttable = p_tabtxt.


START-OF-SELECTION.

  CHECK p_tabtxt IS NOT INITIAL.

  DATA(o_main) = NEW main( ).

  DATA tables TYPE STANDARD TABLE OF rsdstabs WITH EMPTY KEY.
  DATA selection_id TYPE dynselid.
  DATA fields TYPE STANDARD TABLE OF rsdsfields WITH EMPTY KEY .
  DATA fields_ex TYPE STANDARD TABLE OF rsdsfields WITH EMPTY KEY.

  DATA syntax_from TYPE TABLE OF string.
  DATA syntax_where TYPE TABLE OF string.
  DATA syntax_columns TYPE TABLE OF string.

  DATA(dd03p_tab) = o_main->get_fields( p_tabnam ).

  tables = VALUE #( ( prim_tab   = p_tabnam )
                    ( prim_tab   = p_tabtxt ) ).


  LOOP AT dd03p_tab INTO DATA(dd03p).
    APPEND VALUE #( tablename = p_tabnam fieldname = dd03p-fieldname ) TO fields.
    APPEND |{ p_tabnam }~{ dd03p-fieldname },| TO syntax_columns.
  ENDLOOP.

  dd03p_tab = o_main->get_fields( p_tabtxt ).

  DATA(number_of_fields) = lines( dd03p_tab ).

  LOOP AT dd03p_tab INTO dd03p.
    DATA(tabix) = sy-tabix.
    READ TABLE fields
    WITH KEY tablename = p_tabnam
             fieldname = dd03p-fieldname TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      APPEND VALUE #( tablename = p_tabtxt fieldname = dd03p-fieldname ) TO fields_ex.
      IF syntax_from IS INITIAL.
        APPEND |{ p_tabnam } RIGHT OUTER JOIN { p_tabtxt } | TO syntax_from.
        APPEND |ON  { p_tabnam }~{ dd03p-fieldname } = { p_tabtxt }~{ dd03p-fieldname }| TO syntax_from.
      ELSE.
        APPEND |AND { p_tabnam }~{ dd03p-fieldname } = { p_tabtxt }~{ dd03p-fieldname }| TO syntax_from.
      ENDIF.
    ELSEIF dd03p-datatype = 'LANG'.
      DATA(spras_field) = dd03p-fieldname.
      APPEND VALUE #( tablename = p_tabtxt fieldname = dd03p-fieldname ) TO fields_ex.
    ELSE.
      APPEND VALUE #( tablename = p_tabtxt fieldname = dd03p-fieldname ) TO fields.
      IF tabix < number_of_fields.
        APPEND |{ p_tabtxt }~{ dd03p-fieldname },| TO syntax_columns.
      ELSE.
        APPEND |{ p_tabtxt }~{ dd03p-fieldname } AS _DESCRIPTION| TO syntax_columns.
      ENDIF.
    ENDIF.
  ENDLOOP.

  CALL FUNCTION 'FREE_SELECTIONS_INIT'
    EXPORTING
      kind                     = 'T'
    IMPORTING
      selection_id             = selection_id
    TABLES
      tables_tab               = tables
      fields_tab               = fields
      tabfields_not_display    = fields_ex
    EXCEPTIONS
      fields_incomplete        = 1
      fields_no_join           = 2
      field_not_found          = 3
      no_tables                = 4
      table_not_found          = 5
      expression_not_supported = 6
      incorrect_expression     = 7
      illegal_kind             = 8
      area_not_found           = 9
      inconsistent_area        = 10
      kind_f_no_fields_left    = 11
      kind_f_no_fields         = 12
      too_many_fields          = 13
      dup_field                = 14
      field_no_type            = 15
      field_ill_type           = 16
      dup_event_field          = 17
      node_not_in_ldb          = 18
      area_no_field            = 19
      OTHERS                   = 20.
  CHECK sy-subrc = 0.

  DATA where_clause TYPE rsds_twhere .
  DATA expressions TYPE rsds_texpr .
  DATA field_ranges TYPE rsds_trange .
  DATA number_of_active_fields TYPE i .

  "Call dynamic selections dialog
  CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
    EXPORTING
      selection_id            = selection_id
      title                   = 'Selection'(001)
      status                  = 1 "normal selection
      as_window               = abap_false
      tree_visible            = abap_true
    IMPORTING
      where_clauses           = where_clause
      expressions             = expressions
      field_ranges            = field_ranges
      number_of_active_fields = number_of_active_fields
    TABLES
      fields_tab              = fields
    EXCEPTIONS
      OTHERS                  = 1.
  CHECK sy-subrc = 0.


  DATA(source_info) = zcl_cute_source_information=>get_instance( p_tabnam ).
  DATA(table_helper) = zcl_cute_tab_helper=>get_instance( source_info ).
  DATA(ref_edit) = table_helper->get_data_reference_edit( ).

  FIELD-SYMBOLS <table> TYPE ANY TABLE.
  ASSIGN ref_edit->* TO <table>.


  APPEND LINES OF o_main->translate_expressions( name = p_tabnam expr = expressions ) TO syntax_where.
  APPEND LINES OF o_main->translate_expressions( name = p_tabtxt expr = expressions ) TO syntax_where.
  IF syntax_where IS NOT INITIAL.
    APPEND |AND| TO syntax_where.
  ENDIF.
  APPEND |{ p_tabtxt }~{ spras_field } = @SY-LANGU| TO syntax_where.

  TRY.
      SELECT (syntax_columns)
        FROM (syntax_from)
       WHERE (syntax_where)
       INTO CORRESPONDING FIELDS OF TABLE @<table>.

      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   = DATA(r_salv_table)
        CHANGING
          t_table        = <table> ).
      r_salv_table->display( ).
    CATCH cx_salv_msg.

    CATCH cx_sy_dynamic_osql_syntax.
  ENDTRY.
