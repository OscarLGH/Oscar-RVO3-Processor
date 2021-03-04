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
    
    assign data_addr = 64'b0;
    assign data = 64'b0;
    assign rw = 1'b0;
    assign data_valid = 1'b0;
    
    reg [3:0]axi_state;
    reg [63:0]axi_addr_reg;
    reg [63:0]axi_data_reg;
    reg s_axi_awvalid_reg;
    reg s_axi_wvalid_reg;
    reg s_axi_rvalid_reg;
    reg s_axi_done;

    //IBUFGDS clkgen(.O(ori_clk),.I(clk_300_p),.IB(clk_300_n));
    clk_wiz_0 ref_clk
    (
    // Clock out ports
    .clk_out1(clk),     // output clk_out1
    //.clk_out2(ori_clk),     // output clk_out1
    // Status and control signals
    //.reset(reset), // input reset
    // Clock in ports
    .clk_in1_p(clk_300_p),    // input clk_in1_p
    .clk_in1_n(clk_300_n));    // input

    //assign clk = divider[1];
    //assign clk = ori_clk;
    assign ori_clk = clk;
    wire clk_1_2;
    wire clk_1_4;
    wire clk_1_8;
    
    assign clk_1_2 = clk_divider[1];
    assign clk_1_4 = clk;//clk_divider[2];
    assign clk_1_8 = clk_divider[3];

    //assign inst_addr = 64'b0;
    //assign inst_addr_valid = 1'b1;
    //assign CPU_RESET = 0;
    
    inst_rom bootrom (
        .clk(clk_1_4),
        .rst(reset),
        .ce(inst_addr_valid),
        .addr(inst_addr[63:2]),
        .valid(inst_mem_valid),
        .inst(inst_data)
    );
    
    wire [63:0] cpu_addr;
    wire axi_rw;
    wire [63:0] cpu_data_w;
    wire [63:0] cpu_data_r;
    wire axi_mem_ready;
    
    wire interrupt;
    wire [3:0]s_axi_awaddr;
    wire s_axi_awvalid;
    wire s_axi_awready;
    wire [31:0]s_axi_wdata;
    wire [3:0]s_axi_wstrb = 4'b1111;
    wire s_axi_wvalid;
    wire s_axi_wready;
    wire [1:0]s_axi_bresp;
    wire s_axi_bvalid;
    wire s_axi_bready;
    wire [3:0]s_axi_araddr;
    wire s_axi_arvalid;
    wire s_axi_arready;
    wire [31:0]s_axi_rdata;
    wire [1:0]s_axi_rresp;
    wire s_axi_rvalid;
    wire s_axi_rready;
    
    wire cpu_addr_valid;
    
    cpu_core cpu_core (
        .clk(clk_1_4),
        .debug_clk(ori_clk),
        .rst(reset),
        .inst_mem_addr(inst_addr),
        .inst_addr_valid(inst_addr_valid),
        .inst_mem_valid(inst_mem_valid),
        .inst_mem_data(inst_data),
        
        .data_mem_rw(axi_rw),
        .data_mem_addr(cpu_addr),
        .data_mem_addr_valid(cpu_addr_valid),
        .data_mem_ready(s_axi_done),
        .data_mem_data_w(cpu_data_w),
        .data_mem_data_r(cpu_data_r)
    );

    assign s_axi_awvalid = s_axi_awvalid_reg;
    assign s_axi_awaddr = axi_addr_reg[3:0];
    assign s_axi_wdata = axi_data_reg[31:0];
    assign s_axi_wvalid = s_axi_wvalid_reg;
    assign s_axi_bready = 1'b1;
    
    axi_uartlite_0 uart_0 (
        .s_axi_aclk(clk_1_4),
        .s_axi_aresetn(~reset),
        .interrupt(axi_interrupt),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wstrb(s_axi_wstrb),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        
        .rx(uart_rx),
        .tx(uart_tx)
    );
    
    ila_0 ila_uart (
        .clk(ori_clk), // input wire clk
        .probe0(clk_1_4),
        .probe1(reset),
        .probe2(axi_interrupt),
        .probe3(s_axi_awaddr),
        .probe4(s_axi_awvalid),
        .probe5(s_axi_awready),
        .probe6(s_axi_wdata),
        .probe7(s_axi_wstrb),
        .probe8(s_axi_wvalid),
        .probe9(s_axi_wready),
        .probe10(s_axi_bresp),
        .probe11(s_axi_bvalid),
        .probe12(s_axi_bready),
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
        .probe23(axi_state),
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

    localparam IDLE = 4'h1;
    localparam WR_REQ = 4'h2;
    localparam RD_REQ = 4'h3;
    localparam DONE = 4'h4;
    localparam RESET = 4'h0;
    
    reg [7:0] test_data;
    
    always @ (posedge clk) begin
        clk_divider <= clk_divider + 1;
    end
    
    always @ (posedge clk_1_4) begin
        if (reset == 1'b1) begin
		    test_data <= 8'b0;
			axi_state <= 4'h0;
			//axi_addr_reg <= 64'h4;
			//axi_data_reg <= 64'h48;
			//axi_addr_reg <= 64'hc;
			//axi_data_reg <= 64'h13;
			axi_addr_reg <= 64'h0;
            axi_data_reg <= 64'h0;
			s_axi_awvalid_reg <= 0;
			s_axi_wvalid_reg <= 0;
			s_axi_rvalid_reg <= 0;
			s_axi_done <= 0;
			//clk_divider <= 0;
		end else begin
		    //test_wire <= divider[4];
		    //test_data <= test_data + 1;
		    case (axi_state)
		        IDLE:begin //idle
		            s_axi_done <= 1'b0;
		            //s_axi_awvalid_reg <= 1'b0;
		            //s_axi_wvalid_reg <= 1'b0;
		            //if (cpu_addr_valid == 1'b1) begin
		            if (cpu_addr_valid == 1'b1) begin
		                axi_state <= 4'h1;
		                axi_addr_reg <= cpu_addr;
		                axi_data_reg <= cpu_data_w;
		                if (axi_rw == 1'b1) begin
		                    axi_state <= WR_REQ; 
		                end else begin
		                    axi_state <= RD_REQ;
		                end
		            end
		        end
		        WR_REQ:begin  //write addr and data
		            //axi_state <= 4'h2;
		            s_axi_awvalid_reg <= 1'b1;
		            s_axi_wvalid_reg <= 1'b1;
		            if (s_axi_bvalid == 1'b1) begin
		                s_axi_awvalid_reg <= 1'b0;
		                s_axi_wvalid_reg <= 1'b0;
		                if (s_axi_bresp != 2'b0) begin
		                //failed.retry...
		                    axi_state <= RESET;
		                end else begin
		                    axi_state <= DONE;
		                end
		            end
		        end
		        RD_REQ:begin //write addr and read data
		            axi_state <= IDLE;
		        end
		        DONE:begin //done
		            s_axi_done <= 1'b1;
		            //axi_addr_reg <= 64'h4;
                    //axi_data_reg <= (test_data % 32'd10) + 32'h30;
                    //test_data <= test_data + 1;
		            if (cpu_addr_valid == 1'b0) begin
		                axi_state <= IDLE;
		            end
		        end
		        RESET:begin
                    axi_state <= 4'h0;
                    axi_addr_reg <= 64'h0;
                    axi_data_reg <= 64'h0;
                    s_axi_awvalid_reg <= 0;
                    s_axi_wvalid_reg <= 0;
                    s_axi_rvalid_reg <= 0;
                    s_axi_done <= 0;
		            axi_state <= IDLE;
		        end
		        default:begin
		            axi_state <= IDLE;
		        end
		    endcase
		end
	end

endmodule
