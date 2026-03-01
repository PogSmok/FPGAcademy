vlib work
vlog ../*.v
vlog ../src/*.v
vlog *.v
vsim work.testbench
do wave.do
run -all