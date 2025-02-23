
create_project                  ${PROJECT_NAME} ${SYN_DIR_OUT}/${PROJECT_NAME} -part $PART -force

set_property                    XPM_LIBRARIES XPM_CDC       [current_project]
set_property                    default_lib xil_defaultlib  [current_project]
set_property                    target_language Verilog     [current_project]

#incdir_vivado                   $INCDIR_LST

# TODO: There is a way to use .f files and re-format the design files into list file -> hmm, I can't recall right now how this has to be done.
add_files                       -norecurse {rtl/dpbuf_mem.sv}
add_files                       -norecurse {rtl/rd_fifo_ctrl.sv}
add_files                       -norecurse {rtl/sync_reg.sv}
add_files                       -norecurse {rtl/wr_fifo_ctrl.sv}
add_files                       -norecurse {rtl/axi4_str_fifo.sv}


set_property                    top $TOP                    [current_fileset]


import_files -force -norecurse
import_files -fileset constrs_1 $PROJECT_CONSTRAINT_FILE

# Synthesis options - add more if necessary
#
set_property steps.synth_design.args.flatten_hierarchy          rebuilt     [get_runs synth_1]
set_property steps.synth_design.args.gated_clock_conversion     auto        [get_runs synth_1]
set_property steps.synth_design.args.keep_equivalent_registers  true        [get_runs synth_1]
set_property steps.synth_design.args.resource_sharing           off         [get_runs synth_1]


reset_run synth_1


# Synthesise design
#
launch_runs synth_1 -jobs 8
wait_on_run synth_1


#Open synthesizeed design
#
open_run synth_1 -name synth_1


write_checkpoint                -force $SYN_DIR_OUT/post_synth
report_utilization              -file  $SYN_DIR_OUT/post_synth_util.rpt

report_timing                   -sort_by group -max_paths 5 -path_type summary \
                                -file $SYN_DIR_OUT/post_synth_timing.rpt

# Placement and logic optimization
#
opt_design
power_opt_design 

place_design
phys_opt_design 


write_checkpoint                -force $SYN_DIR_OUT/post_place

report_clock_utilization        -file  $SYN_DIR_OUT/clock_util.rpt
report_utilization              -file  $SYN_DIR_OUT/post_place_util.rpt

report_timing                   -sort_by group -max_paths 5 -path_type summary \
                                -file $SYN_DIR_OUT/post_place_timing.rpt

