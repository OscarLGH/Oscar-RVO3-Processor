`define MEM_DELAY 4

module mem (
	input wire clk,
	input wire rst,

	input wire mem_valid,
	input wire mem_rw,
	input wire[63:0] addr,

	output reg mem_rw_o,
	output reg[63:0] addr_o,
	output reg[63:0] data,
	output reg stall
);
	reg [63:0] counter;
	always @(posedge clk) begin
		if (rst == 1'b1) begin
			mem_rw_o <= 1'b0;
			addr_o <= 64'b0;
			data <= 64'b0;
			stall <= 1'b0;
			counter <= 64'b0;
		end else begin
			if (mem_valid == 1'b1) begin
				counter <= counter + 1;
				if (counter < `MEM_DELAY) begin
					stall <= 1'b1;
				end else begin
					stall <= 1'b0;
					counter <= 64'b0;
					data <= addr;
				end
			end
		end	
	end

endmodule
