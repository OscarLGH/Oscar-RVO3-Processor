module test_bench;

	reg clock;
	reg rst;
	wire ce;
	wire [63:0] if_pc;
	wire [63:0] id_pc;
	wire [31:0] inst_if;
	wire [32:0] inst_id;

initial begin
	clock = 1'b0;
	forever #10 clock = ~clock;
end

initial begin

	rst = 1'b1;
	#195 rst = 1'b0;
	#1000 $stop;
end

pc_reg pc_reg_tb (
	.clk(clock),
	.rst(rst),
	.pc(if_pc),
	.ce(ce)
);

if_id if_id_tb (
	.clk(clock),
	.rst(rst),
	.if_pc(if_pc),
	.if_inst(inst_if),
	.id_pc(id_pc),
	.id_inst(inst_id)
);

endmodule
