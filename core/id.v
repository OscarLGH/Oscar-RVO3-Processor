module id (
	input wire rst,
	input wire[63:0] pc,
	input wire[31:0] inst,

	input wire[63:0] reg1_data,
	input wire[63:0] reg2_data,

	output reg reg1_read_enable,
	output reg reg2_read_enable,
	output reg[4:0] reg1_addr,
	output reg[4:0] reg2_addr,

	output reg[7:0] aluop_o,
	output reg[2:0] alusel_o,
	output reg[63:0] reg1_o,
	output reg[63:0] reg2_o,
	output reg[4:0] write_addr_o,
	output reg write_enable_o
);

	wire [6:0] opcode = inst[6:0];
	wire [4:0] rd = inst[11:7];
	wire [2:0] funct3 = inst[14:12];
	wire [4:0] rs1 = inst[19:15];
	wire [4:0] rs2 = inst[25:20];
	wire [6:0] funct7 = inst[31:26];
	reg [63:0] imm;

	always @ (*) begin
		if (rst == 1'b1) begin
			aluop_o <= 8'b0;
			alusel_o <= 3'b0;
			write_addr_o <= 5'b0;
			write_enable_o <= 1'b0;
			reg1_read_enable <= 1'b0;
			reg2_read_enable <= 1'b0;
			reg1_addr <= 5'b0;
			reg2_addr <= 5'b0;
			imm <= 64'b0;
		end else begin
			aluop_o <= 8'b0;
			alusel_o <= 3'b0;
			write_addr_o <= rd;
			write_enable_o <= 1'b0;
			reg1_read_enable <= 1'b0;
			reg2_read_enable <= 1'b0;
			reg1_addr <= 5'b0;
			reg2_addr <= 5'b0;
			imm <= 64'b0;
		end

		if (opcode == 7'b0110011) begin
			alusel_o <= funct3;
		end
	end

endmodule
