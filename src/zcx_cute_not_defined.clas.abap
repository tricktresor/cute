class ZCX_CUTE_NOT_DEFINED definition
  public
  inheriting from ZCX_CUTE
  create public .

public section.

  constants ZCX_CUTE_NOT_DEFINED type SOTR_CONC value '005056A038571ED9BDDF8A0C284DD95A' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CUTE_NOT_DEFINED IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_CUTE_NOT_DEFINED .
 ENDIF.
  endmethod.
ENDCLASS.
