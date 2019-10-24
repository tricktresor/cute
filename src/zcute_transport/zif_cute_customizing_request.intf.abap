interface ZIF_CUTE_CUSTOMIZING_REQUEST
  public .


  methods SET_REQUEST_VIA_POPUP .
  methods GET_REQUEST
    returning
      value(R_REQUEST) type E071-TRKORR .
  methods ADD_KEY_TO_REQUEST
    importing
      !TABLE_NAME type TABNAME
      !TABLE_KEY type TROBJ_NAME
    raising
      ZCX_CUTE_NO_REQUEST .
endinterface.
