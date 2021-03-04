module cpu_core (
	input wire clk,
	input wire debug_clk,
	input wire rst,

	output wire[63:0] inst_mem_addr,
	output wire inst_addr_valid,
	input wire inst_mem_valid,
	input wire[31:0] inst_mem_data,

	output wire[63:0] data_mem_addr,
	output wire data_mem_addr_valid,
	output wire data_mem_rw,
	output wire[63:0] data_mem_data_w,
	input wire[63:0] data_mem_data_r,
	input wire data_mem_ready
);

	wire [4:0] stall_req;
	wire [4:0] stall_sig;
	wire stall_pc;
	wire [4:0] test;

	assign stall_req[0] = ~inst_mem_valid;
	pipeline_ctrl pipe_ctrl(
		.rst(rst),
		.stall_req(stall_req),
		.stall(stall_sig),
		.pc_stall(stall_pc)
	);

    wire [31:0] inst;
	pc_reg instruction_fetch(
		.clk(clk),
		.rst(rst),
		.stall(stall_pc),
		.pc(inst_mem_addr),
		.inst_addr_valid(inst_addr_valid),
		.inst_mem(inst_mem_data),
		.inst_out(inst)
	);

	wire[63:0] id_pc;
	wire[31:0] id_inst;
	if_id if_id_reg(
		.clk(clk),
		.rst(rst),
		.stall(stall_sig[0]),
		.if_pc(inst_mem_addr),
		.if_inst(inst),
		.id_pc(id_pc),
		.id_inst(id_inst)
	);

	wire reg1_read_enable;
	wire[4:0] reg1_addr;
	wire reg2_read_enable;
	wire[4:0] reg2_addr;
	wire[63:0] reg1_data;
	wire[63:0] reg2_data;

	wire[7:0] aluop_id;
	wire[3:0] alusel_id;
	wire[63:0] oprand1_id;
	wire[63:0] oprand2_id;
	wire[4:0] reg_write_addr_id;
	wire reg_write_enable_id;
	wire mem_valid_id;
	wire mem_rw_id;
	wire[63:0] mem_data_id;
	wire[7:0] mem_data_byte_valid_id;

	wire[4:0] reg_write_addr_ex;
	wire reg_write_enable_ex;
	wire[63:0] result_ex;

	wire[63:0] result_mem;
	wire[4:0] reg_write_addr_mem;
	wire reg_write_enable_mem;

	id instruction_decode(
		.rst(rst),
		.inst(id_inst),
		.reg1_data(reg1_data),
		.reg2_data(reg2_data),
		.reg1_read_enable(reg1_read_enable),
		.reg2_read_enable(reg2_read_enable),
		.reg1_addr(reg1_addr),
		.reg2_addr(reg2_addr),
		.stall(stall_req[1]),

		/* forwarding logic */
		.reg_wr_enable_ex(reg_write_enable_ex),
		.reg_wr_addr_ex(reg_write_addr_ex),
		.reg_wr_data_ex(result_ex),
		.reg_wr_enable_mem(reg_write_enable_mem),
		.reg_wr_addr_mem(reg_write_addr_mem),
		.reg_wr_data_mem(result_mem),

		.aluop_o(aluop_id),
		.alusel_o(alusel_id),
		.oprand1(oprand1_id),
		.oprand2(oprand2_id),
		.reg_write_addr_o(reg_write_addr_id),
		.reg_write_enable_o(reg_write_enable_id),
		.mem_valid(mem_valid_id),
		.mem_rw(mem_rw_id),
		.mem_data(mem_data_id),
		.mem_data_byte_valid(mem_data_byte_valid_id)
	);

	wire[63:0] result_wb;
	wire[4:0] reg_write_addr_wb;
	wire reg_write_enable_wb;
	reg_file reg_file(
		.clk(clk),
		.rst(rst),
		.read1_enable(reg1_read_enable),
		.raddr1(reg1_addr),
		.rdata1(reg1_data),
		.read2_enable(reg2_read_enable),
		.raddr2(reg2_addr),
		.rdata2(reg2_data),
		.write_enable(reg_write_enable_wb),
		.waddr(reg_write_addr_wb),
		.wdata(result_wb)
	);

	wire[7:0] aluop_ex;
	wire[3:0] alusel_ex;
	wire[63:0] oprand1_ex;
	wire[63:0] oprand2_ex;
	wire mem_valid_ex;
	wire mem_rw_ex;
	wire[63:0] mem_data_ex;
	wire[7:0] mem_data_byte_valid_ex;

	id_ex id_ex_reg(
		.clk(clk),
		.rst(rst),
		.aluop_i(aluop_id),
		.alusel_i(alusel_id),
		.oprand1_i(oprand1_id),
		.oprand2_i(oprand2_id),
		.reg_write_addr_i(reg_write_addr_id),
		.reg_write_enable_i(reg_write_enable_id),
		.mem_valid_i(mem_valid_id),
		.mem_rw_i(mem_rw_id),
		.mem_data_i(mem_data_id),
		.mem_data_byte_valid_i(mem_data_byte_valid_id),
		.stall(stall_sig[1]),
		.aluop_o(aluop_ex),
		.alusel_o(alusel_ex),
		.oprand1_o(oprand1_ex),
		.oprand2_o(oprand2_ex),
		.reg_write_addr_o(reg_write_addr_ex),
		.reg_write_enable_o(reg_write_enable_ex),
		.mem_valid_o(mem_valid_ex),
		.mem_rw_o(mem_rw_ex),
		.mem_data_o(mem_data_ex),
		.mem_data_byte_valid_o(mem_data_byte_valid_ex)
	);

	ex execution(
		.rst(rst),
		.oprand1(oprand1_ex),
		.oprand2(oprand2_ex),
		.aluop(aluop_ex),
		.alusel(alusel_ex),
		.result(result_ex),
		.stall(stall_req[2])
	);
	
	wire mem_valid_mem;
	wire mem_rw_mem;
	wire[63:0] mem_data_mem;
	wire[7:0] mem_data_byte_valid_mem;
	
	ex_mem ex_mem_reg(
		.clk(clk),
		.rst(rst),
		.result_i(result_ex),
		.reg_write_addr_i(reg_write_addr_ex),
		.reg_write_enable_i(reg_write_enable_ex),
		.mem_valid_i(mem_valid_ex),
		.mem_rw_i(mem_rw_ex),
		.mem_data_i(mem_data_ex),
		.mem_data_byte_valid_i(mem_data_byte_valid_ex),
		.stall(stall_sig[2]),
		.result_o(result_mem),
		.reg_write_addr_o(reg_write_addr_mem),
		.reg_write_enable_o(reg_write_enable_mem),
		.mem_valid_o(mem_valid_mem),
		.mem_rw_o(mem_rw_mem),
		.mem_data_o(mem_data_mem),
		.mem_data_byte_valid_o(mem_data_byte_valid_mem)
	);
	
	wire [63:0] result_mem_1;
	mem mem(
	    .clk(clk),
	    .rst(rst),
	    .ce(mem_valid_mem),
	    .data_mem_rw(mem_rw_mem),
	    .mem_data(mem_data_mem),
	    .mem_data_byte_valid(mem_data_byte_valid_mem),
	    .addr(result_mem),
	    .data_mem_ready(data_mem_ready),
	    .result(result_mem_1),
	    .stall(stall_req[3])
	);
	
	assign data_mem_rw = mem_rw_mem;
	assign data_mem_addr = result_mem;
	assign data_mem_data_w = mem_rw_mem ? mem_data_mem : 64'bz;
	assign data_mem_addr_valid = mem_valid_mem & ~data_mem_ready;

	mem_wb mem_wb_reg(
		.clk(clk),
		.rst(rst),
		.result_i(result_mem_1),
		.reg_write_addr_i(reg_write_addr_mem),
		.reg_write_enable_i(reg_write_enable_mem),
		.stall(stall_sig[3]),
		.result_o(result_wb),
		.reg_write_addr_o(reg_write_addr_wb),
		.reg_write_enable_o(reg_write_enable_wb)
	);

    ila_0 ila_core_pipeline (
        .clk(debug_clk), // input wire clk
        .probe0(clk),
        .probe1(rst),
        .probe2(stall_sig[0]),
        .probe3(inst_mem_addr),
        .probe4(inst),
        .probe5(id_pc),
        .probe6(id_inst),
        .probe7(aluop_id),
        .probe8(alusel_id),
        .probe9(oprand1_id),
        .probe10(oprand2_id),
        .probe11(reg_write_addr_id),
        .probe12(reg_write_enable_id),
        .probe13(mem_valid_id),
        .probe14(mem_rw_id),
        .probe15(mem_data_id),
        .probe16(mem_data_byte_valid_id),
        .probe17(stall_sig[1]),
        .probe18(aluop_ex),
        .probe19(alusel_ex),
        .probe20(oprand1_ex),
        .probe21(oprand2_ex),
        .probe22(reg_write_addr_ex),
        .probe23(reg_write_enable_ex),
        .probe24(mem_valid_ex),
        .probe25(mem_rw_ex),
        .probe26(mem_data_ex),
        .probe27(mem_data_byte_valid_ex),
        .probe28(result_ex),
        .probe29(stall_sig[2]),
        .probe30(result_mem),
        .probe31(reg_write_addr_mem),
        .probe32(reg_write_enable_mem),
        .probe33(mem_valid_mem),
        .probe34(mem_rw_mem),
        .probe35(mem_data_mem),
        .probe36(mem_data_byte_valid_mem),
        .probe37(stall_sig[3]),
        .probe38(result_wb),
        .probe39(reg_write_addr_wb),
        .probe40(reg_write_enable_wb),
        .probe41(data_mem_rw),
        .probe42(data_mem_addr),
        .probe43(data_mem_ready),
        .probe44(stall_req),
        .probe45(data_mem_data_w),
        .probe46(data_mem_data_r),
        .probe47(inst_addr_valid),
        .probe48(64'b0),
        .probe49(64'b0),
        .probe50(64'b0),
        .probe51(64'b0),
        .probe52(64'b0),
        .probe53(64'b0),
        .probe54(64'b0),
        .probe55(64'b0),
        .probe56(64'b0),
        .probe57(64'b0),
        .probe58(64'b0),
        .probe59(64'b0),
        .probe60(64'b0),
        .probe61(64'b0),
        .probe62(64'b0),
        .probe63(64'b0)
    );

endmodule
