"! <p class="shorttext synchronized" lang="en">GUI Control</p>
INTERFACE zif_uitb_gui_control
  PUBLIC .
  data mr_control type ref to cl_gui_control.

  "! <p class="shorttext synchronized" lang="en">Set focus to control</p>
  "!
  METHODS focus.
  "! <p class="shorttext synchronized" lang="en">Checks if the control has the focus</p>
  "!
  "! @parameter rf_has_focus | <p class="shorttext synchronized" lang="en"></p>
  METHODS has_focus
    RETURNING
      VALUE(rf_has_focus) TYPE abap_bool.
ENDINTERFACE.
