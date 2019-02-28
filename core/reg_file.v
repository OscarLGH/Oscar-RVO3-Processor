module reg_file (
	input wire clk,
	input wire rst,
	input wire read1_enable,
	input wire[4:0] raddr1,
	output reg[63:0] rdata1,
	input wire read2_enable,
	input wire[4:0] raddr2,
	output reg[63:0] rdata2,
	input wire write_enable,
	input wire[4:0] waddr,
	input wire[63:0] wdata
);

	reg [63:0] reg_file[31:0];
	integer i;
	/* Reading regfile is a combinational logic operation because
	* we need to get oprand in 1 clock cycle.
	*/
	always @ (*) begin
		if (rst == 1'b1) begin
			rdata1 <= 64'b0;
			rdata2 <= 64'b0;
			for (i = 0; i < 32; i = i + 1) begin
				reg_file[i] <= i;
			end
		end
	end

	always @ (*) begin
		if (read1_enable == 1'b1) begin
			if (raddr1 == waddr) begin
				rdata1 <= wdata;
			end else begin
				rdata1 <= reg_file[raddr1];
			end
		end
	end

	always @ (*) begin
                if (read2_enable == 1'b1) begin
                        if (raddr2 == waddr) begin
                                rdata2 <= wdata;
                        end else begin
                                rdata2 <= reg_file[raddr2];
                        end
                end
        end

	/* Writing regfile is a sequencial logic operation
	* since there can't be a loop between reading and writing reg. 
	*/

	always @ (posedge clk) begin
		if (write_enable == 1'b1) begin
			reg_file[waddr] <= wdata;
		end
	end

endmodule

