"! <p class="shorttext synchronized" lang="en">Functions for ALV</p>
CLASS zcl_uitb_alv_functions DEFINITION
  PUBLIC
  INHERITING FROM zcl_uitb_alv_metadata
  FINAL
  CREATE PUBLIC

  GLOBAL FRIENDS zcl_uitb_alv_grid_adapter .

  PUBLIC SECTION.
    INTERFACES zif_uitb_alv_types.
    INTERFACES zif_uitb_c_alv_function_type.

    ALIASES button
      FOR zif_uitb_c_alv_function_type~button.
    ALIASES separator
      FOR zif_uitb_c_alv_function_type~separator.
    ALIASES menu_button
      FOR zif_uitb_c_alv_function_type~menu_button.
    ALIASES dropdown_button
      FOR zif_uitb_c_alv_function_type~dropdown_button.

    ALIASES tt_function_tag_map
      FOR zif_uitb_alv_types~tt_alv_function_tag_map.
    ALIASES tt_toolbar_button
      FOR zif_uitb_alv_types~tt_alv_toolbar_button.
    ALIASES ty_toolbar_button
      FOR zif_uitb_alv_types~ty_alv_toolbar_button.
    ALIASES ty_toolbar_menu
      FOR zif_uitb_alv_types~ty_alv_toolbar_menu.
    ALIASES tt_toolbar_menu
      FOR zif_uitb_alv_types~tt_alv_toolbar_menu.

    "! <p class="shorttext synchronized" lang="en">CLASS CONSTRUCTOR</p>
    CLASS-METHODS class_constructor .

    "! <p class="shorttext synchronized" lang="en">Adds new function</p>
    METHODS add_function
      IMPORTING
        !iv_name             TYPE ui_func OPTIONAL
        iv_type              TYPE i DEFAULT button
        ir_menu              TYPE REF TO cl_ctmenu OPTIONAL
        !iv_icon             TYPE string OPTIONAL
        !iv_text             TYPE string OPTIONAL
        !iv_tag              TYPE string OPTIONAL
        !iv_tooltip          TYPE string OPTIONAL
        !if_start_of_toolbar TYPE abap_bool OPTIONAL.
    "! <p class="shorttext synchronized" lang="en">Sets functions that are active if input is invalid</p>
    "!
    "! @parameter it_ucomm | <p class="shorttext synchronized" lang="en">Table of function codes</p>
    METHODS set_process_func_on_invinput
      IMPORTING
        it_ucomm TYPE ui_functions.
    "! <p class="shorttext synchronized" lang="en">CONSTRUCTOR</p>
    METHODS constructor
      IMPORTING
        !io_controller TYPE REF TO zif_uitb_alv_metadata_ctrller .
    "! <p class="shorttext synchronized" lang="en">Get disabled functions (predefined ALV Functions)</p>
    METHODS get_disabled
      RETURNING
        VALUE(result) TYPE ui_functions .
    "! <p class="shorttext synchronized" lang="en">Retrieves functions</p>
    METHODS get_functions
      IMPORTING
        !if_for_context_menu TYPE abap_bool OPTIONAL
        !if_for_toolbar      TYPE abap_bool OPTIONAL
      RETURNING
        VALUE(result)        TYPE zif_uitb_alv_types=>tt_function .
    "! <p class="shorttext synchronized" lang="en">Is function checked?</p>
    METHODS is_checked
      IMPORTING
        !iv_user_function     TYPE ui_func
        !if_check_for_enabled TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(result)         TYPE abap_bool .
    "! <p class="shorttext synchronized" lang="en">Is function disabled?</p>
    METHODS is_disabled
      IMPORTING
        !iv_user_function TYPE ui_func
      RETURNING
        VALUE(result)     TYPE abap_bool .
    "! <p class="shorttext synchronized" lang="en">Is function enabled?</p>
    METHODS is_enabled
      IMPORTING
        !iv_name      TYPE ui_func
      RETURNING
        VALUE(result) TYPE abap_bool .
    "! <p class="shorttext synchronized" lang="en">Is function visible?</p>
    METHODS is_visible
      IMPORTING
        !iv_name      TYPE ui_func
      RETURNING
        VALUE(result) TYPE abap_bool .
    "! <p class="shorttext synchronized" lang="en">Removes Function</p>
    METHODS remove_function
      IMPORTING
        !iv_name TYPE ui_func OPTIONAL
        !iv_tag  TYPE string OPTIONAL .
    "! <p class="shorttext synchronized" lang="en">Set all functions enabled/disabled</p>
    METHODS set_all
      IMPORTING
        !value TYPE abap_bool DEFAULT abap_true .
    "! Activates a set of default functions for the
    "! toolbar and context menu like
    "! <ul>
    "! <li>find</li>
    "! <li>filter</li>
    "! <li>copy</li>
    "! <li>column hide / show</li>
    "! </ul>
    "! @parameter value | activate function with 'X'
    METHODS set_default
      IMPORTING
        !value TYPE abap_bool DEFAULT abap_true .
    "! <p class="shorttext synchronized" lang="en">Set Function status</p>
    METHODS set_function
      IMPORTING
        !iv_name    TYPE salv_de_function
        iv_icon     TYPE iconname OPTIONAL
        iv_text     TYPE text40 OPTIONAL
        iv_tooltip  TYPE iconquick OPTIONAL
        !if_enable  TYPE abap_bool DEFAULT abap_true
        !if_checked TYPE abap_bool OPTIONAL .
    "! <p class="shorttext synchronized" lang="en">Set Function status by tag name</p>
    METHODS set_functions_by_tag
      IMPORTING
        !iv_tag     TYPE string
        !if_enable  TYPE abap_bool DEFAULT abap_true
        !if_checked TYPE abap_bool .
    "! <p class="shorttext synchronized" lang="en">Sets quick filter function</p>
    METHODS set_quickfilter
      IMPORTING
        !value TYPE abap_bool DEFAULT abap_true .
    "! <p class="shorttext synchronized" lang="en">Toggle checked state of function</p>
    METHODS toggle_checked
      IMPORTING
        !iv_user_function TYPE ui_func
        !if_checked       TYPE abap_bool OPTIONAL .
    "! <p class="shorttext synchronized" lang="en">Toggle disabled state of function</p>
    METHODS toggle_disabled
      IMPORTING
        !iv_user_function TYPE ui_func
        !if_disabled      TYPE abap_bool OPTIONAL .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mt_buttons TYPE tt_toolbar_button .
    DATA mt_functions TYPE tt_toolbar_button .
    DATA mt_buttons_front TYPE tt_toolbar_button .
    DATA mt_menus TYPE tt_toolbar_menu .
    DATA mt_existing_disabled TYPE ui_functions .
    DATA mt_function_tag_map TYPE tt_function_tag_map .
    DATA mf_quickfilter TYPE abap_bool .
    data mt_func_on_invalid_input type ui_functions.
    CLASS-DATA st_existing_functions TYPE ui_functions .

    "! <p class="shorttext synchronized" lang="en">Fills function tag map for menu entries</p>
    METHODS fill_function_tag_map_for_menu
      IMPORTING
        !ir_menu TYPE REF TO cl_ctmenu
        !iv_tag  TYPE string .
    "! <p class="shorttext synchronized" lang="en">Update states of toolbar button</p>
    METHODS update_toolbar_button
      IMPORTING
        !is_button TYPE ty_toolbar_button .
    "! <p class="shorttext synchronized" lang="en">Updates states of toolbar buttons for tag</p>
    METHODS update_toolbar_buttons
      IMPORTING
        !iv_tag     TYPE string
        !if_disable TYPE abap_bool OPTIONAL
        !if_checked TYPE abap_bool OPTIONAL .
ENDCLASS.



CLASS zcl_uitb_alv_functions IMPLEMENTATION.


  METHOD add_function.
    IF iv_type <> separator AND iv_name IS NOT INITIAL.
      CHECK NOT line_exists( mt_functions[ function = iv_name ] ).
    ENDIF.

    DATA(ls_button) = VALUE ty_toolbar_button(
      butn_type   = iv_type
      function    = iv_name
      tag         = iv_tag
      text        = iv_text
      quickinfo   = iv_tooltip
      icon        = iv_icon
    ).

    mt_functions = VALUE #( BASE mt_functions ( ls_button ) ).
    IF iv_tag IS NOT INITIAL AND iv_name IS NOT INITIAL.
      mt_function_tag_map = VALUE #( BASE mt_function_tag_map
       ( function = iv_name tag = iv_tag )
      ).
    ENDIF.

    IF if_start_of_toolbar = abap_true.
      INSERT ls_button INTO mt_buttons_front INDEX 1.
    ELSE.
      mt_buttons = VALUE #( BASE mt_buttons ( ls_button ) ).
    ENDIF.

    IF iv_type = menu_button OR
       iv_type = dropdown_button.
      ASSERT ir_menu IS BOUND.
      mt_menus = VALUE #( BASE mt_menus
        ( function = iv_name
          ctmenu   = ir_menu
          tag      = iv_tag
        )
      ).
*... fill function <-> map for menu entries
      fill_function_tag_map_for_menu( ir_menu = ir_menu iv_tag = iv_tag ).
    ENDIF.

    set_setter_changed( iv_method = 'ADD_FUNCTION' ).
  ENDMETHOD.


  METHOD class_constructor.
    DATA(lr_alv_functions) = CAST cl_abap_intfdescr( cl_abap_typedescr=>describe_by_name( 'ZIF_UITB_C_ALV_FUNCTIONS' ) ).

    LOOP AT lr_alv_functions->attributes ASSIGNING FIELD-SYMBOL(<ls_constant>) WHERE is_constant = abap_true .
      ASSIGN zif_uitb_c_alv_functions=>(<ls_constant>-name) TO FIELD-SYMBOL(<lv_function_val>).
      IF sy-subrc = 0.
        st_existing_functions = VALUE #( BASE st_existing_functions ( <lv_function_val> ) ).
      ENDIF.
    ENDLOOP.

  ENDMETHOD.


  METHOD constructor.
    super->constructor( io_controller = io_controller ).
  ENDMETHOD.


  METHOD fill_function_tag_map_for_menu.
    ir_menu->get_functions( IMPORTING fcodes = DATA(lt_functions) ).
    LOOP AT lt_functions ASSIGNING FIELD-SYMBOL(<lv_func>).
      mt_function_tag_map = VALUE #( BASE mt_function_tag_map
        ( function = <lv_func> tag = iv_tag )
      ).
    ENDLOOP.

    ir_menu->get_submenus( IMPORTING menus = DATA(lt_menus) ).
    LOOP AT lt_menus ASSIGNING FIELD-SYMBOL(<ls_menu>).
      fill_function_tag_map_for_menu( ir_menu = <ls_menu>-menu_ref iv_tag = iv_tag ).
    ENDLOOP.
  ENDMETHOD.


  METHOD get_disabled.
    result = mt_existing_disabled.
  ENDMETHOD.


  METHOD get_functions.
  ENDMETHOD.


  METHOD is_checked.
    CLEAR result.

    DATA(lr_function) = REF #( mt_functions[ function = iv_user_function ] OPTIONAL ).
    IF lr_function IS BOUND.
      result = lr_function->checked.
      IF if_check_for_enabled = abap_true AND lr_function->disabled = abap_true.
        CLEAR result.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD is_disabled.
    result = VALUE #( mt_functions[ function = iv_user_function ]-disabled DEFAULT abap_true ).
  ENDMETHOD.


  METHOD is_enabled.
    result = xsdbool( NOT line_exists( mt_existing_disabled[ table_line = iv_name ] ) ).
  ENDMETHOD.


  METHOD is_visible.
  ENDMETHOD.


  METHOD remove_function.
    IF iv_name IS NOT INITIAL.

      DELETE mt_functions WHERE function = iv_name.

      IF sy-subrc = 0.
        DELETE mt_buttons WHERE function = iv_name.
        DELETE mt_buttons_front WHERE function = iv_name.
        DELETE mt_menus WHERE function = iv_name.

        set_setter_changed( iv_method = 'REMOVE_FUNCTION' ).
      ENDIF.

    ELSEIF iv_tag IS NOT INITIAL.
      DELETE mt_function_tag_map WHERE tag = iv_tag.
      DELETE mt_functions WHERE tag = iv_tag.

      IF sy-subrc = 0.
        DELETE mt_buttons WHERE tag = iv_tag.
        DELETE mt_buttons_front WHERE tag = iv_tag.
        DELETE mt_menus WHERE tag = iv_tag.

        set_setter_changed( iv_method = 'REMOVE_FUNCTION' ).
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD set_all.
    IF value = abap_false.
      mt_existing_disabled = st_existing_functions.
    ELSE.
      CLEAR mt_existing_disabled.
    ENDIF.
  ENDMETHOD.


  METHOD set_default.
    set_all( abap_false ).
    set_function( iv_name = zif_uitb_c_alv_functions=>sort_asc if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>sort_desc if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>find if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>find_more if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>filter if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>filter_delete if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>columns_to_fix if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>columns_to_unfix if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>column_optimze if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>column_invisible if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>layout_change if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>layout_menu if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>layout_save if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>layout_change if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>local_copy if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>local_cut if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>local_paste_menu if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>local_paste_new_row if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>local_append_row if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>local_insert_row if_enable = value ).
    set_function( iv_name = zif_uitb_c_alv_functions=>local_delete_row if_enable = value ).
  ENDMETHOD.


  METHOD set_function.
    DATA(lv_function) = CONV ui_func( to_upper( iv_name ) ).

*.. 1) check if this function is a user function
    DATA(lr_user_function) = REF #( mt_functions[ function = lv_function ] OPTIONAL ).
    IF lr_user_function IS BOUND.
      lr_user_function->disabled = xsdbool( if_enable = abap_false ).
      lr_user_function->checked = if_checked.

      IF iv_icon IS SUPPLIED.
        lr_user_function->icon = iv_icon.
      ENDIF.

      IF iv_text IS SUPPLIED.
        lr_user_function->text = iv_text.
      ENDIF.

      IF iv_tooltip IS SUPPLIED.
        lr_user_function->quickinfo = iv_tooltip.
      ENDIF.

      update_toolbar_button( lr_user_function->* ).
      RETURN.
    ENDIF.

*.. 2) enable/disable predefined alv function
    IF if_enable = abap_true.
      DELETE mt_existing_disabled WHERE table_line = iv_name.
    ELSE.
      IF NOT line_exists( mt_existing_disabled[ table_line = lv_function ] ).
        mt_existing_disabled = VALUE #( BASE mt_existing_disabled ( lv_function ) ).
      ENDIF.
    ENDIF.

    set_setter_changed( iv_method = 'SET_FUNCTION' ).
  ENDMETHOD.


  METHOD set_functions_by_tag.
    LOOP AT mt_functions ASSIGNING FIELD-SYMBOL(<ls_function>) WHERE tag = iv_tag.
      <ls_function>-disabled = xsdbool( if_enable = abap_false ).
      <ls_function>-checked = if_checked.
    ENDLOOP.

    update_toolbar_buttons(
      iv_tag     = iv_tag
      if_disable = xsdbool( if_enable = abap_false )
      if_checked = if_checked
    ).
  ENDMETHOD.


  METHOD set_quickfilter.
    mf_quickfilter = value.
  ENDMETHOD.

  METHOD set_process_func_on_invinput.
    mt_func_on_invalid_input = it_ucomm.
    set_setter_changed( 'SET_ACTIVE_FUNC_ON_INVINPUT' ).
  ENDMETHOD.


  METHOD toggle_checked.
    DATA(lr_user_function) = REF #( mt_functions[ function = to_upper( iv_user_function ) ] OPTIONAL ).
    IF lr_user_function IS BOUND.

      IF if_checked IS SUPPLIED.
        lr_user_function->checked = if_checked.
      ELSE.
        zcl_uitb_appl_util=>toggle( CHANGING value = lr_user_function->checked ).
      ENDIF.

      update_toolbar_button( lr_user_function->* ).
    ENDIF.
  ENDMETHOD.


  METHOD toggle_disabled.
    DATA(lr_user_function) = REF #( mt_functions[ function = to_upper( iv_user_function ) ] OPTIONAL ).
    IF lr_user_function IS BOUND.
      IF if_disabled IS SUPPLIED.
        lr_user_function->disabled = if_disabled.
      ELSE.
        zcl_uitb_appl_util=>toggle( CHANGING value = lr_user_function->disabled ).
      ENDIF.
      update_toolbar_button( lr_user_function->* ).
    ENDIF.
  ENDMETHOD.


  METHOD update_toolbar_button.
    ASSIGN mt_buttons[ function = is_button-function ] TO FIELD-SYMBOL(<ls_button>).
    IF sy-subrc <> 0.
      ASSIGN mt_buttons_front[ function = is_button-function ] TO <ls_button>.
      CHECK sy-subrc = 0.
    ENDIF.

    CHECK <ls_button> IS ASSIGNED.
    <ls_button>-disabled = is_button-disabled.
    <ls_button>-checked = is_button-checked.
    <ls_button>-icon = is_button-icon.
    <ls_button>-text = is_button-text.
    <ls_button>-quickinfo = is_button-quickinfo.
  ENDMETHOD.


  METHOD update_toolbar_buttons.
    LOOP AT mt_buttons_front ASSIGNING FIELD-SYMBOL(<ls_button_front>) WHERE tag = iv_tag.
      <ls_button_front>-checked = if_checked.
      <ls_button_front>-disabled = if_disable.
    ENDLOOP.

    LOOP AT mt_buttons ASSIGNING FIELD-SYMBOL(<ls_button>) WHERE tag = iv_tag.
      <ls_button>-checked = if_checked.
      <ls_button>-disabled = if_disable.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
