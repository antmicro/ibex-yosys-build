`timescale 1ns/1ps

module sim;

reg clk = 1'b0;
reg rst = 1'b0;
reg tst = 1'b0;
reg dummy_instr_id_i = 1'b0;

reg [4:0] raddr_a_i;
reg [4:0] raddr_b_i;

wire [31:0] rdata_a_o;
wire [31:0] rdata_b_o;

reg  [4:0] waddr_a_i;
reg [31:0] wdata_a_i;

reg we_a = 1'b0;

glbl glbl();

work_ibex_register_file uut(
	.clk_i(clk),
	.rst_ni(rst),
	.test_en_i(tst),
	.dummy_instr_id_i(dummy_instr_id_i),

	.raddr_a_i(raddr_a_i),
	.raddr_b_i(raddr_b_i),

	.rdata_a_o(rdata_a_o),
	.rdata_b_o(rdata_b_o),

	.waddr_a_i(waddr_a_i),
	.wdata_a_i(wdata_a_i),
	.we_a_i(we_a)
);

initial forever #5 clk = !clk;
//initial begin $dumpfile("dump.vcd"); $dumpvars(0); end
initial #50 rst <= '1;

initial begin
	#50 raddr_a_i <= 5'h0;
	#50 $display("tb1:%4d:%08h:%08h", $time, raddr_a_i, rdata_a_o);
	#50 raddr_b_i <= 5'h0;
	#50 $display("tb1:%4d:%08h:%08h", $time, raddr_b_i, rdata_b_o);

	#50 waddr_a_i <= 5'h2; wdata_a_i <= 32'hdeadbeef; we_a <= '1; #50 we_a <= '0;
	#50 waddr_a_i <= 5'h3; wdata_a_i <= 32'h0badc0de; we_a <= '1; #50 we_a <= '0;

	#50 raddr_a_i <= 5'h2; #50 $display("tb1:%4d:%08h:%08h", $time, raddr_a_i, rdata_a_o);
	#50 raddr_b_i <= 5'h2; #50 $display("tb1:%4d:%08h:%08h", $time, raddr_b_i, rdata_b_o);

	#50 raddr_a_i <= 5'h3; #50 $display("tb1:%4d:%08h:%08h", $time, raddr_a_i, rdata_a_o);
	#50 raddr_b_i <= 5'h2; #50 $display("tb1:%4d:%08h:%08h", $time, raddr_b_i, rdata_b_o);
	$finish;
end

endmodule
