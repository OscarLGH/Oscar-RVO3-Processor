module pc_reg (
	input wire clk,
	input wire rst,
	input wire stall,
	output reg[63:0] pc,
	output reg ce
);

	always @ (posedge clk) begin
		if (rst == 1) begin
			ce <= 0;
		end else begin
			ce <= 1;
		end
	end

	always @ (posedge clk) begin
		if (ce == 0) begin
			pc <= 64'b0;
		end else if (stall != 1'b1) begin
			pc <= pc + 4;
		end
	end

endmodule
