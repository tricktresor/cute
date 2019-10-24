REPORT zcute_main.


SELECTION-SCREEN COMMENT /1(80) cmt.
PARAMETERS p_table TYPE typename DEFAULT 'ZCUTE_TEST'.

INCLUDE <cl_alv_control>.

CLASS lcl_cute_table DEFINITION.
  PUBLIC SECTION.
    INTERFACES zif_cute.
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
  METHOD zif_cute~edit.
    zif_cute~container = container.
    zif_cute~table_helper = zcl_cute_tab_helper=>get_instance( zif_cute~source_information ).
    zif_cute~read( ).
    edit_grid( ).
  ENDMETHOD.
  METHOD zif_cute~set_source.
    zif_cute~source_information = source_info.
  ENDMETHOD.

  METHOD zif_cute~read.
    FIELD-SYMBOLS <table> TYPE table.
    DATA(tabref) = zif_cute~table_helper->get_data_reference_origin( ).
    ASSIGN tabref->* TO <table>.

    SELECT * FROM (zif_cute~source_information->name)
      INTO TABLE <table>.

    zif_cute~map_origin_to_edit( ).

  ENDMETHOD.

  METHOD zif_cute~save.
    FIELD-SYMBOLS <origin_data> TYPE table.

    zif_cute~map_edit_to_origin( ).

    DATA(origin_data) = zif_cute~table_helper->get_data_reference_origin( ).
    ASSIGN origin_data->* TO <origin_data>.


    MODIFY (zif_cute~source_information->name)
      FROM TABLE <origin_data>.
    IF sy-subrc = 0.
      MESSAGE 'data has been saved.'(svs) TYPE 'S'.
    ELSE.
      MESSAGE 'Error saving data... ;('(sve) TYPE 'I'.
    ENDIF.

  ENDMETHOD.

  METHOD zif_cute~check.
  ENDMETHOD.

  METHOD edit_grid.

    FIELD-SYMBOLS <edit_data> TYPE table.

    DATA(edit_data) = zif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.


    splitter = NEW #(
      parent        = zif_cute~container
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
    DATA(fcat) = zif_cute~table_helper->get_field_catalog( grid ).

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

  METHOD zif_cute~map_edit_to_origin.
    DATA(origin_data) = zif_cute~table_helper->get_data_reference_origin( ).
    DATA(edit_data)   = zif_cute~table_helper->get_data_reference_edit( ).

    FIELD-SYMBOLS <origin_data> TYPE table.
    FIELD-SYMBOLS <edit_data> TYPE table.


    ASSIGN origin_data->* TO <origin_data>.
    ASSIGN edit_data->*   TO <edit_data>.

    <origin_data> = CORRESPONDING #( <edit_data> ).

  ENDMETHOD.

  METHOD zif_cute~map_origin_to_edit.

    DATA(origin_data) = zif_cute~table_helper->get_data_reference_origin( ).
    DATA(edit_data)   = zif_cute~table_helper->get_data_reference_edit( ).

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
      DATA(field_info) = zif_cute~source_information->get_field_info( good_cell-fieldname ).

*      CALL FUNCTION 'DDUT_INPUT_CHECK'
*        EXPORTING
*          tabname           = zif_cute~source_information->name
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
        zif_cute~save( ).
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
        VALUE(instance) TYPE REF TO zif_cute
      RAISING
        zcx_cute.
  PROTECTED SECTION.

ENDCLASS.


CLASS lcl_cute_main IMPLEMENTATION.
  METHOD get_instance.

    DATA(source_info) = zcl_cute_source_information=>get_instance( source ).

    CASE source_info->class.
      WHEN 'TRANSP'.
        instance = NEW lcl_cute_table( ).
        instance->set_source( source_info ).
      WHEN 'VIEW'.
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_cute_unsupported_category.
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
    CATCH zcx_cute.
      MESSAGE 'error' TYPE 'I'.
  ENDTRY.
