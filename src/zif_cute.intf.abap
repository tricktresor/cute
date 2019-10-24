INTERFACE zif_cute
  PUBLIC .

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
      source_info TYPE REF TO zif_cute_source_info.
  DATA source_information TYPE REF TO zif_cute_source_info.
  DATA table_helper TYPE REF TO zcl_cute_tab_helper.
  DATA container TYPE REF TO cl_gui_container.

ENDINTERFACE.
