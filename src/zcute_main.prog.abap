REPORT zcute_main.


SELECTION-SCREEN COMMENT /1(80) cmt.
PARAMETERS p_table TYPE typename DEFAULT 'ZCUTE_TEST'.

INCLUDE <cl_alv_control>.

CLASS lcx_cute DEFINITION INHERITING FROM cx_static_check. ENDCLASS.
CLASS lcx_cute_unsupported_category DEFINITION INHERITING FROM lcx_cute. ENDCLASS.
CLASS lcx_cute_not_defined DEFINITION INHERITING FROM lcx_cute. ENDCLASS.
CLASS lcx_cute_get_type DEFINITION INHERITING FROM lcx_cute. ENDCLASS.

INTERFACE lif_cute_source_info.
  TYPES: BEGIN OF fieldinfo,
           fieldname TYPE fieldname,
           dfies     TYPE dfies,
           catalog   TYPE lvc_s_fcat,
           cute      TYPE zcute_field,
           domvalues TYPE dd07vtab,
         END OF fieldinfo.
  METHODS read
    IMPORTING
              source TYPE clike
    RAISING   lcx_cute.
  METHODS get_field_info
    IMPORTING
      fieldname        TYPE clike
    RETURNING
      VALUE(fieldinfo) TYPE fieldinfo.
  DATA name TYPE typename.
  DATA class TYPE tabclass.
  DATA fieldinfos TYPE SORTED TABLE OF fieldinfo WITH UNIQUE KEY fieldname.
  DATA cute_tech TYPE zcute_tech.
  DATA cute_fields TYPE SORTED TABLE OF zcute_field WITH UNIQUE KEY fieldname.
ENDINTERFACE.

CLASS lcl_cute_listbox_helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_listbox_for_fix_values
      IMPORTING
        domname              TYPE domname
        handle               TYPE i
        type                 TYPE zcute_field_display_type
      RETURNING
        VALUE(listbox_alias) TYPE lvc_t_dral.
ENDCLASS.

CLASS lcl_cute_listbox_helper IMPLEMENTATION.
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



CLASS lcl_cute_source_info_tabl DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_cute_source_info.

    DATA header TYPE dd02v.
    DATA technical TYPE dd09v.
    DATA components TYPE STANDARD TABLE OF dd03p.

ENDCLASS.

CLASS lcl_cute_source_info_tabl IMPLEMENTATION.

  METHOD lif_cute_source_info~read.

    DATA source_name TYPE typename.
    lif_cute_source_info~class = 'TRANSP'.
    lif_cute_source_info~name  = source.

    SELECT SINGLE * FROM zcute_tech INTO lif_cute_source_info~cute_tech WHERE typename = source.
    IF sy-subrc > 0.
      RAISE EXCEPTION TYPE lcx_cute_not_defined.
    ELSE.
      SELECT * FROM zcute_field INTO TABLE lif_cute_source_info~cute_fields
       WHERE typename = source.
    ENDIF.

    CALL FUNCTION 'DDIF_TABL_GET'
      EXPORTING
        name          = lif_cute_source_info~name
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
      RAISE EXCEPTION TYPE lcx_cute_get_type.
    ENDIF.

  ENDMETHOD.

  METHOD lif_cute_source_info~get_field_info.

    DATA dfies_table TYPE STANDARD TABLE OF dfies.

    READ TABLE lif_cute_source_info~fieldinfos WITH TABLE KEY fieldname = fieldname INTO fieldinfo.
    IF sy-subrc > 0.
      fieldinfo-fieldname = fieldname.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = lif_cute_source_info~name
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
        READ TABLE lif_cute_source_info~cute_fields INTO fieldinfo-cute WITH TABLE KEY fieldname = fieldname.
        IF sy-subrc > 0.
          fieldinfo-cute-fieldname = '%%%'.
        ENDIF.
        "insert field information
        INSERT fieldinfo INTO TABLE lif_cute_source_info~fieldinfos.

      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
CLASS lcl_cute_source_info_view DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_cute_source_info.

    DATA header TYPE dd25v.
    DATA technical TYPE dd09l.
    DATA components TYPE STANDARD TABLE OF dd27p.
    DATA selection_criteria TYPE STANDARD TABLE OF dd28v.
    DATA joins TYPE STANDARD TABLE OF dd28j.
    DATA base_tables TYPE STANDARD TABLE OF dd26v.

ENDCLASS.

CLASS lcl_cute_source_info_view IMPLEMENTATION.

  METHOD lif_cute_source_info~read.

    lif_cute_source_info~class = 'VIEW'.
    lif_cute_source_info~name  = source.
    SELECT SINGLE * FROM zcute_tech INTO lif_cute_source_info~cute_tech WHERE typename = source.
    IF sy-subrc > 0.
      RAISE EXCEPTION TYPE lcx_cute_not_defined.
    ELSE.
      SELECT * FROM zcute_field INTO TABLE lif_cute_source_info~cute_fields
       WHERE typename = source.
    ENDIF.

    CALL FUNCTION 'DDIF_VIEW_GET'
      EXPORTING
        name          = lif_cute_source_info~name
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
      RAISE EXCEPTION TYPE lcx_cute_get_type.
    ENDIF.

  ENDMETHOD.

  METHOD lif_cute_source_info~get_field_info.

    READ TABLE lif_cute_source_info~fieldinfos WITH TABLE KEY fieldname = fieldname INTO fieldinfo.
    IF sy-subrc > 0.
      fieldinfo-fieldname = fieldname.

      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = lif_cute_source_info~name
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
        INSERT fieldinfo INTO TABLE lif_cute_source_info~fieldinfos.
      ENDIF.

    ENDIF.

  ENDMETHOD.
ENDCLASS.

CLASS lcl_cute_source_information DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      IMPORTING
        source          TYPE clike
      RETURNING
        VALUE(instance) TYPE REF TO lif_cute_source_info.
    CLASS-METHODS get_source_type
      IMPORTING
        source          TYPE clike
      RETURNING
        VALUE(typekind) TYPE ddtypekind.

ENDCLASS.


CLASS lcl_cute_source_information IMPLEMENTATION.
  METHOD get_instance.
    CASE get_source_type( source ).
      WHEN 'TABL'.
        instance = NEW lcl_cute_source_info_tabl( ).
      WHEN 'VIEW'.
        instance = NEW lcl_cute_source_info_view( ).
    ENDCASE.

    IF instance IS BOUND.
      TRY.
          instance->read( source ).
        CATCH lcx_cute.
      ENDTRY.
    ENDIF.
  ENDMETHOD.
  METHOD get_source_type.
    DATA source_name TYPE typename.
    DATA gotstate TYPE ddgotstate.

    source_name = source.

    CALL FUNCTION 'DDIF_TYPEINFO_GET'
      EXPORTING
        typename = source_name
      IMPORTING
        typekind = typekind
        gotstate = gotstate.

  ENDMETHOD.
ENDCLASS.


CLASS lcl_cute_tab_helper DEFINITION.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      IMPORTING
        source_info     TYPE REF TO lif_cute_source_info
      RETURNING
        VALUE(instance) TYPE REF TO lcl_cute_tab_helper.
    METHODS set_source
      IMPORTING
        source_info TYPE REF TO lif_cute_source_info.
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
      IMPORTING
        grid        TYPE REF TO cl_gui_alv_grid
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
    DATA source_information TYPE REF TO lif_cute_source_info.
    DATA components TYPE cl_abap_structdescr=>component_table.
ENDCLASS.

CLASS lcl_cute_tab_helper IMPLEMENTATION.
  METHOD get_instance.
    instance = NEW lcl_cute_tab_helper( ).
    instance->set_source( source_info ).
    instance->create( ).
  ENDMETHOD.

  METHOD create.
    struc_origin_descr = CAST cl_abap_structdescr( cl_abap_structdescr=>describe_by_name( source_information->name ) ).

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
          <field>-ref_table = source_information->name.

          DATA(field_info) = source_information->get_field_info( component-name ).
          IF field_info-cute-read_only = abap_false.
            <field>-edit      = abap_true.
          ENDIF.

          CASE field_info-cute-fieldtype.
            WHEN 'CB'.
              <field>-checkbox = abap_true.
            WHEN 'LK' OR 'LT' OR 'LB'.
              <field>-drdn_hndl  = field_info-dfies-position.
              <field>-drdn_alias = 'X'.
              grid->set_drop_down_table(
                  it_drop_down_alias = lcl_cute_listbox_helper=>get_listbox_for_fix_values(
                    handle  = <field>-drdn_hndl
                    type    = field_info-cute-fieldtype
                    domname = field_info-dfies-domname ) ).
            WHEN 'IC'.
              <field>-icon = abap_true.

          ENDCASE.

*          <field>-style = ALV_STYLE_FONT_ITALIC.
*          <field>-style = ALV_STYLE_radio_checked.

        CATCH cx_sy_move_cast_error.
          CONTINUE.
      ENDTRY.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.


INTERFACE lif_cute.
  METHODS edit
    IMPORTING
      container TYPE REF TO cl_gui_container.
  METHODS save.
  METHODS check.
  METHODS read.
  METHODS map_edit_to_origin.
  METHODS map_origin_to_edit.
  METHODS set_source
    IMPORTING
      source_info TYPE REF TO lif_cute_source_info.
  DATA source_information TYPE REF TO lif_cute_source_info.
  DATA table_helper TYPE REF TO lcl_cute_tab_helper.
  DATA container TYPE REF TO cl_gui_container.
ENDINTERFACE.



CLASS lcl_cute_table DEFINITION.
  PUBLIC SECTION.
    INTERFACES lif_cute.
  PRIVATE SECTION.
    DATA grid TYPE REF TO cl_gui_alv_grid.
    DATA splitter TYPE REF TO cl_gui_easy_splitter_container.
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
    lif_cute~container = container.
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

    SELECT * FROM (lif_cute~source_information->name)
      INTO TABLE <table>.

    lif_cute~map_origin_to_edit( ).

  ENDMETHOD.

  METHOD lif_cute~save.
    FIELD-SYMBOLS <origin_data> TYPE table.

    lif_cute~map_edit_to_origin( ).

    DATA(origin_data) = lif_cute~table_helper->get_data_reference_origin( ).
    ASSIGN origin_data->* TO <origin_data>.


    MODIFY (lif_cute~source_information->name)
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


    splitter = NEW #(
      parent        = lif_cute~container
      orientation   = cl_gui_easy_splitter_container=>orientation_vertical
      sash_position = 70 ).

    grid = NEW #(
         i_parent          = splitter->top_left_container
         i_applogparent    = splitter->bottom_right_container
         i_appl_events     = ' ' ).

    grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
    grid->set_ready_for_input( 1 ).

    SET HANDLER handle_data_changed FOR grid.
    SET HANDLER handle_user_command FOR grid.
    SET HANDLER handle_toolbar FOR grid.

    DATA layout TYPE lvc_s_layo.
    DATA(fcat) = lif_cute~table_helper->get_field_catalog( grid ).

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

    DATA msgid             TYPE sy-msgid.
    DATA msgty             TYPE sy-msgty.
    DATA msgno             TYPE sy-msgno.
    DATA msgv1             TYPE sy-msgv1.
    DATA msgv2             TYPE sy-msgv2.
    DATA msgv3             TYPE sy-msgv3.
    DATA msgv4             TYPE sy-msgv4.
    DATA value_internal    TYPE string.

    CHECK e_onf4 IS INITIAL
    AND   e_onf4_after IS INITIAL
    AND   e_onf4_before IS INITIAL.

    LOOP AT er_data_changed->mt_good_cells INTO DATA(good_cell).
      DATA(field_info) = lif_cute~source_information->get_field_info( good_cell-fieldname ).

*      CALL FUNCTION 'DDUT_INPUT_CHECK'
*        EXPORTING
*          tabname           = lif_cute~source_information->name
*          fieldname         = conv FNAM_____4( good_cell-fieldname )
*          value             = good_cell-value
*          value_is_external = 'X'
*          no_forkey_check   = ' '
*          keep_fieldinfo    = ' '
*        IMPORTING
*          msgid             = msgid
*          msgty             = msgty
*          msgno             = msgno
*          msgv1             = msgv1
*          msgv2             = msgv2
*          msgv3             = msgv3
*          msgv4             = msgv4
*          value_internal    = value_internal
*        EXCEPTIONS
*          no_ddic_field     = 1
*          illegal_move      = 2
*          OTHERS            = 3.
*      IF sy-subrc = 0 AND msgid IS NOT INITIAL.
*        er_data_changed->add_protocol_entry(
*            i_msgid     = msgid
*            i_msgty     = msgty
*            i_msgno     = msgno
*            i_msgv1     = msgv1
*            i_msgv2     = msgv2
*            i_msgv3     = msgv3
*            i_msgv4     = msgv4
*            i_fieldname = good_cell-fieldname
*            i_row_id    = good_cell-row_id
*            i_tabix     = good_cell-tabix  ).
*      ENDIF.

    ENDLOOP.

    " fm DDUT_INPUT_CHECK


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
        source          TYPE typename
      RETURNING
        VALUE(instance) TYPE REF TO lif_cute
      RAISING
        lcx_cute.
  PROTECTED SECTION.

ENDCLASS.


CLASS lcl_cute_main IMPLEMENTATION.
  METHOD get_instance.

    DATA(source_info) = lcl_cute_source_information=>get_instance( source ).

    CASE source_info->class.
      WHEN 'TRANSP'.
        instance = NEW lcl_cute_table( ).
        instance->set_source( source_info ).
      WHEN 'VIEW'.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE lcx_cute_unsupported_category.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

INITIALIZATION.
  cmt = 'press enter'.

*START-OF-SELECTION.
AT SELECTION-SCREEN.

  TRY.
      DATA(cute) = lcl_cute_main=>get_instance( p_table ).
      cute->edit( NEW cl_gui_dialogbox_container( top = 10 left = 10 height = 600 width = 1500 ) ).
    CATCH lcx_cute.
      MESSAGE 'error' TYPE 'I'.
  ENDTRY.
