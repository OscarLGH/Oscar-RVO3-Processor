module pc_reg (
	input wire clk,
	input wire rst,
	input wire stall,
	output reg[63:0] pc,
	output reg ce,
	input wire[63:0] inst_mem,
	output reg[31:0] inst_out
);

	always @ (posedge clk) begin
		if (rst == 1) begin
			ce <= 0;
		end else begin
			ce <= 1;
		end
	end

	always @ (posedge clk) begin
		if (ce == 0 ) begin
			pc <= 64'b0;
		end else begin
		    if (stall != 1'b1) begin
		        pc <= pc + 4;
		    end
		end
	end
	
	always @ (*) begin
		if (stall == 1'b1) begin
		    inst_out = 32'b0010011;        //insert bubble when stall
		end else begin
		    inst_out = inst_mem[31:0];
		end
	end

endmodule
