interface ZIF_CUTE_SOURCE_INFO
  public .


  types:
    BEGIN OF fieldinfo,
           fieldname TYPE fieldname,
           dfies     TYPE dfies,
           catalog   TYPE lvc_s_fcat,
           cute      TYPE zcute_field,
           domvalues TYPE dd07vtab,
         END OF fieldinfo .

  data NAME type TYPENAME .
  data CLASS type TABCLASS .
  data:
    fieldinfos TYPE SORTED TABLE OF fieldinfo WITH UNIQUE KEY fieldname .
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
      value(FIELDINFO) type FIELDINFO .
endinterface.
