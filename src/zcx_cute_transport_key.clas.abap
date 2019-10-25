class ZCX_CUTE_TRANSPORT_KEY definition
  public
  inheriting from ZCX_CUTE
  create public .

public section.

  constants ZCX_CUTE_TRANSPORT_KEY type SOTR_CONC value '005056A038571ED9BDDF4B1431F3D958' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CUTE_TRANSPORT_KEY IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_CUTE_TRANSPORT_KEY .
 ENDIF.
  endmethod.
ENDCLASS.
