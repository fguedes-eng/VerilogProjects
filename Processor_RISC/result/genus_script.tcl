
set USER aluno22 ;# put here YOUR user name at this machine
set PROJECT_DIR /prj/ci/workarea/${USER}/verilog/result
set TECH_DIR /pdk/gpdk045 ;# technology dependent
set HDL_NAME "RISC_V"



set HDL_FILES {AA_mnemonics_pkg.sv ALU.sv Control_unit.sv Data_memory.sv Instruction_decoder.sv Instruction_memory.sv Multiplexers.sv Program_Counter.sv Registers.sv RISCV.sv}

set LIB_DIR ${TECH_DIR}/gsclib045_svt_v4.7/gsclib045/timing
#set LEF_DIR ${TECH_DIR}/gsclib045_svt_v4.7/gsclib045/lef

set WORST_LIST {slow_vdd1v0_basicCells.lib} 
set BEST_LIST {fast_vdd1v2_basicCells.lib} 
set LEF_LIST {gsclib045_tech.lef gsclib045_macro.lef}

set_db init_hdl_search_path "${PROJECT_DIR}"

#Set the search paths to the libraries and the HDL files
set_db hdl_search_path "${PROJECT_DIR}"

#set_db lib_search_path "${LIB_DIR} ${LEF_DIR}"
set_db lib_search_path "${LIB_DIR}"

set_db library "${BEST_LIST}"

read_hdl -language sv ${HDL_FILES}

set_db hdl_record_naming_style %s_%s

elaborate ${HDL_NAME}

set_top_module ${HDL_NAME}

check_design -unresolved ${HDL_NAME}

read_sdc ${PROJECT_DIR}/constraint.sdc

syn_generic ${HDL_NAME}

syn_map ${HDL_NAME} 

report_timing > ${PROJECT_DIR}/${HDL_NAME}_timing.rpt

write_hdl ${HDL_NAME} > ${PROJECT_DIR}/${HDL_NAME}.v

write_sdc > ${PROJECT_DIR}/timing_design.sdc

write_sdf > ${PROJECT_DIR}/timing_design.sdf

report power  > ${REPORTS_PATH}${DESIGN}_power.rpt
report timing -lint > ${REPORTS_PATH}${DESIGN}_time.rpt
report timing > ${REPORTS_PATH}${DESIGN}_slack.rpt
report area > ${REPORTS_PATH}${DESIGN}_area.rpt
report gates > ${REPORTS_PATH}${DESIGN}_gater.rpt
report qor > ${REPORTS_PATH}${DESIGN}_qor.rpt
report messages > ${REPORTS_PATH}${DESIGN}_messages.rpt
report summary > ${REPORTS_PATH}${DESIGN}_summary.rpt
report_multibit_inferencing > ${REPORTS_PATH}${DESIGN}_multibit.rpt
