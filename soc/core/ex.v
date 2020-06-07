`include "riscv-defines.v"

module ex (
	input wire rst,
	input wire[63:0] oprand1,
	input wire[63:0] oprand2,
	input wire[7:0] aluop,
	input wire[3:0] alusel,
	output reg[63:0] result,
	output reg stall
);

	always @ (*) begin
		if (rst == 1'b1) begin
			result <= 64'b0;
			stall <= 1'b0;
		end else begin
			case (alusel)
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
