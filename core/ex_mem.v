module ex_mem (
	input wire clk,
	input wire rst,
	input wire[63:0] result_i,
	input wire[4:0] reg_write_addr_i,
	input wire reg_write_enable_i,
	input wire mem_valid_i,
	input wire mem_rw_i,

	input wire stall,

	output reg[63:0] result_o,
	output reg[4:0] reg_write_addr_o,
	output reg reg_write_enable_o,
	output reg mem_valid_o,
	output reg mem_rw_o
);

	always @(posedge clk) begin
		if (rst == 1'b1 || stall == 1'b1) begin
			result_o <= 64'b0;
			reg_write_addr_o <= 5'b0;
			reg_write_enable_o <= 1'b0;
			mem_valid_o <= 1'b0;
			mem_rw_o <= 1'b0;
		end	else begin
			result_o <= result_i;
			reg_write_addr_o <= reg_write_addr_i;
			reg_write_enable_o <= reg_write_enable_i;
			mem_valid_o <= mem_valid_i;
			mem_rw_o <= mem_rw_i;
		end
	end

endmodule
