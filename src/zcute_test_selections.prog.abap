REPORT zcute_test_selections.

PARAMETERS p_table TYPE typename DEFAULT 'ZCUTE_TEST'.

START-OF-SELECTION.

  data(srcinfo) = zcl_cute_source_information=>get_instance( p_table ).
  DATA(selopt) = zcl_cute_selection_screen=>get_instance( srcinfo ).
  selopt->show( ).
