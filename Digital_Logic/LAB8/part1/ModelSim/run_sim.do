vlib work
vlog ../*.v
vlog ../src/ram32x4.v
vlog *.v
vsim work.testbench
add wave *
run -all