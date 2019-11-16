class ZCX_CUTE_DATA_DUPLICATE_KEYS definition
  public
  inheriting from ZCX_CUTE
  create public .

public section.

  constants ZCX_CUTE_DATA_DUPLICATE_KEYS type SOTR_CONC value '005056A038571ED9BDE20715ECCD5978' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional .
protected section.
private section.
ENDCLASS.



CLASS ZCX_CUTE_DATA_DUPLICATE_KEYS IMPLEMENTATION.


  method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
 IF textid IS INITIAL.
   me->textid = ZCX_CUTE_DATA_DUPLICATE_KEYS .
 ENDIF.
  endmethod.
ENDCLASS.
