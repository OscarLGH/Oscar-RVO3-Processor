module inst_rom(
	input wire ce,
	input wire[63:0] addr,
	output reg[31:0] inst
);

	reg[31:0] inst_mem[0:255];

	initial $readmemh("inst_rom.data", inst_mem);

	always @(*) begin
		if (ce == 1'b0) begin
			inst <= 32'b0;
		end else begin
			inst <= inst_mem[addr[63:2]];
		end
	end

endmodule
