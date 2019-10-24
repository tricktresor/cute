class ZCL_CUTE_AUTHORIZATION definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF authorization_type,
        maintain TYPE flag, "at least one of create, change or insert
        display  TYPE flag,
        change   TYPE flag,
        insert   TYPE flag,
        delete   TYPE flag,
      END OF authorization_type .

  constants ACTIVITY_CHANGE type ACTIV_AUTH value '02' ##NO_TEXT.
  constants ACTIVITY_ADD_OR_CREATE type ACTIV_AUTH value '02' ##NO_TEXT.
  constants ACTIVITY_DISPLAY type ACTIV_AUTH value '01' ##NO_TEXT.
  constants ACTIVITY_DELETE type ACTIV_AUTH value '06' ##NO_TEXT.
  constants ACTIVITY_TRANSPORT type ACTIV_AUTH value '21' ##NO_TEXT.

  class-methods SM30_GROUP
    importing
      !GROUP type BEGRU
      !ACTIVITY type ACTIV_AUTH
    returning
      value(AUTHORIZED) type FLAG .
  class-methods SOURCE_NAME
    importing
      !NAME type TYPENAME
      !ACTIVITY type ACTIV_AUTH
    returning
      value(AUTHORIZED) type FLAG .
  class-methods CHECK_ALL
    importing
      !GROUP type BEGRU
      !NAME type TYPENAME
    returning
      value(AUTHORIZED_TO) type AUTHORIZATION_TYPE .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CUTE_AUTHORIZATION IMPLEMENTATION.


  METHOD check_all.

    "Insert
    authorized_to-insert = sm30_group(
      group    = group
      activity = activity_add_or_create ).

    authorized_to-insert = source_name(
      name     = name
      activity = activity_add_or_create ).

    "Change
    authorized_to-change = zcl_cute_authorization=>sm30_group(
      group    = group
      activity = activity_change ).

    authorized_to-change = source_name(
      name     = name
      activity = activity_change ).

    "Delete
    authorized_to-delete = sm30_group(
      group    = group
      activity = activity_delete ).

    authorized_to-delete = source_name(
      name     = name
      activity = activity_delete ).

    "Maintain any?
    IF authorized_to-insert = abap_true
    OR authorized_to-change = abap_true
    OR authorized_to-delete = abap_true.
      authorized_to-maintain = abap_true.
    ENDIF.

    "Display
    authorized_to-display = sm30_group(
      group    = group
      activity = activity_display ).

    authorized_to-display = source_name(
      name     = name
      activity = activity_display ).

  ENDMETHOD.


  METHOD sm30_group.

    IF group IS INITIAL.
      authorized = abap_true.
    ELSE.
      "Check authority for SM30 group
      AUTHORITY-CHECK OBJECT 'S_TABU_DIS'
               ID 'DICBERCLS' FIELD group
               ID 'ACTVT' FIELD activity.
      IF sy-subrc = 0.
        authorized = abap_true.
      ELSE.
        authorized = abap_false.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD source_name.

    "check authority for table name
    AUTHORITY-CHECK OBJECT 'S_TABU_NAM'
             ID 'ACTVT' FIELD activity
             ID 'TABLE' FIELD name.
    IF sy-subrc = 0.
      authorized = abap_true.
    ELSE.
      authorized = abap_false.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
