module inst_rom(
	input clk,
	input rst,
	input wire ce,
	input wire[63:0] addr,
	output wire valid,
	output wire[31:0] inst
);

	reg[31:0] inst_mem[0:255];
	reg[31:0] counter;
	reg req;

    always @(posedge clk) begin
        if (rst == 1) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
    
    assign valid = counter[1] & counter[0];
	blk_mem_gen_0 inst_rom_0 (
  		.clka(clk),    // input wire clka
  		.ena(ce),      // input wire ena
  		.addra({{8'b0},addr[3:0]}),  // input wire [11 : 0] addra
  		.douta(inst)  // output wire [31 : 0] douta
	);

endmodule
