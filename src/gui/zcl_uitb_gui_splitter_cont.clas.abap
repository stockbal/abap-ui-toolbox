"! <p class="shorttext synchronized" lang="en">Wrapper for CL_GUI_SPLITTER_CONTAINER</p>
CLASS zcl_uitb_gui_splitter_cont DEFINITION
  PUBLIC
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_uitb_gui_control.

    CONSTANTS c_default_size TYPE string VALUE '50:50'.
    CONSTANTS c_size_separator TYPE char1 VALUE ':'.

    CONSTANTS:
      "! <p class="shorttext synchronized" lang="en">Mode for splitter container</p>
      BEGIN OF c_mode,
        rows TYPE i VALUE 0,
        cols TYPE i VALUE 1,
      END OF c_mode.


    "! <p class="shorttext synchronized" lang="en">Creates new GUI Splitter Container</p>
    "! @parameter io_parent | <p class="shorttext synchronized" lang="en">Parent container</p>
    "! @parameter iv_elements | <p class="shorttext synchronized" lang="en">Number of elements in the splitter</p>
    "! @parameter iv_size | <p class="shorttext synchronized" lang="en">String with container sizes, e.g. '50:50'</p>
    "!    If an asterisk (*) is detected in the size string, absolute sizes will be used, i.e. if a size string
    "!    of '26:*' is used, the first container will have 26 pixels and the second container will use the remaining space.
    "! @parameter iv_Mode | <p class="shorttext synchronized" lang="en">Columns or Rows order</p>
    "! @parameter if_auto_def_progid_dynnr | <p class="shorttext synchronized" lang="en">If 'X' the container will be bound to the current screen</p>
    "! @parameter if_no_border | <p class="shorttext synchronized" lang="en">If 'X' no border will be painted</p>
    METHODS constructor
      IMPORTING
        io_parent                TYPE REF TO cl_gui_container
        iv_elements              TYPE i
        iv_size                  TYPE string DEFAULT c_default_size
        iv_mode                  TYPE i DEFAULT zcl_uitb_gui_splitter_cont=>c_mode-rows
        if_auto_def_progid_dynnr TYPE abap_bool OPTIONAL
        if_no_border             TYPE abap_bool OPTIONAL.

    "! <p class="shorttext synchronized" lang="en">Set size of a given Cell</p>
    METHODS set_element_size
      IMPORTING
        iv_index TYPE i
        iv_size  TYPE i.

    "! <p class="shorttext synchronized" lang="en">Retrieve container at specific index</p>
    METHODS get_container
      IMPORTING
        iv_index            TYPE i
      RETURNING
        VALUE(ro_container) TYPE REF TO cl_gui_container.

    "! <p class="shorttext synchronized" lang="en">Sets the sash movable for a given element</p>
    METHODS set_sash_movable
      IMPORTING
        iv_index           TYPE i
        if_movable         TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(ro_splitter) TYPE REF TO zcl_uitb_gui_splitter_cont.

    "! <p class="shorttext synchronized" lang="en">Sets the sash visible for a given element</p>
    METHODS set_sash_visible
      IMPORTING
        iv_index           TYPE i
        if_visible         TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(ro_splitter) TYPE REF TO zcl_uitb_gui_splitter_cont.

    "! <p class="shorttext synchronized" lang="en">Sets properties for all sashes</p>
    METHODS set_all_sash_properties
      IMPORTING
        if_visible         TYPE abap_bool DEFAULT abap_true
        if_movable         TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(ro_splitter) TYPE REF TO zcl_uitb_gui_splitter_cont.
    "! <p class="shorttext synchronized" lang="en">Show/hide element</p>
    "!
    METHODS set_element_visibility
      IMPORTING
        iv_element TYPE i
        if_visible TYPE abap_bool OPTIONAL.

    "! <p class="shorttext synchronized" lang="en">Returns true if the element at given index is visible</p>
    METHODS is_element_visible
      IMPORTING
        iv_element           TYPE i
      RETURNING
        VALUE(rf_is_visible) TYPE abap_bool.

    "! <p class="shorttext synchronized" lang="en">Toggles visibility of the element at the given position</p>
    "!
    "! @parameter iv_element | <p class="shorttext synchronized" lang="en">the positional number of an element in the splitter</p>
    METHODS toggle_visibility
      IMPORTING
        iv_element TYPE i.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CONSTANTS c_true TYPE i VALUE cl_gui_splitter_container=>true.
    CONSTANTS c_false TYPE i VALUE cl_gui_splitter_container=>false.

    TYPES:
      BEGIN OF ty_s_element,
        base_size       TYPE i,
        size            TYPE i,
        visible         TYPE abap_bool,
        sash_visible    TYPE abap_bool,
        stretch_content TYPE abap_bool,
      END OF ty_s_element.

    DATA mt_elements TYPE STANDARD TABLE OF ty_s_element WITH EMPTY KEY.
    DATA mo_splitter TYPE REF TO cl_gui_splitter_container.
    DATA mv_mode TYPE i.
    DATA mv_width TYPE i.
    DATA mv_elements_count TYPE i.
    DATA mv_size_mode TYPE i.

    "! <p class="shorttext synchronized" lang="en">Update cell sizes</p>
    "!
    METHODS update_size
      IMPORTING
        if_initial_update TYPE abap_bool OPTIONAL.

    METHODS set_column_sash
      IMPORTING
        iv_index TYPE i
        iv_type  TYPE i
        iv_value TYPE i.

    METHODS set_row_sash
      IMPORTING
        iv_index TYPE i
        iv_type  TYPE i
        iv_value TYPE i.

    METHODS set_size_hidden_cells.
    METHODS set_size_visible_cells.
ENDCLASS.



CLASS zcl_uitb_gui_splitter_cont IMPLEMENTATION.

  METHOD constructor.
    DATA: lv_rows            TYPE i,
          lv_size            TYPE i,
          lv_total           TYPE i,
          lt_size            TYPE STANDARD TABLE OF string,
          lv_cols            TYPE i,
          lf_stretch_content TYPE abap_bool.

    SPLIT iv_size AT c_size_separator INTO TABLE lt_size.

    IF iv_mode = c_mode-cols.
      lv_rows = 1.
      lv_cols = iv_elements.
    ELSEIF iv_mode = c_mode-rows.
      lv_cols = 1.
      lv_rows = iv_elements.
    ELSE.
      RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
    ENDIF.

    mv_mode = iv_mode.

    mv_size_mode = cl_gui_splitter_container=>mode_relative.

*.. Determine elements with sizes
    LOOP AT lt_size INTO DATA(lv_size_string).
      DATA(lv_tabix) = sy-tabix.
      CLEAR lf_stretch_content.

      IF lv_size_string = '*'.
        mv_size_mode = cl_gui_splitter_container=>mode_absolute.
        lf_stretch_content = abap_true.
        lv_size = 0.
      ELSE.
        TRY.
            lv_size = CONV #( lv_size_string ).
          CATCH cx_sy_conversion_no_number.
            RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
        ENDTRY.
*        lv_total = lv_total + lv_size.
      ENDIF.

      mt_elements = VALUE #(
        BASE mt_elements
        ( base_size       = lv_size
          visible         = abap_true
          sash_visible    = abap_true
          stretch_content = lf_stretch_content ) ).

    ENDLOOP.

    mv_elements_count = lines( mt_elements ).

*.. Create the splitter control
    CREATE OBJECT mo_splitter
      EXPORTING
        parent                  = io_parent
        rows                    = lv_rows
        columns                 = lv_cols
        no_autodef_progid_dynnr = xsdbool( if_auto_def_progid_dynnr = abap_false )
      EXCEPTIONS
        cntl_error              = 1
        cntl_system_error       = 2
        OTHERS                  = 3.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
    ENDIF.

    CASE mv_mode.

      WHEN c_mode-cols.
        mo_splitter->set_column_mode(
          EXPORTING
            mode              = mv_size_mode
          EXCEPTIONS
            cntl_error        = 1
            cntl_system_error = 2
            OTHERS            = 3 ).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
        ENDIF.

      WHEN c_mode-rows.
        mo_splitter->set_row_mode(
          EXPORTING
            mode              = mv_size_mode
          EXCEPTIONS
            cntl_error        = 1
            cntl_system_error = 2
            OTHERS            = 3 ).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
        ENDIF.
    ENDCASE.

*.. Hide the border
    mo_splitter->set_border(
      EXPORTING
        border            = xsdbool( if_no_border = abap_false )
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3 ).
    IF sy-subrc NE 0.
      RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
    ENDIF.

    update_size( if_initial_update = abap_true ).
  ENDMETHOD.

  METHOD zif_uitb_gui_control~free.
    CHECK mo_splitter IS BOUND.
    mo_splitter->free( EXCEPTIONS OTHERS = 1 ).
  ENDMETHOD.

  METHOD zif_uitb_gui_control~focus.
    zcl_uitb_gui_helper=>set_focus( mo_splitter ).
  ENDMETHOD.

  METHOD zif_uitb_gui_control~has_focus.
    rf_has_focus = zcl_uitb_gui_helper=>has_focus( mo_splitter ).
  ENDMETHOD.

  METHOD get_container.
    ro_container = mo_splitter->get_container(
      row    = COND #( WHEN mv_mode = c_mode-cols THEN 1 ELSE iv_index )
      column = COND #( WHEN mv_mode = c_mode-rows THEN 1 ELSE iv_index ) ).
  ENDMETHOD.

  METHOD set_all_sash_properties.

    DO lines( mt_elements ) - 1 TIMES.
      set_sash_movable(
        iv_index    = sy-index
        if_movable  = if_movable ).
      set_sash_visible(
        iv_index   = sy-index
        if_visible = if_visible ).
    ENDDO.

    ro_splitter = me.
  ENDMETHOD.

  METHOD set_sash_movable.
    DATA(lv_movable) = COND i( WHEN if_movable = abap_true THEN c_true ELSE c_false ).

    CASE mv_mode.

      WHEN c_mode-cols.
        set_column_sash(
          iv_index = iv_index
          iv_type  = cl_gui_splitter_container=>type_movable
          iv_value = lv_movable ).

      WHEN c_mode-rows.
        set_row_sash(
          iv_index = iv_index
          iv_type  = cl_gui_splitter_container=>type_movable
          iv_value = lv_movable ).
    ENDCASE.

    ro_splitter = me.
  ENDMETHOD.

  METHOD set_sash_visible.
    DATA(lv_visible) = COND i( WHEN if_visible = abap_true THEN c_true ELSE c_false ).

    CASE mv_mode.

      WHEN c_mode-cols.
        set_column_sash(
          iv_index = iv_index
          iv_type  = cl_gui_splitter_container=>type_sashvisible
          iv_value = lv_visible ).

      WHEN c_mode-rows.
        set_row_sash(
          iv_index = iv_index
          iv_type  = cl_gui_splitter_container=>type_sashvisible
          iv_value = lv_visible ).
    ENDCASE.

    ro_splitter = me.
  ENDMETHOD.

  METHOD set_element_size.
    CASE mv_mode.

      WHEN c_mode-cols.
        mo_splitter->set_column_width(
          EXPORTING
            id                = iv_index
            width             = iv_size
          EXCEPTIONS
            cntl_error        = 1
            cntl_system_error = 2
            OTHERS            = 3 ).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
        ENDIF.

      WHEN c_mode-rows.
        mo_splitter->set_row_height(
          EXPORTING
            id                = iv_index
            height            = iv_size
          EXCEPTIONS
            cntl_error        = 1
            cntl_system_error = 2
            OTHERS            = 3 ).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
        ENDIF.
    ENDCASE.

*.. Update size property for element
    DATA(lr_element) = REF #( mt_elements[ iv_index ] ).
    lr_element->size = iv_size.
  ENDMETHOD.

  METHOD set_element_visibility.
    DATA: lv_count TYPE i,
          lf_delta TYPE abap_bool,
          lf_show  TYPE abap_bool.

    FIELD-SYMBOLS: <ls_element> LIKE LINE OF mt_elements.

    DATA(lr_element) = REF #( mt_elements[ iv_element ] OPTIONAL ).
    CHECK lr_element IS BOUND.

    IF if_visible IS NOT SUPPLIED.
      lf_show = lr_element->visible.
      zcl_uitb_appl_util=>toggle( CHANGING value = lf_show ).
    ELSE.
      lf_show = if_visible.
    ENDIF.

*.. check child visibility
    IF lr_element->visible <> lf_show.

*.... visibility delta
      lr_element->visible = lf_show.
      lf_delta = abap_true.

      LOOP AT mt_elements ASSIGNING <ls_element> WHERE visible = abap_true.
        lv_count = lv_count + 1.
      ENDLOOP.

      LOOP AT mt_elements ASSIGNING <ls_element>.
        IF <ls_element>-visible = abap_true.
          lv_count = lv_count - 1.
          IF lv_count > 0.
            <ls_element>-sash_visible = abap_true.
          ELSE.
            <ls_element>-sash_visible = abap_false.
          ENDIF.

        ELSE.
          <ls_element>-sash_visible = abap_false.
        ENDIF.
      ENDLOOP.
    ELSE.
      lf_delta = abap_false.
    ENDIF.

    IF lf_delta = abap_true.
      update_size( ).
    ENDIF.

  ENDMETHOD.

  METHOD toggle_visibility.
    set_element_visibility( iv_element = iv_element if_visible = xsdbool( NOT is_element_visible( iv_element ) ) ).
  ENDMETHOD.

  METHOD is_element_visible.
    rf_is_visible = VALUE #( mt_elements[ iv_element ]-visible OPTIONAL ).
  ENDMETHOD.

  METHOD update_size.
    mo_splitter->get_width( IMPORTING width = mv_width ).
    set_size_visible_cells( ).
    set_size_hidden_cells( ).
  ENDMETHOD.

  METHOD set_size_visible_cells.
    DATA: lv_tabix TYPE i.

    FIELD-SYMBOLS: <ls_element> LIKE LINE OF mt_elements.

    LOOP AT mt_elements ASSIGNING <ls_element> WHERE visible = abap_true.
      lv_tabix = sy-tabix.

      IF <ls_element>-stretch_content = abap_false.
        set_element_size(
          iv_index = lv_tabix
          iv_size  = <ls_element>-base_size ).
      ENDIF.

      CHECK lv_tabix < mv_elements_count.

      set_sash_visible(
        iv_index    = lv_tabix
        if_visible  = abap_true ).
    ENDLOOP.

  ENDMETHOD.

  METHOD set_size_hidden_cells.

    LOOP AT mt_elements ASSIGNING FIELD-SYMBOL(<ls_element>) WHERE visible = abap_false.
      DATA(lv_tabix) = sy-tabix.
      set_element_size(
          iv_index = lv_tabix
          iv_size  = 0 ).
      CHECK lv_tabix < mv_elements_count.

      set_sash_visible(
        iv_index    = lv_tabix
        if_visible  = abap_false ).
    ENDLOOP.

  ENDMETHOD.

  METHOD set_column_sash.
    mo_splitter->set_column_sash(
      EXPORTING
        id                = iv_index
        type              = iv_type
        value             = iv_value
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
    ENDIF.
  ENDMETHOD.

  METHOD set_row_sash.
    mo_splitter->set_row_sash(
      EXPORTING
        id                = iv_index
        type              = iv_type
        value             = iv_value
      EXCEPTIONS
        cntl_error        = 1
        cntl_system_error = 2
        OTHERS            = 3 ).
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_uitb_gui_exception.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
