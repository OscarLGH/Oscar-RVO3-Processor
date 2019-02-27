`include "riscv-defines.v"

module ex (
	input wire rst,
	input wire[63:0] oprand1,
	input wire[63:0] oprand2,
	input reg[7:0] aluop_i,
	input reg[4:0] alusel_i,
	output reg[63:0] result
);

	always @ (*) begin
		if (rst == 1'b1) begin
			result <= 64'b0;
		end else begin
			case (alusel_i)
				`RISCV_ALU_ADD: begin
					result <= oprand1 + oprand2;
				end
				`RISCV_ALU_SUB: begin
					result <= oprand1 - oprand2;
				end
				`RISCV_ALU_XOR: begin
					result <= oprand1 ^ oprand2;
				end
				`RISCV_ALU_OR: begin
					result <= oprand1 | oprand2;
				end
				`RISCV_ALU_AND: begin
					result <= oprand1 & oprand2;
				end
			endcase
		end
	end

endmodule
