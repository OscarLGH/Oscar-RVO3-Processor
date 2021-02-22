`define MEM_DELAY 4

module mem (
	input wire clk,
	input wire rst,

	input wire mem_valid,
	input wire mem_rw,
	input wire[63:0] mem_data,
	input wire[7:0] mem_data_byte_valid,
	input wire[63:0] addr,

    output reg[63:0] result,
	output reg stall
);
	reg [63:0] counter;
	reg mem_rw_o;
	reg[63:0] addr_o;
	reg[63:0] data_o;

	always @(mem_valid) begin
	    result = (mem_valid == 1'b1) ? data_o : addr;
	end

	always @(posedge clk) begin
		if (rst == 1'b1) begin
			mem_rw_o <= 1'b0;
			addr_o <= 64'b0;
			data_o <= 64'b0;
			stall <= 1'b0;
			counter <= 64'b0;
		end else begin
			if (mem_valid == 1'b1) begin
			    //stall = 1'b1;
			    // AXI state machine...
			    
				if (mem_rw == 1'b0) begin
				    //result <= addr;
				    data_o <= 64'h55aaaa55aa5555aa;
				end
			end
		end	
	end

endmodule
