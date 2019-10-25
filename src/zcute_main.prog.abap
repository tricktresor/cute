REPORT zcute_main.


PARAMETERS p_table TYPE typename DEFAULT 'ZCUTE_TEST'.
PARAMETERS p_edit TYPE flag RADIOBUTTON GROUP m DEFAULT 'X' USER-COMMAND onli.
PARAMETERS p_show TYPE flag RADIOBUTTON GROUP m .



CLASS lcl_main DEFINITION.
  PUBLIC SECTION.
    METHODS pbo
      IMPORTING
        edit TYPE flag.
    METHODS pai
      IMPORTING
        ucomm TYPE syucomm.
    METHODS set_status.
    METHODS ask_save_data
      RETURNING
        VALUE(result) TYPE flag.

  PRIVATE SECTION.
    DATA cc TYPE REF TO cl_gui_custom_container.
    DATA cute  TYPE REF TO zif_cute.
ENDCLASS.

CLASS lcl_main IMPLEMENTATION.
  METHOD pbo.

    set_status( ).

    TRY.
        cute = zcl_cute_main=>get_instance( p_table ).
        IF cc IS INITIAL.
          cc = NEW #( container_name = 'CC' ).
        ENDIF.

        cute->set_container( cc ).
        IF edit = abap_true.
          cute->edit( ).
        ELSE.
          cute->show( ).
        ENDIF.

        cl_gui_container=>set_focus( cc ).

      CATCH zcx_cute INTO DATA(error).
        MESSAGE error TYPE 'E' DISPLAY LIKE 'I'.

    ENDTRY.
  ENDMETHOD.

  METHOD pai.

    CASE sy-ucomm.
      WHEN 'BACK' OR 'HOME' OR 'CANCEL'.
        IF cute->check_input( ) = abap_false.
          MESSAGE 'input error' TYPE 'S'.
        ENDIF.

        IF cute->check_unsaved_data( ) = abap_true.
          DATA(answer) = ask_save_data( ).
          CASE answer.
            WHEN '1'.
              cute->save( ).
              SET SCREEN 0.
              LEAVE SCREEN.
            WHEN '2'.
              SET SCREEN 0.
              LEAVE SCREEN.
            WHEN 'A'.
              RETURN.
          ENDCASE.
        ELSE.
          SET SCREEN 0.
          LEAVE SCREEN.

        ENDIF.
      WHEN OTHERS.

    ENDCASE.


  ENDMETHOD.

  METHOD ask_save_data.
    DATA answer TYPE c LENGTH 1.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        titlebar              = 'unsaved data'(001)
        text_question         = 'Save data before leaving?'(002)
        text_button_1         = 'Yes, please'(yes)
        icon_button_1         = 'ICON_SYSTEM_SAVE'
        text_button_2         = 'No, thanks'(ano)
        icon_button_2         = 'ICON_SYSTEM_BACK'
        default_button        = '1'
        display_cancel_button = 'X'
        start_column          = 25
        start_row             = 6
        popup_type            = 'ICON_MESSAGE_QUESTION'
      IMPORTING
        answer                = answer
      EXCEPTIONS
        text_not_found        = 1
        OTHERS                = 2.
    IF sy-subrc = 0.
      result = answer.
    ENDIF.


  ENDMETHOD.

  METHOD set_status.
    SET PF-STATUS '100'.
    IF p_edit = abap_true.
      SET TITLEBAR 'EDIT' WITH p_table.
    ELSE.
      SET TITLEBAR 'SHOW' WITH p_table.
    ENDIF.
  ENDMETHOD.

ENDCLASS.

DATA main TYPE REF TO lcl_main.

START-OF-SELECTION.

  CALL SCREEN 100.



*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  CHECK main IS INITIAL.
  main = NEW #( ).
  main->pbo( p_edit ).

ENDMODULE.

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  main->pai( sy-ucomm ).

ENDMODULE.
