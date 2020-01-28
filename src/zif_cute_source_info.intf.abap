interface ZIF_CUTE_SOURCE_INFO
  public .


  types:
    BEGIN OF ts_fieldinfo,
      fieldname TYPE fieldname,
      dfies     TYPE dfies,
      catalog   TYPE lvc_s_fcat,
      cute      TYPE zcute_field,
      domvalues TYPE dd07v_tab,
    END OF ts_fieldinfo .
  types:
    tt_fieldinfos TYPE SORTED TABLE OF ts_fieldinfo WITH UNIQUE KEY fieldname WITH UNIQUE SORTED KEY position COMPONENTS dfies-position .
  types:
    BEGIN OF ts_texttable,
      name      TYPE tabname,
      description type dfies,
      keyfields TYPE STANDARD TABLE OF fieldname WITH EMPTY KEY,
    END OF ts_texttable .
  types:
    tt_texttables TYPE SORTED TABLE OF ts_texttable WITH UNIQUE KEY name .

  data NAME type TYPENAME .
  data CLASS type TABCLASS .
  data FIELDINFOS type TT_FIELDINFOS .
  data CUTE_TECH type ZCUTE_TECH .
  data:
    cute_fields TYPE SORTED TABLE OF zcute_field WITH UNIQUE KEY fieldname .
  data TEXT_TABLES type TT_TEXTTABLES .

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
  methods DETERMINE_TEXT_TABLE .
  methods GET_TEXT_TABLE
    importing
      !NAME type TABNAME optional
    returning
      value(TEXTTABLE) type TS_TEXTTABLE .
endinterface.
