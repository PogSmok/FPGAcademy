vlib work
vlog ../*.v
vlog ../src/*.v
vlog *.v
vsim work.testbench
add wave *
run 140 ns