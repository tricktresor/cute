REPORT zcute_main.


PARAMETERS p_table TYPE tabname16 DEFAULT 'ZCUTE_TEST'.


CLASS lcl_cute_source_information DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      IMPORTING
        source          TYPE tabname16
      RETURNING
        VALUE(instance) TYPE REF TO lcl_cute_source_information.
    METHODS read_source
      IMPORTING
        source TYPE tabname16.

    DATA header TYPE dd02v.
    DATA technical TYPE dd09v.
    DATA components TYPE STANDARD TABLE OF dd03p.

ENDCLASS.

CLASS lcl_cute_source_information IMPLEMENTATION.
  METHOD get_instance.
    instance = NEW lcl_cute_source_information( ).
    instance->read_source( source ).
  ENDMETHOD.
  METHOD read_source.
    DATA source_name      TYPE ddobjname.

    source_name = source.

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = source_name
        state         = 'A'
        langu         = sy-langu
      IMPORTING
        dd02v_wa      = header
      TABLES
        dd03p_tab     = components
      EXCEPTIONS
        illegal_input = 1
        OTHERS        = 2.
    IF sy-subrc = 0.

    ENDIF.

  ENDMETHOD.
ENDCLASS.


CLASS lcl_cute_tab_helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      IMPORTING
        source_info     TYPE REF TO lcl_cute_source_information
      RETURNING
        VALUE(instance) TYPE REF TO lcl_cute_tab_helper.
    METHODS set_source
      IMPORTING
        source_info TYPE REF TO lcl_cute_source_information.
    METHODS get_components
      RETURNING
        VALUE(components) TYPE cl_abap_structdescr=>component_table.
    METHODS set_components
      IMPORTING
        components TYPE cl_abap_structdescr=>component_table.
    METHODS get_data_reference_edit
      RETURNING
        VALUE(dataref) TYPE REF TO data.
    METHODS get_data_reference_origin
      RETURNING
        VALUE(dataref) TYPE REF TO data.
    METHODS get_field_catalog
      RETURNING
        VALUE(fcat) TYPE lvc_t_fcat.
  PRIVATE SECTION.
    METHODS create.
    DATA struc_origin_descr TYPE REF TO cl_abap_structdescr.
    DATA table_origin_descr TYPE REF TO cl_abap_tabledescr.
    DATA table_origin_data TYPE REF TO data.

    DATA table_edit_data TYPE REF TO data.
    DATA table_edit_descr TYPE REF TO cl_abap_tabledescr.
    DATA struc_edit_descr TYPE REF TO cl_abap_structdescr.
    DATA source_information TYPE REF TO lcl_cute_source_information.
    DATA components TYPE cl_abap_structdescr=>component_table.
ENDCLASS.

CLASS lcl_cute_tab_helper IMPLEMENTATION.
  METHOD get_instance.
    instance = NEW lcl_cute_tab_helper( ).
    instance->set_source( source_info ).
    instance->create( ).
  ENDMETHOD.

  METHOD create.
    struc_origin_descr = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( source_information->header-tabname ) ).

    "Needed to save data
    table_origin_descr = cl_abap_tabledescr=>create(
      p_line_type  = struc_origin_descr
      p_table_kind = cl_abap_tabledescr=>tablekind_std
      p_unique     = abap_false ).

    CREATE DATA table_origin_data TYPE HANDLE table_origin_descr.

    "Adapt editable structure
    components = struc_origin_descr->get_components( ).

    APPEND VALUE #( name = '_COLOR_' type = CAST cl_abap_datadescr( cl_abap_structdescr=>describe_by_name( 'LVC_T_SCOL' ) ) )
    TO components.

    struc_edit_descr = cl_abap_structdescr=>create( components ).

    table_edit_descr = cl_abap_tabledescr=>create(
      p_line_type  = struc_edit_descr
      p_table_kind = cl_abap_tabledescr=>tablekind_std
      p_unique     = abap_false ).

    CREATE DATA table_edit_data TYPE HANDLE table_edit_descr.
  ENDMETHOD.

  METHOD set_components.
  ENDMETHOD.

  METHOD get_components.
  ENDMETHOD.

  METHOD get_data_reference_edit.
    dataref = table_edit_data.
  ENDMETHOD.
  METHOD get_data_reference_origin.
    dataref = table_origin_data.
  ENDMETHOD.

  METHOD set_source.
    source_information = source_info.
  ENDMETHOD.

  METHOD get_field_catalog.
    DATA element_descr TYPE REF TO cl_abap_elemdescr.
    DATA field_descr TYPE dfies.

    LOOP AT components INTO DATA(component).
      TRY.
          element_descr ?= component-type.
          field_descr = element_descr->get_ddic_field( ).
          CHECK field_descr-datatype <> 'CLNT'.
          APPEND INITIAL LINE TO fcat ASSIGNING FIELD-SYMBOL(<field>).
          MOVE-CORRESPONDING field_descr TO <field>.
          <field>-fieldname = component-name.
          <field>-reptext   = field_descr-fieldname.
          <field>-scrtext_s = field_descr-fieldname.
          <field>-scrtext_m = field_descr-fieldname.
          <field>-scrtext_l = field_descr-fieldname.
          <field>-ref_table = source_information->header-tabname.
          <field>-edit      = abap_true.
        CATCH cx_sy_move_cast_error.
          CONTINUE.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


INTERFACE lif_cute.
  METHODS edit.
  METHODS save.
  METHODS check.
  METHODS read.
  METHODS map_edit_to_origin.
  METHODS map_origin_to_edit.
  METHODS set_source
    IMPORTING
      source_info TYPE REF TO lcl_cute_source_information.
  DATA source_information TYPE REF TO lcl_cute_source_information.
  DATA table_helper TYPE REF TO lcl_cute_tab_helper.
ENDINTERFACE.


CLASS lcx_cute DEFINITION INHERITING FROM cx_static_check. ENDCLASS.
CLASS lcx_cute_unsupported_category DEFINITION INHERITING FROM lcx_cute. ENDCLASS.

CLASS lcl_cute_table DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_cute.
  PRIVATE SECTION.
    DATA grid TYPE REF TO cl_gui_alv_grid.
    METHODS edit_grid.
    METHODS grid_excluded_functions
      RETURNING
        VALUE(functions) TYPE ui_functions.
    METHODS handle_data_changed
          FOR EVENT data_changed OF cl_gui_alv_grid
      IMPORTING
          er_data_changed
          e_ucomm
          e_onf4
          e_onf4_after
          e_onf4_before.
    METHODS  handle_toolbar
          FOR EVENT toolbar OF cl_gui_alv_grid
      IMPORTING
          e_object
          e_interactive.
    METHODS handle_user_command
          FOR EVENT user_command OF cl_gui_alv_grid
      IMPORTING
          e_ucomm.
ENDCLASS.

CLASS lcl_cute_table IMPLEMENTATION.
  METHOD lif_cute~edit.
    lif_cute~table_helper = lcl_cute_tab_helper=>get_instance( lif_cute~source_information ).
    lif_cute~read( ).
    edit_grid( ).
  ENDMETHOD.
  METHOD lif_cute~set_source.
    lif_cute~source_information = source_info.
  ENDMETHOD.

  METHOD lif_cute~read.
    FIELD-SYMBOLS <table> TYPE table.
    DATA(tabref) = lif_cute~table_helper->get_data_reference_origin( ).
    ASSIGN tabref->* TO <table>.

    SELECT * FROM (lif_cute~source_information->header-tabname)
      INTO TABLE <table>.

    lif_cute~map_origin_to_edit( ).

  ENDMETHOD.

  METHOD lif_cute~save.
    FIELD-SYMBOLS <origin_data> TYPE table.

    lif_cute~map_edit_to_origin( ).

    DATA(origin_data) = lif_cute~table_helper->get_data_reference_origin( ).
    ASSIGN origin_data->* TO <origin_data>.


    MODIFY (lif_cute~source_information->header-tabname)
      FROM TABLE <origin_data>.
    IF sy-subrc = 0.
      MESSAGE 'data has been saved.'(svs) TYPE 'S'.
    ELSE.
      MESSAGE 'Error saving data... ;('(sve) TYPE 'I'.
    ENDIF.

  ENDMETHOD.

  METHOD lif_cute~check.
  ENDMETHOD.

  METHOD edit_grid.

    FIELD-SYMBOLS <edit_data> TYPE table.

    DATA(edit_data) = lif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.

    grid = NEW #(
         i_parent          = cl_gui_container=>screen0
         i_appl_events     = ' ' ).

    grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
    grid->set_ready_for_input( 1 ).

    SET HANDLER handle_data_changed FOR grid.
    SET HANDLER handle_user_command FOR grid.
    SET HANDLER handle_toolbar FOR grid.

    DATA layout TYPE lvc_s_layo.
    DATA(fcat) = lif_cute~table_helper->get_field_catalog( ).

    grid->set_table_for_first_display(
      EXPORTING
        is_variant                    = VALUE #( handle = 'GRID' report = sy-repid username = sy-uname )
        i_save                        = 'A'
        i_default                     = abap_true
        is_layout                     = layout
        it_toolbar_excluding          = grid_excluded_functions( )
      CHANGING
        it_outtab                     = <edit_data>
        it_fieldcatalog               = fcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4  ).
    IF sy-subrc = 0.
      grid->set_toolbar_interactive( ).
      WRITE space.
    ENDIF.

  ENDMETHOD.

  METHOD grid_excluded_functions.
    APPEND cl_gui_alv_grid=>mc_mb_view TO functions.
    APPEND cl_gui_alv_grid=>mc_fc_reprep TO functions.
    APPEND cl_gui_alv_grid=>mc_fc_maximum TO functions.
    APPEND cl_gui_alv_grid=>mc_fc_minimum TO functions.
    APPEND cl_gui_alv_grid=>mc_mb_sum TO functions.
    APPEND cl_gui_alv_grid=>mc_mb_subtot TO functions.
    APPEND cl_gui_alv_grid=>mc_fc_graph TO functions.

  ENDMETHOD.

  METHOD lif_cute~map_edit_to_origin.
    DATA(origin_data) = lif_cute~table_helper->get_data_reference_origin( ).
    DATA(edit_data)   = lif_cute~table_helper->get_data_reference_edit( ).

    FIELD-SYMBOLS <origin_data> TYPE table.
    FIELD-SYMBOLS <edit_data> TYPE table.


    ASSIGN origin_data->* TO <origin_data>.
    ASSIGN edit_data->*   TO <edit_data>.

    <origin_data> = CORRESPONDING #( <edit_data> ).

  ENDMETHOD.

  METHOD lif_cute~map_origin_to_edit.

    DATA(origin_data) = lif_cute~table_helper->get_data_reference_origin( ).
    DATA(edit_data)   = lif_cute~table_helper->get_data_reference_edit( ).

    FIELD-SYMBOLS <origin_data> TYPE table.
    FIELD-SYMBOLS <edit_data> TYPE table.


    ASSIGN origin_data->* TO <origin_data>.
    ASSIGN edit_data->*   TO <edit_data>.

    <edit_data> = CORRESPONDING #( <origin_data> ).

  ENDMETHOD.

  METHOD handle_data_changed.
  ENDMETHOD.

  METHOD handle_toolbar.
    DATA button  TYPE stb_button.
    CLEAR button.
    button-butn_type = 3. "Separator
    APPEND button TO e_object->mt_toolbar.

    "add save button
    CLEAR button.
    button-function  = 'SAVE'.
    button-icon      = icon_system_save.
    button-quickinfo = 'Save data'(svq).
    button-butn_type = '0'. "normal Button
    button-disabled  = ' '.
    APPEND button TO e_object->mt_toolbar.
  ENDMETHOD.

  METHOD handle_user_command.
    CASE e_ucomm.
      WHEN 'SAVE'.
        lif_cute~save( ).
      WHEN OTHERS.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

CLASS lcl_cute_main DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      IMPORTING
        source          TYPE tabname16
      RETURNING
        VALUE(instance) TYPE REF TO lif_cute
      RAISING
        lcx_cute.
  PROTECTED SECTION.

ENDCLASS.


CLASS lcl_cute_main IMPLEMENTATION.
  METHOD get_instance.

    DATA(source_info) = lcl_cute_source_information=>get_instance( source ).

    CASE source_info->header-tabclass.
      WHEN 'TRANSP'.
        instance = NEW lcl_cute_table( ).
        instance->set_source( source_info ).
      WHEN 'VIEW'.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE lcx_cute_unsupported_category.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.


START-OF-SELECTION.

  TRY.
      DATA(cute) = lcl_cute_main=>get_instance( p_table ).
      cute->edit( ).
    CATCH lcx_cute.
      MESSAGE 'error' TYPE 'I'.
  ENDTRY.
