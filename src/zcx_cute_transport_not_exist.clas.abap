class ZCX_CUTE_TRANSPORT_NOT_EXIST definition
  public
  inheriting from ZCX_CUTE
  create public .

public section.

  constants ZCX_CUTE_TRANSPORT_NOT_EXIST type SOTR_CONC value '005056A038571EEA8099310F40FE83AE' ##NO_TEXT.
  data OBJ_NAME type STRING .
  data OBJECT type STRING .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !OBJ_NAME type STRING optional
      !OBJECT type STRING optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CUTE_TRANSPORT_NOT_EXIST IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_CUTE_TRANSPORT_NOT_EXIST .
 ENDIF.
me->OBJ_NAME = OBJ_NAME .
me->OBJECT = OBJECT .
  endmethod.
ENDCLASS.
