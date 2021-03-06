FUNCTION ZUITB_CALL_TEMPLATE_SCREEN.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PROGRAM_TITLE) TYPE  CUA_TIT_TX
*"     REFERENCE(IR_CALLBACK) TYPE REF TO
*"        ZCL_UITB_TEMPLT_PROG_CALLBACK
*"     REFERENCE(IT_DYNAMIC_FUNCTIONS) TYPE
*"        ZCL_UITB_TEMPLT_PROG_CALLBACK=>TT_DYNAMIC_FUNCTIONS
*"     REFERENCE(IV_START_LINE) TYPE  I OPTIONAL
*"     REFERENCE(IV_START_COLUMN) TYPE  I OPTIONAL
*"     REFERENCE(IV_END_LINE) TYPE  I OPTIONAL
*"     REFERENCE(IV_END_COLUMN) TYPE  I OPTIONAL
*"----------------------------------------------------------------------
  " save current controller
  IF gs_view_data IS NOT INITIAL.
    INSERT gs_view_data INTO gt_view_controller INDEX 1.
    CLEAR gs_view_data.
  ENDIF.

  gs_view_data-controller = ir_callback.
  gs_view_data-functions = it_dynamic_functions.
  gs_view_data-title = iv_program_title.
  gs_view_data-is_first_call = abap_true.

  IF iv_start_line IS NOT INITIAL.
    gs_view_data-as_dialog = abap_true.
    CALL SCREEN 0101 STARTING AT iv_start_column iv_start_line ENDING AT iv_end_column iv_end_line.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.

ENDFUNCTION.
