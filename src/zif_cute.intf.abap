interface ZIF_CUTE
  public .


  data SOURCE_INFORMATION type ref to ZIF_CUTE_SOURCE_INFO .
  data TABLE_HELPER type ref to ZCL_CUTE_TAB_HELPER .
  data CONTAINER type ref to CL_GUI_CONTAINER .
  data AUTHORIZED_TO type ZCL_CUTE_AUTHORIZATION=>AUTHORIZATION_TYPE .
  data UNSAVED_DATA type FLAG .

  methods CHECK_AUTHORITY
    raising
      ZCX_CUTE_NOT_AUTHORIZED .
  methods CHECK_INPUT
    returning
      value(VALID) type FLAG .
  methods CHECK_UNSAVED_DATA
    returning
      value(UNSAVED_DATA) type FLAG .
  methods EDIT .
  methods MAP_EDIT_TO_ORIGIN .
  methods MAP_ORIGIN_TO_EDIT .
  methods READ .
  methods SAVE .
  methods SET_CONTAINER
    importing
      !CONTAINER type ref to CL_GUI_CONTAINER .
  methods SET_SOURCE
    importing
      !SOURCE_INFO type ref to ZIF_CUTE_SOURCE_INFO .
  methods SHOW .
endinterface.
