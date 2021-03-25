module soc (
    input wire clk_300_p,
    input wire clk_300_n,
    input wire reset,
    output wire outwire,
    output wire uart_tx,
    input wire uart_rx
);
    wire clk;
    reg[4:0] clk_divider;
	wire inst_addr_valid;
	wire inst_mem_valid;
	wire[63:0] inst_addr;
	wire[31:0] inst_data;
	wire rw;
	wire data_valid;
	wire[63:0] data_addr;
	wire[63:0] data;
    wire ori_clk;
    
    clk_wiz_0 ref_clk(
        .clk_out1(clk),     // output clk_out1
        .clk_in1_p(clk_300_p),    // input clk_in1_p
        .clk_in1_n(clk_300_n));    // input

    //assign clk = divider[1];
    //assign clk = ori_clk;
    assign ori_clk = clk;
    wire clk_1_2;
    wire clk_1_4;
    wire clk_1_8;
    
    always @ (posedge clk) begin
        clk_divider <= clk_divider + 1;
    end
    
    assign clk_1_2 = clk_divider[1];
    assign clk_1_4 = clk;//clk_divider[2];
    assign clk_1_8 = clk_divider[3];

    /*
    inst_rom bootrom (
        .clk(clk_1_4),
        .rst(reset),
        .ce(inst_addr_valid),
        .addr(inst_addr[63:2]),
        .valid(inst_mem_valid),
        .inst(inst_data)
    );
    */
    
    wire [63:0] cpu_addr;
    wire cpu_rw;
    wire [63:0] cpu_data_w;
    wire [63:0] cpu_data_r;
    wire axi_mem_ready;
    
    wire interrupt;
    wire [3:0]uart_axi_awaddr;
    wire uart_axi_awvalid;
    wire uart_axi_awready;
    wire [31:0]uart_axi_wdata;
    wire [3:0]uart_axi_wstrb;
    wire uart_axi_wvalid;
    wire uart_axi_wready;
    wire [1:0]uart_axi_bresp;
    wire uart_axi_bvalid;
    wire uart_axi_bready;
    wire [3:0]uart_axi_araddr;
    wire uart_axi_arvalid;
    wire uart_axi_arready;
    wire [31:0]uart_axi_rdata;
    wire [1:0]uart_axi_rresp;
    wire uart_axi_rvalid;
    wire uart_axi_rready;
    
    wire [3:0]inst_axi_awaddr;
    wire inst_axi_awvalid;
    wire inst_axi_awready;
    wire [31:0]inst_axi_wdata;
    wire [3:0]inst_axi_wstrb = 4'b1111;
    wire inst_axi_wvalid;
    wire inst_axi_wready;
    wire [1:0]inst_axi_bresp;
    wire inst_axi_bvalid;
    wire inst_axi_bready;
    wire [63:0]inst_axi_araddr;
    wire inst_axi_arvalid;
    wire inst_axi_arready;
    wire [31:0]inst_axi_rdata;
    wire [1:0]inst_axi_rresp;
    wire inst_axi_rvalid;
    wire inst_axi_rready;
    
    wire cpu_addr_valid;
    wire cpu_mem_done;
    cpu_core cpu_core (
        .clk(clk_1_4),
        .debug_clk(ori_clk),
        .rst(reset),
        .inst_mem_addr(inst_addr),
        .inst_addr_valid(inst_addr_valid),
        .inst_mem_valid(inst_mem_valid),
        .inst_mem_data(inst_data),
        
        .data_mem_rw(cpu_rw),
        .data_mem_addr(cpu_addr),
        .data_mem_addr_valid(cpu_addr_valid),
        .data_mem_ready(cpu_mem_done),
        .data_mem_data_w(cpu_data_w),
        .data_mem_data_r(cpu_data_r)
    );
    
    wire [63:0]addr_r;
    wire [63:0]addr_w;
    wire [63:0]data_r;
    wire [63:0]data_w;
    
    assign addr_r = (cpu_rw == 0) ? cpu_addr : 64'h0;
    assign addr_w = (cpu_rw == 1) ? cpu_addr : 64'h0;

    cpu_axi cpu_axi_lite_data (
        .clk(clk_1_4),
        .reset(reset),

        .r_busy(),
        .r_addr_valid(cpu_addr_valid),
        .r_addr(addr_r),
        .r_byte_valid(0'h7),
        .r_data_valid(cpu_mem_done),
        .r_data(data_r),

        .w_busy(),
        .w_addr_valid(cpu_addr_valid),
        .w_addr(addr_w),
        .w_data(data_w),
        .w_byte_valid(0'h7),
        
        .aclk(),
        .aresetn(~reset),
        .interrupt(),
        .s_axi_awaddr(uart_axi_awaddr),
        .s_axi_awvalid(uart_axi_awvalid),
        .s_axi_awready(uart_axi_awready),
        .s_axi_wdata(uart_axi_wdata),
        .s_axi_wstrb(uart_axi_wstrb),
        .s_axi_wvalid(uart_axi_wvalid),
        .s_axi_wready(uart_axi_wready),
        .s_axi_bresp(uart_axi_bresp),
        .s_axi_bvalid(uart_axi_bvalid),
        .s_axi_bready(uart_axi_bready),
        .s_axi_araddr(uart_axi_araddr),
        .s_axi_arvalid(uart_axi_arvalid),
        .s_axi_arready(uart_axi_arready),
        .s_axi_rdata(uart_axi_rdata),
        .s_axi_rresp(uart_axi_rresp),
        .s_axi_rvalid(uart_axi_rvalid),
        .s_axi_rready(uart_axi_rready)
    );

    axi_uartlite_0 uart_0 (
        .s_axi_aclk(clk_1_4),
        .s_axi_aresetn(~reset),
        .interrupt(axi_interrupt),
        .s_axi_awaddr(uart_axi_awaddr),
        .s_axi_awvalid(uart_axi_awvalid),
        .s_axi_awready(uart_axi_awready),
        .s_axi_wdata(uart_axi_wdata),
        .s_axi_wstrb(uart_axi_wstrb),
        .s_axi_wvalid(uart_axi_wvalid),
        .s_axi_wready(uart_axi_wready),
        .s_axi_bresp(uart_axi_bresp),
        .s_axi_bvalid(uart_axi_bvalid),
        .s_axi_bready(uart_axi_bready),
        .s_axi_araddr(uart_axi_araddr),
        .s_axi_arvalid(uart_axi_arvalid),
        .s_axi_arready(uart_axi_arready),
        .s_axi_rdata(uart_axi_rdata),
        .s_axi_rresp(uart_axi_rresp),
        .s_axi_rvalid(uart_axi_rvalid),
        .s_axi_rready(uart_axi_rready),
        
        .rx(uart_rx),
        .tx(uart_tx)
    );
    
    cpu_axi cpu_axi_lite_inst (
        .clk(clk_1_4),
        .reset(reset),

        .r_busy(),
        .r_addr_valid(inst_addr_valid),
        .r_addr(inst_addr),
        .r_byte_valid(0'h7),
        .r_data_valid(inst_mem_valid),
        .r_data(inst_data),

        .w_busy(),
        .w_addr_valid(),
        .w_addr(),
        .w_data(),
        .w_byte_valid(0'h0),
        
        .aclk(),
        .aresetn(~reset),
        .interrupt(),
        .s_axi_awaddr(),
        .s_axi_awvalid(),
        .s_axi_awready(),
        .s_axi_wdata(),
        .s_axi_wstrb(),
        .s_axi_wvalid(),
        .s_axi_wready(),
        .s_axi_bresp(),
        .s_axi_bvalid(),
        .s_axi_bready(),
        .s_axi_araddr(inst_axi_araddr),
        .s_axi_arvalid(inst_axi_arvalid),
        .s_axi_arready(inst_axi_arready),
        .s_axi_rdata(inst_axi_rdata),
        .s_axi_rresp(inst_axi_rresp),
        .s_axi_rvalid(inst_axi_rvalid),
        .s_axi_rready(inst_axi_rready)
    );
    blk_mem_gen_0 inst_rom (
        .rsta_busy(rsta_busy),          // output wire rsta_busy
        .rstb_busy(rstb_busy),          // output wire rstb_busy
        .s_aclk(clk_1_4),                // input wire s_aclk
        .s_aresetn(~reset),          // input wire s_aresetn
        .s_axi_awid(4'b0),        // input wire [3 : 0] s_axi_awid
        .s_axi_awaddr(32'b0),    // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen(8'b1),      // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize(3'b0),    // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst(2'b0),  // input wire [1 : 0] s_axi_awburst
        .s_axi_awvalid(1'b0),  // input wire s_axi_awvalid
        .s_axi_awready(1'b0),  // output wire s_axi_awready
        .s_axi_wdata(32'b0),      // input wire [31 : 0] s_axi_wdata
        .s_axi_wstrb(4'b0),      // input wire [3 : 0] s_axi_wstrb
        .s_axi_wlast(1'b0),      // input wire s_axi_wlast
        .s_axi_wvalid(1'b0),    // input wire s_axi_wvalid
        .s_axi_wready(1'b0),    // output wire s_axi_wready
        .s_axi_bid(4'b0),          // output wire [3 : 0] s_axi_bid
        .s_axi_bresp(2'b0),      // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid(1'b0),    // output wire s_axi_bvalid
        .s_axi_bready(1'b0),    // input wire s_axi_bready
        .s_axi_arid(4'b0),        // input wire [3 : 0] s_axi_arid
        .s_axi_araddr(inst_axi_araddr),    // input wire [31 : 0] s_axi_araddr
        .s_axi_arlen(8'b1),      // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize(3'b1),    // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst(2'b0),  // input wire [1 : 0] s_axi_arburst
        .s_axi_arvalid(inst_axi_arvalid),  // input wire s_axi_arvalid
        .s_axi_arready(inst_axi_arready),  // output wire s_axi_arready
        .s_axi_rid(s_axi_rid),          // output wire [3 : 0] s_axi_rid
        .s_axi_rdata(inst_axi_rdata),      // output wire [31 : 0] s_axi_rdata
        .s_axi_rresp(inst_axi_rresp),      // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast(s_axi_rlast),      // output wire s_axi_rlast
        .s_axi_rvalid(inst_axi_rvalid),    // output wire s_axi_rvalid
        .s_axi_rready(inst_axi_rready)    // input wire s_axi_rready
    );
    
    ila_0 ila_uart (
        .clk(ori_clk), // input wire clk
        .probe0(clk_1_4),
        .probe1(reset),
        .probe2(inst_axi_araddr),
        .probe3(inst_axi_arvalid),
        .probe4(inst_axi_arready),
        .probe5(inst_axi_rdata),
        .probe6(inst_axi_rresp),
        .probe7(inst_axi_rvalid),
        .probe8(inst_axi_rready),
        .probe9(inst_addr_valid),
        .probe10(inst_addr),
        .probe11(inst_mem_valid),
        .probe12(inst_data),
        .probe13(s_axi_araddr),
        .probe14(s_axi_arvalid),
        .probe15(s_axi_arready),
        .probe16(s_axi_rdata),
        .probe17(s_axi_rresp),
        .probe18(s_axi_rvalid),
        .probe19(s_axi_rready),
        .probe20(uart_tx),
        .probe21(uart_rx),
        .probe22(cpu_addr_valid),
        .probe23(inst_addr),
        .probe24(test_wire),
        .probe25(64'b0),
        .probe26(64'b0),
        .probe27(64'b0),
        .probe28(64'b0),
        .probe29(64'b0),
        .probe30(64'b0),
        .probe31(64'b0),
        .probe32(64'b0),
        .probe33(64'b0),
        .probe34(64'b0),
        .probe35(64'b0),
        .probe36(64'b0),
        .probe37(64'b0),
        .probe38(64'b0),
        .probe39(64'b0),
        .probe40(64'b0),
        .probe41(64'b0),
        .probe42(64'b0),
        .probe43(64'b0),
        .probe44(64'b0),
        .probe45(64'b0),
        .probe46(64'b0),
        .probe47(64'b0),
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
