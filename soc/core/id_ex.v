module id_ex (
	input wire clk,
	input wire rst,
	
	input wire[7:0] aluop_i,
	input wire[3:0] alusel_i,
	input wire[63:0] oprand1_i,
	input wire[63:0] oprand2_i,
	input wire[4:0] reg_write_addr_i,
	input wire reg_write_enable_i,
	input wire mem_valid_i,
	input wire mem_rw_i,
	input wire[63:0] mem_data_i,
	input wire[7:0] mem_data_byte_valid_i,

	input wire stall,
	
	output reg[7:0] aluop_o,
	output reg[3:0] alusel_o,
	output reg[63:0] oprand1_o,
	output reg[63:0] oprand2_o,
	output reg[4:0] reg_write_addr_o,
	output reg reg_write_enable_o,
	output reg mem_valid_o,
	output reg mem_rw_o,
	output reg[63:0] mem_data_o,
	output reg[7:0] mem_data_byte_valid_o
);

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			aluop_o <= 8'b0;
			alusel_o <= 3'b0;
			oprand1_o <= 64'b0;
			oprand2_o <= 64'b0;
			reg_write_enable_o <= 1'b0;
			reg_write_addr_o <= 4'b0;
			mem_valid_o <= 1'b0;
			mem_rw_o <= 1'b0;
			mem_data_o <= 64'b0;
			mem_data_byte_valid_o <= 8'b0;
		end else if(stall != 1'b1) begin
			aluop_o <= aluop_i;
			alusel_o <= alusel_i;
			oprand1_o <= oprand1_i;
			oprand2_o <= oprand2_i;
			reg_write_enable_o <= reg_write_enable_i;
			reg_write_addr_o <= reg_write_addr_i;
			mem_valid_o <= mem_valid_i;
			mem_rw_o <= mem_rw_i;
			mem_data_o <= mem_data_i;
			mem_data_byte_valid_o <= mem_data_byte_valid_i;
		end
	end

endmodule
