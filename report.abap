*&---------------------------------------------------------------------*
*& Report  ZTEMP2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  z_split_2alv_inone.

"Data for output
data: gr_container type ref to cl_gui_docking_container.   "The carrier for the split container
data: lv_splitter type ref to cl_gui_splitter_container.  "The splitter itself
data: lv_parent1 type ref to cl_gui_container.           "parent 1 and 2
data: lv_parent2 type ref to cl_gui_container.

data ref_grid1 type ref to cl_gui_alv_grid.
data ref_grid2 type ref to cl_gui_alv_grid.
data: gr_table1 type ref to cl_salv_table.
data: gr_table2 type ref to cl_salv_table.

"Some data used for DB query
data: gt_mara type standard table of mara.
data: gt_mard type standard table of mard.


start-of-selection.

  select * from mara into table gt_mara up to 200 rows.
  select * from mard into table gt_mard up to 200 rows.

  call screen 2000.


*&---------------------------------------------------------------------*
*&      Module STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
module status_2000 output.
  set pf-status 'STATUS'.

  "Now we create a docking container which will use the hole screen. So the Dynpro 2000 can't be seen anymore.
  create object gr_container
    exporting
      repid                       = sy-repid                                  "needs report id
      dynnr                       = sy-dynnr                                  "need dynpro number
      side                        = cl_gui_docking_container=>dock_at_top     "we want to add the docking on the bottom of the screen 2000
      extension                   = cl_gui_docking_container=>ws_maximizebox  "The Dockingcontainer should use the hole screen
    exceptions
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      others                      = 6.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
    with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


**   create splitter container in which we'll place the alv table
  create object lv_splitter
    exporting
      parent  = gr_container
      rows    = 2
      columns = 1.

*  lv_splitter->set_column_sash(
*      id = 1
*      type  = cl_gui_splitter_container=>type_sashvisible
*      value = cl_gui_splitter_container=>false
*  ).

  lv_parent1 = lv_splitter->get_container( row = 1 column = 1 ).
  lv_parent2 = lv_splitter->get_container( row = 2 column = 1 ).

***  Display first ALV
  perform set_display1.
***  Display second ALV
  perform set_display2.

endmodule.                 " STATUS_2000  OUTPUT
*&---------------------------------------------------------------------*
*&      Module USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
module user_command_2000 input.
  if sy-ucomm = 'EXIT'.
    leave program.
  endif.
endmodule.                 " USER_COMMAND_2000  INPUT
*&---------------------------------------------------------------------*
*&      Form SET_DISPLAY
*&---------------------------------------------------------------------*
form set_display1 raising cx_salv_msg.
  data gr_alv_functions type ref to cl_salv_functions_list.

  cl_salv_table=>factory(
    exporting
      r_container  = lv_parent1
    importing
      r_salv_table = gr_table1
    changing
      t_table      = gt_mara
  ).

  gr_alv_functions = gr_table1->get_functions( ).
  gr_alv_functions->set_all( ).

  gr_table1->display( ).
endform. " SET_DISPLAY

form set_display2 raising cx_salv_msg.
  data gr_alv_functions type ref to cl_salv_functions_list.
  cl_salv_table=>factory(
    exporting
      r_container  = lv_parent2
    importing
      r_salv_table = gr_table2
    changing
      t_table      = gt_mard
  ).
  gr_alv_functions = gr_table1->get_functions( ).
  gr_alv_functions->set_all( abap_false ).
  gr_table2->display( ).
endform.
