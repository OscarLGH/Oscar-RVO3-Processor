`define MEM_DELAY 4

module mem (
	input wire clk,
	input wire rst,

    input wire ce,
	input wire data_mem_rw,
	input wire[63:0] mem_data,
	input wire[7:0] mem_data_byte_valid,
	input wire[63:0] addr,

    input wire data_mem_ready,
    output wire[63:0] result,
	output reg stall
);
	assign result = (ce == 1'b1 && data_mem_rw == 1'b0) ? mem_data : addr;

	always @(*) begin
		if (rst == 1'b1) begin
			stall = 1'b0;
		end else begin
		    if (ce == 1'b1) begin
			    stall = 1'b1;
			end
			
			if (data_mem_ready == 1'b1) begin
			    stall = 1'b0;
			end
		end	
	end

endmodule
