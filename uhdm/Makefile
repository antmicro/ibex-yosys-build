all::
	@true

clean::
	@true

prep: .uhdm-integration .ibex .cmake .surelog .uhdm .yosys .unisim

#
# Generates EDIF
#
#	../ibex/rtl/ibex_register_file_fpga.sv
#	../ibex/rtl/ibex_pkg.sv \
#	../ibex/rtl/ibex_counter.sv \
#	../ibex/rtl/ibex_fetch_fifo.sv \
#	../ibex/rtl/ibex_load_store_unit.sv \

#
# Fails because of unsupported features in Yosys
#
#	../ibex/rtl/ibex_prefetch_buffer.sv
#	../ibex/rtl/ibex_pmp.sv
#	../ibex/rtl/ibex_multdiv_slow.sv
#	../ibex/rtl/ibex_multdiv_fast.sv
#	../ibex/rtl/ibex_id_stage.sv
#	../ibex/rtl/ibex_ex_block.sv
#	../ibex/rtl/ibex_cs_registers.sv
#	../ibex/rtl/ibex_core.sv
#	../ibex/rtl/ibex_dummy_instr.sv
#

#
# Fails because of some out-of-range exception
#
#	../ibex/rtl/ibex_if_stage.sv
#	../ibex/rtl/ibex_icache.sv
#	../ibex/rtl/ibex_decoder.sv
#	../ibex/rtl/ibex_core_tracing.sv
#	../ibex/rtl/ibex_controller.sv
#	../ibex/rtl/ibex_wb_stage.sv
#	../ibex/rtl/ibex_alu.sv
#	../ibex/rtl/ibex_tracer_pkg.sv
#	../ibex/rtl/ibex_compressed_decoder.sv
#	../ibex/rtl/ibex_tracer.sv
#

ibex-reg-file-tb:
		PATH="$(PWD)/uhdm-integration/image/bin:$$PATH" \
			surelog -parse -sverilog \
			-I../ibex/vendor/lowrisc_ip/prim/rtl \
			../ibex/rtl/ibex_register_file_fpga.sv \
	&& \
		$(PWD)/uhdm-integration/yosys/yosys \
			-p 'read_uhdm slpp_all/surelog.uhdm' \
			-p 'synth_xilinx -iopad -family xc7' \
			-p 'write_verilog -nodec -nohex -noattr top.premap.v' \
			-p 'write_edif -pvector bra top.edif' \
	&& \
		iverilog -g2005-sv \
			-s sim -o sim top.premap.v tb.sv \
			unisim/verilog/src/glbl.v \
			unisim/verilog/src/unisims/GND.v \
			unisim/verilog/src/unisims/VCC.v  \
			unisim/verilog/src/unisims/BUFG.v \
			unisim/verilog/src/unisims/FDRE.v \
			unisim/verilog/src/unisims/IBUF.v \
			unisim/verilog/src/unisims/OBUF.v \
			unisim/verilog/src/unisims/LUT6.v \
			unisim/verilog/src/unisims/LUT5.v \
			unisim/verilog/src/unisims/LUT1.v \
			unisim/verilog/src/unisims/LUT2.v \
			unisim/verilog/src/unisims/MUXF7.v \
	&& \
		vvp sim

# ---------------------------------- UHDM ----------------------------------
.uhdm-integration:
	git clone https://github.com/alainmarcel/uhdm-integration.git \
		uhdm-integration && touch $@
# ---------------------------------- UHDM ----------------------------------

# ---------------------------------- IBEX ----------------------------------
.ibex:
	(cd $(PWD)/.. && git submodule update --init --recursive ibex) && touch $@
# ---------------------------------- IBEX ----------------------------------

# ---------------------------------- UNISIM --------------------------------
.unisim:
	git clone https://github.com/Xilinx/XilinxUnisimLibrary.git unisim && touch $@
# ---------------------------------- UNISIM --------------------------------

# ---------------------------------- CMAKE ---------------------------------
CMAKE_VERSION = 3.18.1
CMAKE_URL = https://github.com/Kitware/CMake/releases/download/v$(CMAKE_VERSION)/cmake-$(CMAKE_VERSION).tar.gz

cmake-src.tar.gz:
	wget -c -O $@ $(CMAKE_URL) && touch $@

cmake-src/.dir:
	mkdir `dirname $@` && touch $@

cmake-src/.unpack: cmake-src.tar.gz cmake-src/.dir
	tar --strip-component=1 -xf $< -C `dirname $@` && touch $@

cmake-src/.conf: cmake-src/.unpack
	(cd cmake-src && ./bootstrap \
		--prefix=$(PWD)/uhdm-integration/image \
		--parallel=`nproc`) && touch $@

cmake-src/.build: cmake-src/.conf
	(cd cmake-src && make -j`nproc`) && touch $@

cmake-src/.install: cmake-src/.build
	(cd cmake-src && make install) && touch $@

.cmake: cmake-src/.install
# ---------------------------------- CMAKE ---------------------------------

# --------------------------------- SURELOG --------------------------------
$(PWD)/uhdm-integration/Surelog/CMakeLists.txt:
	(cd $(PWD)/uhdm-integration && \
		git submodule update --init --recursive Surelog && touch $@)

.surelog: $(PWD)/uhdm-integration/Surelog/CMakeLists.txt .cmake
	PATH="$(PWD)/uhdm-integration/image/bin:$$PATH" make \
		-C $(PWD)/uhdm-integration/Surelog \
		PREFIX=$(PWD)/uhdm-integration/image release install -j`nproc` && touch $@
# --------------------------------- SURELOG --------------------------------

# ---------------------------------- UHDM ----------------------------------
$(PWD)/uhdm-integration/UHDM/CMakeLists.txt:
	(cd $(PWD)/uhdm-integration && \
		git submodule update --init --recursive UHDM && touch $@)

.uhdm.patch: $(PWD)/uhdm-integration/UHDM/CMakeLists.txt
	(cd $(PWD)/uhdm-integration/UHDM && \
		git apply < ../UHDM.patch) && touch $@

.uhdm: .uhdm.patch .surelog .cmake
	mkdir -p $(PWD)/uhdm-integration/UHDM/build && \
	(cd $(PWD)/uhdm-integration/UHDM/build && \
		PATH="$(PWD)/uhdm-integration/image/bin:$$PATH" cmake \
		-DCMAKE_INSTALL_PREFIX=$(PWD)/uhdm-integration/image \
		-D_GLIBCXX_DEBUG=1 \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_FLAGS='-D_GLIBCXX_USE_CXX11_ABI=1 -DWITH_LIBCXX=Off' \
		../) && \
	$(MAKE) -C $(PWD)/uhdm-integration/UHDM install -j`nproc` && touch $@
# ---------------------------------- UHDM ----------------------------------

# ---------------------------------- YOSYS ---------------------------------
$(PWD)/uhdm-integration/yosys/Makefile:
	(cd $(PWD)/uhdm-integration && \
		git submodule update --init --recursive yosys && touch $@)

.yosys.patch: $(PWD)/uhdm-integration/yosys/Makefile
	(cd $(PWD)/uhdm-integration/yosys && \
		git apply < $(PWD)/uhdm-integration/tests/synthesis/yosys.patch) && touch $@

.yosys: .yosys.patch
	$(MAKE) -C $(PWD)/uhdm-integration/yosys -j`nproc` && touch $@
# ---------------------------------- YOSYS ---------------------------------
