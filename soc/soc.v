module soc (
    input wire CLK_125_P,
    input wire CLK_125_N,
    input wire CPU_RESET,
    output wire outwire
);
    wire clk;
    reg[4:0] divider;
	wire inst_addr_valid;
	wire inst_mem_valid;
	wire[63:0] inst_addr;
	wire[31:0] inst_data;
	wire rw;
	wire data_valid;
	wire[63:0] data_addr;
	wire[63:0] data;
    wire ori_clk;
    
    assign data_addr = 64'b0;
    assign data = 64'b0;
    assign rw = 1'b0;
    assign data_valid = 1'b0;
    

    IBUFGDS clkgen(.O(ori_clk),.I(CLK_125_P),.IB(CLK_125_N));

    always @ (posedge ori_clk) begin
		if (CPU_RESET == 1) begin
			divider <= 0;
		end else begin
			divider <= divider + 1;
		end
	end
  
    assign clk = divider[1];


//assign inst_addr = 64'b0;
//assign inst_addr_valid = 1'b1;
//assign CPU_RESET = 0;

inst_rom bootroom (
	.clk(clk),
	.rst(CPU_RESET),
	.ce(inst_addr_valid),
	.addr(inst_addr[63:2]),
	.valid(inst_mem_valid),
	.inst(inst_data)
);

cpu_core cpu_core (
	.clk(clk),
	.debug_clk(ori_clk),
	.rst(CPU_RESET),
	.inst_mem_addr(inst_addr),
	.inst_addr_valid(inst_addr_valid),
	.inst_mem_valid(inst_mem_valid),
	.inst_mem_data(inst_data),
	
	.data_mem_rw(),
	.data_mem_addr(),
	.data_mem_valid(),
	.data_mem_data()
);

endmodule
