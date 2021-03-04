module pipeline_ctrl (
	input wire rst,
	input wire[4:0] stall_req,
	output reg[4:0] stall,
	output reg pc_stall
);

	always @ (*) begin

		if (rst == 1'b1) begin
			stall = 5'b00000;
		end else begin

			if (stall_req[0] == 1'b1) begin
				stall = 5'b00001;
			end else if (stall_req[1] == 1'b1) begin
				stall = 5'b00011;
			end else if (stall_req[2] == 1'b1) begin
				stall = 5'b00111;
			end else if (stall_req[3] == 1'b1) begin
				stall = 5'b01111;
			end else if (stall_req[4] == 1'b1) begin
				stall = 5'b11111;
			end else begin
				stall = 5'b00000;
			end
			pc_stall <= |stall;
		end
	end
endmodule
