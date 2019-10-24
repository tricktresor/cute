REPORT zcute_main.


SELECTION-SCREEN COMMENT /1(80) cmt.
PARAMETERS p_table TYPE typename DEFAULT 'ZCUTE_TEST'.

INCLUDE <cl_alv_control>.


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
        instance = NEW zcl_cute_table_edit( ).
        instance->set_source( source_info ).
      WHEN 'VIEW'.
        RAISE EXCEPTION TYPE zcx_cute_unsupported_category.
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
