module if_id(
	input wire clk,
	input wire rst,
	input wire[63:0] if_pc,
	input wire[31:0] if_inst,
	input wire stall,
	output reg[63:0] id_pc,
	output reg[31:0] id_inst
);

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			id_pc <= 64'b0;
			id_inst <= 32'b0;
		end else begin
			id_pc <= if_pc;
			id_inst <= if_inst;
		end
	end

endmodule
