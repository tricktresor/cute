class ZCL_CUTE_TABLE_EDIT definition
  public
  create public .

public section.

  interfaces ZIF_CUTE .
  PROTECTED SECTION.
private section.

  data GRID type ref to CL_GUI_ALV_GRID .
  data SPLITTER type ref to CL_GUI_EASY_SPLITTER_CONTAINER .
  data ERRORS_EXIST type FLAG .

  methods SET_UPDATE_FLAG
    importing
      !FLAG type UPDKZ_D
    changing
      !LINE type ANY .
  methods PROCESS_DELETED_DATA
    importing
      !ER_DATA_CHANGED type ref to CL_ALV_CHANGED_DATA_PROTOCOL .
  methods REFRESH .
  methods SET_KEY_FIELDS_READ_ONLY .
  methods EDIT_GRID .
  methods GRID_EXCLUDED_FUNCTIONS
    returning
      value(FUNCTIONS) type UI_FUNCTIONS .
  methods HANDLE_DATA_CHANGED
    for event DATA_CHANGED of CL_GUI_ALV_GRID
    importing
      !ER_DATA_CHANGED
      !E_ONF4
      !E_ONF4_AFTER
      !E_ONF4_BEFORE
      !E_UCOMM .
  methods HANDLE_TOOLBAR
    for event TOOLBAR of CL_GUI_ALV_GRID
    importing
      !E_INTERACTIVE
      !E_OBJECT .
  methods HANDLE_AFTER_USER_COMMAND
    for event AFTER_USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM
      !E_SAVED
      !E_NOT_PROCESSED .
  methods HANDLE_USER_COMMAND
    for event USER_COMMAND of CL_GUI_ALV_GRID
    importing
      !E_UCOMM .
  methods CHECK_KEYS
    raising
      ZCX_CUTE_DATA_DUPLICATE_KEYS .
  methods PROCESS_INSERTED_DATA
    importing
      !ER_DATA_CHANGED type ref to CL_ALV_CHANGED_DATA_PROTOCOL .
  methods PROCESS_CHANGED_DATA
    importing
      !ER_DATA_CHANGED type ref to CL_ALV_CHANGED_DATA_PROTOCOL .
ENDCLASS.



CLASS ZCL_CUTE_TABLE_EDIT IMPLEMENTATION.


  METHOD check_keys.

    errors_exist = abap_false.

    FIELD-SYMBOLS <edit_data> TYPE table.
    DATA(edit_data) = zif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.

    FIELD-SYMBOLS <edit_key> TYPE any.
    DATA(edit_key) = zif_cute~table_helper->get_data_reference_key( ).
    ASSIGN edit_key->* TO <edit_key>.

    DATA key_table TYPE STANDARD TABLE OF string.
    FIELD-SYMBOLS <color_row> TYPE char04.

    LOOP AT <edit_data> ASSIGNING FIELD-SYMBOL(<edit_line>).

      "fill key
      MOVE-CORRESPONDING <edit_line> TO <edit_key>.

      "assign color table
      ASSIGN COMPONENT '_COLOR_ROW_' OF STRUCTURE <edit_line> TO <color_row>.

      "check key values
      READ TABLE key_table WITH KEY table_line = <edit_key> TRANSPORTING NO FIELDS.
      IF sy-subrc > 0.
        APPEND <edit_key> TO key_table.
        CLEAR <color_row>.
      ELSE.
        "more detailed information: if first of duplicate key has been changed, then
        "the 2nd line will be marked as duplicate. the changed line should be
        "marked because the user just edited it
        zcl_cute_todo=>beautify( 'maybe derive detailed information about wrong part of the key and line' ).
        errors_exist = abap_true.
        "color duplicate line RED
        <color_row> = 'C600'. "red
      ENDIF.
    ENDLOOP.

    IF errors_exist = abap_true.
      "display colors
      RAISE EXCEPTION TYPE zcx_cute_data_duplicate_keys.
    ENDIF.

  ENDMETHOD.


  METHOD edit_grid.


    FIELD-SYMBOLS <edit_data> TYPE table.

    DATA(edit_data) = zif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.

    IF zif_cute~container IS INITIAL.
      zif_cute~container = NEW cl_gui_dialogbox_container( top = 10 left = 10 height = 600 width = 1500 ).
    ENDIF.

    IF zif_cute~authorized_to-maintain = abap_true.
      "use separate container for application log in edit mode
      splitter = NEW #(
        parent        = zif_cute~container
        orientation   = cl_gui_easy_splitter_container=>orientation_vertical
        sash_position = 70 ).
      DATA(container_grid) = splitter->top_left_container.
      DATA(container_prot) = splitter->bottom_right_container.
    ELSE.
      "no container for application log in display mode
      container_grid = zif_cute~container.
    ENDIF.

    grid = NEW #(
         i_parent          = container_grid
         i_applogparent    = container_prot
         i_appl_events     = ' ' ).

    IF zif_cute~authorized_to-maintain = abap_true.
      "editable
      grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
      grid->set_ready_for_input( 1 ).
      SET HANDLER handle_data_changed FOR grid.
    ENDIF.

    SET HANDLER handle_user_command       FOR grid.
    SET HANDLER handle_after_user_command FOR grid.
    SET HANDLER handle_toolbar            FOR grid.

    "layout settings
    DATA layout TYPE lvc_s_layo.
    layout-ctab_fname = '_COLOR_'.
    layout-stylefname = '_STYLE_'.
    layout-info_fname = '_COLOR_ROW_'.

    "Fieldcatalog
    DATA(fcat) = zif_cute~table_helper->get_field_catalog(
      grid = grid
      edit = zif_cute~authorized_to-maintain ).

    "layout settings for key values
    set_key_fields_read_only( ).

    "display grid
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
      "Change toolbar
      grid->set_toolbar_interactive( ).
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


  METHOD handle_after_user_command.

    CASE e_ucomm.
      WHEN '&CHECK'.
        TRY.
            check_keys( ).
            refresh( ).
          CATCH zcx_cute_data.
            MESSAGE 'Duplicate keys; please check!' TYPE 'I'.
        ENDTRY.
    ENDCASE.

  ENDMETHOD.


  METHOD handle_data_changed.

    CHECK e_onf4 IS INITIAL
    AND   e_onf4_after IS INITIAL
    AND   e_onf4_before IS INITIAL.


    process_deleted_data( er_data_changed ).
    process_inserted_data( er_data_changed ).
    process_changed_data( er_data_changed ).

    TRY.
        check_keys( ).
      CATCH zcx_cute_data_duplicate_keys.
        MESSAGE i001.
    ENDTRY.

    "activate color settings
    refresh( ).

  ENDMETHOD.


  METHOD handle_toolbar.

    "do not display SAVE icon if only in Display mode
    CHECK zif_cute~authorized_to-maintain = abap_true.

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


  METHOD process_changed_data.

    FIELD-SYMBOLS <style> TYPE lvc_t_styl.
    DATA cell_style TYPE lvc_s_styl.
    FIELD-SYMBOLS <cell_style> TYPE lvc_s_styl.
    FIELD-SYMBOLS <color> TYPE lvc_t_scol.
    FIELD-SYMBOLS <cell_color> TYPE lvc_s_scol.
    FIELD-SYMBOLS <edit_data> TYPE table.
    FIELD-SYMBOLS <edit_line> TYPE any.
    FIELD-SYMBOLS <color_row> TYPE char04.


    DATA(edit_data) = zif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.

    LOOP AT er_data_changed->mt_good_cells INTO DATA(good_cell).
      DATA(field_info) = zif_cute~source_information->get_field_info( good_cell-fieldname ).
      READ TABLE <edit_data> ASSIGNING <edit_line> INDEX good_cell-row_id.

      set_update_flag(
        EXPORTING
          flag = zcl_cute_tab_helper=>line_changed
        CHANGING
          line = <edit_line> ).

      "assign color table
      ASSIGN COMPONENT '_COLOR_' OF STRUCTURE <edit_line> TO <color>.
      READ TABLE <color> ASSIGNING <cell_color> WITH KEY fname = good_cell-fieldname.
      IF sy-subrc > 0.
        INSERT INITIAL LINE INTO TABLE <color> ASSIGNING <cell_color>.
        <cell_color>-fname = good_cell-fieldname.
      ENDIF.
      IF line_exists( er_data_changed->mt_inserted_rows[ row_id = good_cell-row_id ] ).
        "line inserted: mark fields as green
        <cell_color>-color-col = col_positive.
      ELSE.
        "line changed: mark fields as yellow
        <cell_color>-color-col = col_total.
      ENDIF.

      ASSIGN COMPONENT good_cell-fieldname OF STRUCTURE <edit_line> TO FIELD-SYMBOL(<value>).
      <value> = good_cell-value.
      zif_cute~unsaved_data = abap_true.
    ENDLOOP.

  ENDMETHOD.


  METHOD PROCESS_DELETED_DATA.

    FIELD-SYMBOLS <edit_data> TYPE table.
    FIELD-SYMBOLS <edit_line> TYPE any.

    DATA(edit_data) = zif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.

    LOOP AT er_data_changed->mt_deleted_rows INTO DATA(rowdel).
      zif_cute~unsaved_data = abap_true.
*      "set update flag
*      READ TABLE <edit_data> ASSIGNING <edit_line> INDEX rowdel-row_id.
*      ASSIGN COMPONENT '_UPDKZ_' OF STRUCTURE <edit_line> TO <updkz>.
*      <updkz> = zcl_cute_tab_helper=>line_deleted.
*      "set style DISABLED
*      ASSIGN COMPONENT '_STYLE_' OF STRUCTURE <edit_line> TO <style>.
*      READ TABLE <style> WITH KEY fieldname = space ASSIGNING <cell_style>.
*      IF sy-subrc = 0.
*        <cell_style>-style = alv_style_disabled + alv_style_no_delete_row.
*      ELSE.
*        cell_style-fieldname = space.
*        cell_style-style     = alv_style_disabled + alv_style_no_delete_row.
*        INSERT cell_style INTO TABLE <style>.
*      ENDIF.
*      "mark deletion red
*      ASSIGN COMPONENT '_COLOR_ROW_' OF STRUCTURE <edit_line> TO <color_row>.
*      <color_row> = 'C711'.
    ENDLOOP.


  ENDMETHOD.


  METHOD process_inserted_data.

    FIELD-SYMBOLS <edit_data> TYPE table.
    FIELD-SYMBOLS <edit_line> TYPE any.

    DATA(edit_data) = zif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.

    LOOP AT er_data_changed->mt_inserted_rows INTO DATA(rowins).
      INSERT INITIAL LINE INTO <edit_data> ASSIGNING <edit_line> INDEX rowins-row_id.
      set_update_flag(
        EXPORTING
          flag = zcl_cute_tab_helper=>line_inserted
        CHANGING
          line = <edit_line> ).
    ENDLOOP.

  ENDMETHOD.


  METHOD refresh.

    grid->refresh_table_display(
      i_soft_refresh = abap_true
      is_stable = VALUE #( col = abap_true row = abap_true ) ).

  ENDMETHOD.


  METHOD set_key_fields_read_only.

    FIELD-SYMBOLS <edit_data> TYPE table.
    FIELD-SYMBOLS <edit_line> TYPE any.
    FIELD-SYMBOLS <style> TYPE lvc_t_styl.
    DATA cell_style TYPE lvc_s_styl.

    DATA(edit_data) = zif_cute~table_helper->get_data_reference_edit( ).
    ASSIGN edit_data->* TO <edit_data>.


    LOOP AT <edit_data> ASSIGNING <edit_line>.
      "assign color table
      ASSIGN COMPONENT '_STYLE_' OF STRUCTURE <edit_line> TO <style>.
      LOOP AT zif_cute~source_information->fieldinfos
      INTO DATA(fieldinfo)
      WHERE dfies-keyflag = abap_true
        AND dfies-datatype <> 'CLNT'.
        cell_style-fieldname = fieldinfo-fieldname.
        cell_style-style     = cl_gui_alv_grid=>mc_style_disabled.
        INSERT cell_style INTO TABLE <style>.
      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.


  METHOD set_update_flag.

    ASSIGN COMPONENT '_UPDKZ_' OF STRUCTURE line TO FIELD-SYMBOL(<updkz>).
    <updkz> = flag.

  ENDMETHOD.


  METHOD zif_cute~check_authority.

    zif_cute~authorized_to = zcl_cute_authorization=>check_all(
      group    = zif_cute~source_information->cute_tech-sm30_group
      name     = zif_cute~source_information->name ).

  ENDMETHOD.


  METHOD ZIF_CUTE~CHECK_INPUT.

    grid->check_changed_data( IMPORTING e_valid = valid ).

  ENDMETHOD.


  METHOD zif_cute~check_unsaved_data.
    DATA(valid) = zif_cute~check_input( ).
    unsaved_data = zif_cute~unsaved_data.
  ENDMETHOD.


  METHOD zif_cute~edit.

    zif_cute~table_helper = zcl_cute_tab_helper=>get_instance( zif_cute~source_information ).
    TRY.
        zif_cute~check_authority( ).
        zif_cute~read( ).
        edit_grid( ).
      CATCH zcx_cute_not_authorized.
        RETURN.
    ENDTRY.

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

    IF zif_cute~check_input( ) = abap_false.
      MESSAGE 'input error. data cannot be saved.' TYPE 'I'.
      RETURN.
    ENDIF.

    check_keys( ).

    IF errors_exist = abap_true.
      MESSAGE 'data error. data cannot be saved.' TYPE 'I'.
      RETURN.
    ENDIF.

    zif_cute~map_edit_to_origin( ).

    DATA(origin_data) = zif_cute~table_helper->get_data_reference_origin( ).
    ASSIGN origin_data->* TO <origin_data>.


    MODIFY (zif_cute~source_information->name)
      FROM TABLE <origin_data>.
    IF sy-subrc = 0.
      zif_cute~unsaved_data = abap_false.
      MESSAGE 'data has been saved.'(svs) TYPE 'S'.
    ELSE.
      MESSAGE 'Error saving data... ;('(sve) TYPE 'I'.
    ENDIF.


  ENDMETHOD.


  METHOD zif_cute~set_container.
    zif_cute~container = container.
  ENDMETHOD.


  METHOD zif_cute~set_source.

    zif_cute~source_information = source_info.

  ENDMETHOD.


  METHOD zif_cute~show.

    zif_cute~table_helper = zcl_cute_tab_helper=>get_instance( zif_cute~source_information ).
    TRY.
        zif_cute~authorized_to-display = abap_true.
        zif_cute~read( ).
        edit_grid( ).
      CATCH zcx_cute_not_authorized.
        RETURN.
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
