module test_bench;

	reg clock;
	reg rst;
	wire inst_valid;
	wire[63:0] inst_addr;
	wire[31:0] inst_data;
	wire rw;
	wire data_valid;
	wire[63:0] data_addr;
	wire[63:0] data;

initial begin
	clock = 1'b0;
	forever #10 clock = ~clock;
end

initial begin

	rst = 1'b1;
	#195 rst = 1'b0;
	#1000 $stop;
end

assign inst_data = 32'b00000000001000001000000010110011;

cpu_core cpu_core_sim (
	.clk(clock),
	.rst(rst),
	.inst_mem_addr(inst_addr),
	.inst_mem_valid(inst_valid),
	.inst_mem_data(inst_data),
	
	.data_mem_rw(rw),
	.data_mem_addr(data_addr),
	.data_mem_valid(data_valid),
	.data_mem_data(data)
);


endmodule
