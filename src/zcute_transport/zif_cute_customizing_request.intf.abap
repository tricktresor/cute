INTERFACE zif_cute_customizing_request
  PUBLIC .


  METHODS set_request_via_popup .
  METHODS get_request
    RETURNING
      VALUE(r_request) TYPE e071-trkorr .
  METHODS add_key_to_request
    IMPORTING
      !table_name TYPE tabname
      !table_key  TYPE trobj_name
    RAISING
      zcx_cute_transport_no_request .
ENDINTERFACE.
