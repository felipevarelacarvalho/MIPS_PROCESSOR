add wave -position insertpoint \
sim:/tb_simplifiedmipsprocessor/MySimplifiedMIPSProcess/*

add wave -position insertpoint -r sim:/tb_simplifiedmipsprocessor/*

mem load -infile ../temp/imem.hex -format hex /MySimplifiedMIPSProcess/IMem
mem load -infile ../temp/dmem.hex -format hex /MySimplifiedMIPSProcess/DMem

run 10000000

quit
