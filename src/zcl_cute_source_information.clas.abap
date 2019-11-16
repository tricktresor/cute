class ZCL_CUTE_SOURCE_INFORMATION definition
  public
  final
  create public .

public section.

  class-methods GET_INSTANCE
    importing
      !SOURCE type CLIKE
    returning
      value(INSTANCE) type ref to ZIF_CUTE_SOURCE_INFO
    raising
      ZCX_CUTE .
  class-methods GET_SOURCE_TYPE
    importing
      !SOURCE type CLIKE
    returning
      value(TYPEKIND) type DDTYPEKIND
    raising
      ZCX_CUTE_GET_TYPE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CUTE_SOURCE_INFORMATION IMPLEMENTATION.


  METHOD get_instance.

    CASE get_source_type( source ).
      WHEN 'TABL'.
        instance = NEW zcl_cute_source_info_tabl( ).
      WHEN 'VIEW'.
        instance = NEW zcl_cute_source_info_view( ).
      WHEN OTHERS.
        RAISE EXCEPTION TYPE zcx_cute_unsupported_category.
    ENDCASE.

    IF instance IS BOUND.
      TRY.
          instance->read( source ).
        CATCH zcx_cute INTO DATA(error).
          MESSAGE error TYPE 'E'.
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
    IF typekind IS INITIAL.
      RAISE EXCEPTION TYPE zcx_cute_source_not_existent.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
