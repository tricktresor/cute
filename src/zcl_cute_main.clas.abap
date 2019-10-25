class ZCL_CUTE_MAIN definition
  public
  create public .

public section.

  class-methods GET_INSTANCE
    importing
      !SOURCE type TYPENAME
    returning
      value(INSTANCE) type ref to ZIF_CUTE
    raising
      ZCX_CUTE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CUTE_MAIN IMPLEMENTATION.


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
