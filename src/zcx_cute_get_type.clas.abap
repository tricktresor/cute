class ZCX_CUTE_GET_TYPE definition
  public
  inheriting from ZCX_CUTE
  create public .

public section.

  constants ZCX_CUTE_GET_TYPE type SOTR_CONC value '005056A038571ED9BDDF44E92725D958' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CUTE_GET_TYPE IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_CUTE_GET_TYPE .
 ENDIF.
  endmethod.
ENDCLASS.
