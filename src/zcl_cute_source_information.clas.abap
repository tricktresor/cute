CLASS zcl_cute_source_information DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      IMPORTING
        source          TYPE clike
      RETURNING
        VALUE(instance) TYPE REF TO zif_cute_source_info.
    CLASS-METHODS get_source_type
      IMPORTING
        source          TYPE clike
      RETURNING
        VALUE(typekind) TYPE ddtypekind.

ENDCLASS.



CLASS ZCL_CUTE_SOURCE_INFORMATION IMPLEMENTATION.


  METHOD get_instance.
    CASE get_source_type( source ).
      WHEN 'TABL'.
        instance = NEW zcl_cute_source_info_tabl( ).
      WHEN 'VIEW'.
        instance = NEW zcl_cute_source_info_view( ).
    ENDCASE.

    IF instance IS BOUND.
      TRY.
          instance->read( source ).
        CATCH zcx_cute.
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
