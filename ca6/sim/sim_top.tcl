alias clc ".main clear"

# Clear the simulation environment
clc
exec vlib work
vmap work work

# Set testbench and paths
set TB "testbench3_3"
set hdl_path "../src/hdl"
set inc_path "../src/inc"

# Set the runtime for simulation
set run_time "10 ns"
# Uncomment the line below for an unlimited runtime
# set run_time "-all"

#============================ Add Verilog Files ===============================
# Add your HDL source files here with lint, width checks, and warnings as errors
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/IF_buf_read.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/buffer.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/datapath.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/filt_buf_read.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/read_addr_gen.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/top.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/_aux.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/controller.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/fifo_buffer.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/out_buf.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/scratches.v
vlog +acc -incr -source +define+SIM +lint=all +warn=width -pedanticerrors $hdl_path/psum_scr_ct.v

# Add the testbench with lint, width checks, and warnings as errors
vlog +acc -incr -source +incdir+$inc_path +define+SIM +lint=all +warn=width -pedanticerrors ./tb/$TB.v
onerror {break}


#================================ Simulation ====================================
vsim -voptargs=+acc -debugDB $TB

#======================= Adding Signals to Wave Window ==========================
add wave -hex -group {TB} sim:/$TB/*
add wave -hex -group {top} sim:/$TB/uut/*
add wave -hex -group -r {all} sim:/$TB/*

#=========================== Configure Wave Signals =============================
configure wave -signalnamewidth 2

#====================================== Run =====================================
run $run_time
