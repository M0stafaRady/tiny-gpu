.PHONY: test compile

export LIBPYTHON_LOC=$(shell cocotb-config --libpython)

test_%:
	make compile
	make insert_wave_dump
	iverilog -o build/sim.vvp -s gpu -g2012 -DDUMP_WAVE build/gpu.v
	MODULE=test.test_$* vvp -M $$(cocotb-config --prefix)/cocotb/libs -m libcocotbvpi_icarus build/sim.vvp

compile:
	make compile_alu
	sv2v -I src/* -w build/gpu.v
	echo "" >> build/gpu.v
	cat build/alu.v >> build/gpu.v
	echo '`timescale 1ns/1ns' > build/temp.v
	cat build/gpu.v >> build/temp.v
	mv build/temp.v build/gpu.v

insert_wave_dump:
	# Add the following to gpu.v to enable wave dump    
	# initial begin
    #    $dumpfile ({"test/logs/waves.vcd"});
    #    $dumpvars (0, gpu);
    # end
	sed -i '/dcr dcr_instance(/i \    initial begin \n		\$$dumpfile ({"test/logs/waves.vcd"}); \n		\$$dumpvars (0, gpu); \n	end' build/gpu.v

compile_%:
	sv2v -w build/$*.v src/$*.sv

show_waves: 
	gtkwave test/logs/waves.vcd

clean:
	rm -rf build/* test/logs/*.log test/logs/*.vcd
# TODO: Get gtkwave visualizaiton

show_%: %.vcd %.gtkw
	gtkwave $^
