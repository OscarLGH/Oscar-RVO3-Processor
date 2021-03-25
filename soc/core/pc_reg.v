module pc_reg (
	input wire clk,
	input wire rst,
	input wire stall,
	output reg[63:0] pc,
	output reg inst_addr_valid,
	input wire inst_mem_valid,
	input wire[63:0] inst_mem,
	output reg[31:0] inst_out
);

    reg[3:0] pc_state;
    reg[8:0] inst_idx;

    localparam PC_IDLE = 4'h1;
    localparam PC_ADDR_VALID = 4'h2;
    localparam PC_DATA_VALID = 4'h3;

	always @ (posedge clk) begin
		if (rst == 1'b1) begin
			pc <= 64'b0;
			inst_addr_valid <= 0;
			pc_state <= PC_IDLE;
		end else begin
		    case (pc_state)
		        PC_IDLE:begin
		            inst_addr_valid <= 1;
		            pc_state <= PC_ADDR_VALID;
		        end
		        PC_ADDR_VALID:begin
		            if (inst_mem_valid == 1'b1) begin
		                pc_state <= PC_DATA_VALID;
		            end
		        end
		        PC_DATA_VALID:begin
		            inst_addr_valid <= 1'b0;
		            if (stall != 1'b1) begin
		                pc <= pc + 4;
		                pc_state <= PC_IDLE;
		            end
		        end
		        default:begin
		            pc_state <= PC_IDLE;
		        end
		    endcase
		end
	end
	
	always @ (*) begin
		if (stall == 1'b1 || inst_mem_valid != 1'b1) begin
		    inst_out = 32'b0010011;        //insert bubble when stall
		end else begin
		    inst_out = inst_mem[31:0];
		end
	end

endmodule
