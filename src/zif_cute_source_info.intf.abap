interface ZIF_CUTE_SOURCE_INFO
  public .


  types:
    BEGIN OF ts_fieldinfo,
      fieldname TYPE fieldname,
      dfies     TYPE dfies,
      catalog   TYPE lvc_s_fcat,
      cute      TYPE zcute_field,
      domvalues TYPE dd07vtab,
    END OF ts_fieldinfo .
  types:
    tt_fieldinfos TYPE SORTED TABLE OF ts_fieldinfo WITH UNIQUE KEY fieldname WITH UNIQUE SORTED KEY position COMPONENTS dfies-position .

  data NAME type TYPENAME .
  data CLASS type TABCLASS .
  data FIELDINFOS type TT_FIELDINFOS .
  data CUTE_TECH type ZCUTE_TECH .
  data:
    cute_fields TYPE SORTED TABLE OF zcute_field WITH UNIQUE KEY fieldname .

  methods READ
    importing
      !SOURCE type CLIKE
    raising
      ZCX_CUTE .
  methods GET_FIELD_INFO
    importing
      !FIELDNAME type CLIKE
    returning
      value(FIELDINFO) type ZIF_CUTE_SOURCE_INFO=>TS_FIELDINFO .
endinterface.
