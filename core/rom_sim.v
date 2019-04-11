module inst_rom(
	input clk,
	input rst,
	input wire ce,
	input wire[63:0] addr,
	output reg valid,
	output reg[31:0] inst
);

	reg[31:0] inst_mem[0:255];
	reg[31:0] counter;
	reg req;

	initial $readmemh("inst_rom.data", inst_mem);

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			inst <= 32'b0;
			valid <= 1'b0;
			counter <= 32'b0;
			req <= 1'b0;
		end

		if (ce == 1'b1) begin
			req <= 1'b1;
		end

		if (req == 1'b1) begin
			counter <= counter + 1;

			if (counter == 32'h4) begin
				inst <= inst_mem[addr[63:2]];
				valid <= 1'b1;
			end else if (counter == 32'h5) begin
				valid <= 1'b0;
				counter <= 32'b0;
				req <= 1'b0;
			end
		end
	end

endmodule
