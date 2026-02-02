vlib work
vlog ../*.v
vlog ../src/*.v
vlog *.v
vsim work.testbench
add wave *
run 32ns