class ZCL_CUTE_SELECTION_SCREEN definition
  public
  final
  create private .

public section.

  data WHERE_CLAUSE type RSDS_TWHERE .
  data EXPRESSIONS type RSDS_TEXPR .
  data FIELD_RANGES type RSDS_TRANGE .
  data NUMBER_OF_ACTIVE_FIELDS type I .
  data:
    fields TYPE STANDARD TABLE OF rsdsfields WITH EMPTY KEY .
  data SOURCE_NAME type TYPEINFO .

  methods CONSTRUCTOR
    importing
      !SOURCE_INFO type ref to ZIF_CUTE_SOURCE_INFO .
  methods SHOW
    raising
      ZCX_CUTE_SELECTION_SCREEN .
  methods GET_WHERE_CLAUSE
    returning
      value(WHERE_CLAUSE) type RSDS_WHERE_TAB .
  class-methods GET_INSTANCE
    importing
      !SOURCE_INFO type ref to ZIF_CUTE_SOURCE_INFO
    returning
      value(INSTANCE) type ref to ZCL_CUTE_SELECTION_SCREEN .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ts_instance,
      name TYPE typename,
      ref  TYPE REF TO zcl_cute_selection_screen,
    END OF ts_instance .
  types:
    tt_instances TYPE SORTED TABLE OF ts_instance WITH UNIQUE KEY name .

  data SELECTIONS_ID type DYNSELID .
  data SOURCE_INFO type ref to ZIF_CUTE_SOURCE_INFO .
  class-data INSTANCES type TT_INSTANCES .

  methods INIT
    raising
      ZCX_CUTE_SELECTION_SCREEN .
ENDCLASS.



CLASS ZCL_CUTE_SELECTION_SCREEN IMPLEMENTATION.


  METHOD constructor.
    me->source_info = source_info.
    source_name = source_info->name.
    init( ).
  ENDMETHOD.


  METHOD get_instance.

    READ TABLE instances INTO DATA(instance_exist)
    WITH TABLE KEY name = source_info->name.
    IF sy-subrc > 0.
      INSERT VALUE #(
        name = source_info->name
        ref  = NEW zcl_cute_selection_screen( source_info ) )
      INTO TABLE instances ASSIGNING FIELD-SYMBOL(<new_instance>).
      instance = <new_instance>-ref.
    ENDIF.

  ENDMETHOD.


  METHOD get_where_clause.

    READ TABLE me->where_clause
    WITH TABLE KEY tablename = source_info->name
    INTO DATA(where).
    IF sy-subrc = 0.
      where_clause = where-where_tab.
    ENDIF.

  ENDMETHOD.


  METHOD init.

    DATA tables TYPE STANDARD TABLE OF rsdstabs WITH EMPTY KEY.

    APPEND source_info->name TO tables.

    DATA(fieldinfos) = source_info->fieldinfos.

    LOOP AT fieldinfos INTO DATA(fieldinfo) USING KEY position.
      CHECK fieldinfo-dfies-datatype <> 'CLNT'.
      INSERT VALUE #(
        tablename = source_info->name
        fieldname = fieldinfo-dfies-fieldname )
      INTO TABLE fields.
    ENDLOOP.


    CALL FUNCTION 'FREE_SELECTIONS_INIT'
      EXPORTING
        kind                     = 'T'
      IMPORTING
        selection_id             = selections_id
        number_of_active_fields  = number_of_active_fields
        expressions              = expressions
      TABLES
        tables_tab               = tables
        fields_tab               = fields
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
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_cute_selection_screen.
    ENDIF.

  ENDMETHOD.


  METHOD show.

    "Call dynamic selections dialog
    CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
      EXPORTING
        selection_id            = selections_id
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
    IF sy-subrc > 0.
      RAISE EXCEPTION TYPE zcx_cute_selection_screen.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
