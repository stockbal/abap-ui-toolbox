*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

CLASS lcl_pretty_printer_settings IMPLEMENTATION.
  METHOD if_pretty_printer_settings~get_case_mode.
    case_mode = if_pretty_printer_settings~co_case_mode_hikey.
  ENDMETHOD.

  METHOD constructor.
    super->constructor( ).
    mv_line_length = iv_line_length.
  ENDMETHOD.

ENDCLASS.
