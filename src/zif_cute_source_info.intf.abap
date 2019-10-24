INTERFACE zif_cute_source_info public.
  TYPES: BEGIN OF fieldinfo,
           fieldname TYPE fieldname,
           dfies     TYPE dfies,
           catalog   TYPE lvc_s_fcat,
           cute      TYPE zcute_field,
           domvalues TYPE dd07vtab,
         END OF fieldinfo.
  METHODS read
    IMPORTING
              source TYPE clike
    RAISING   zcx_cute.
  METHODS get_field_info
    IMPORTING
      fieldname        TYPE clike
    RETURNING
      VALUE(fieldinfo) TYPE fieldinfo.
  DATA name TYPE typename.
  DATA class TYPE tabclass.
  DATA fieldinfos TYPE SORTED TABLE OF fieldinfo WITH UNIQUE KEY fieldname.
  DATA cute_tech TYPE zcute_tech.
  DATA cute_fields TYPE SORTED TABLE OF zcute_field WITH UNIQUE KEY fieldname.
ENDINTERFACE.
