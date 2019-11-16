class ZCX_CUTE definition
  public
  inheriting from CX_DYNAMIC_CHECK
  create public .

public section.

  constants ZCX_CUTE type SOTR_CONC value '005056A038571ED9BDDF401375BAD958' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CUTE IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_CUTE .
 ENDIF.
  endmethod.
ENDCLASS.
