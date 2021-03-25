module cpu_axi (
    input wire clk,
    input wire reset,

    output reg r_busy,
    input wire r_addr_valid,
    input wire [63:0]r_addr,
    input wire [7:0]r_byte_valid,
    output reg r_data_valid,
    output wire [63:0]r_data,

    output reg w_busy,
    input wire w_addr_valid,
    input wire [63:0]w_addr,
    input wire [63:0]w_data,
    input wire [7:0]w_byte_valid,
    
    output wire aclk,
    output wire aresetn,
    input wire interrupt,
    output wire [63:0]s_axi_awaddr,
    output reg s_axi_awvalid,
    input wire s_axi_awready,
    output wire [63:0]s_axi_wdata,
    output reg [3:0]s_axi_wstrb,
    output reg s_axi_wvalid,
    input wire s_axi_wready,
    input wire [1:0]s_axi_bresp,
    input wire s_axi_bvalid,
    output reg s_axi_bready,
    output wire [63:0]s_axi_araddr,
    output reg s_axi_arvalid,
    input wire s_axi_arready,
    input wire [31:0]s_axi_rdata,
    input wire [1:0]s_axi_rresp,
    input wire s_axi_rvalid,
    output reg s_axi_rready
);
    reg [3:0]axi_state_r;
    reg [3:0]axi_state_w;
    reg [63:0]axi_addr_reg;
    reg [63:0]axi_data_reg;
    
    assign s_axi_awaddr = w_addr ;
    assign s_axi_araddr = r_addr;
    assign s_axi_wdata = w_data;
    assign r_data = s_axi_rdata;

    localparam IDLE = 4'h1;
    localparam RD_ADDR = 4'h2;
    localparam RD_DATA = 4'h3;
    localparam WR_ADDR = 4'h4;
    localparam WR_DATA = 4'h5;
    localparam DONE = 4'h6;
    localparam RESET = 4'h0;
    
    assign data = axi_data_reg;
    assign aresetn = ~reset;
    assign aclk = clk;
 
    always @ (posedge aclk) begin
        if (reset == 1'b1) begin
			axi_state_r <= IDLE;
			r_busy <= 1'b0;
			s_axi_arvalid <= 0;
			s_axi_rready <= 0;
		end else begin

		    case (axi_state_r)
		        IDLE:begin
                    r_busy <= 1'b0;
                    s_axi_arvalid <= 1'b0;
                    s_axi_rready <= 1'b0;
                    r_data_valid <= 1'b0;
		            if (r_addr_valid == 1'b1) begin
		                axi_state_r <= RD_ADDR;
		            end
		        end
		        RD_ADDR:begin
		            s_axi_arvalid <= 1'b1;
                    r_busy <= 1'b1;

		            if (s_axi_arready == 1'b1) begin
		                axi_state_r <= RD_DATA;
		            end
		        end
		        RD_DATA:begin
		            s_axi_arvalid <= 1'b0;
		            s_axi_rready <= 1'b1;
		            if (s_axi_rvalid == 1'b1) begin
		                axi_state_r <= DONE;
		                r_data_valid <= 1'b1;
		            end
		        end
		        DONE:begin
		            if (r_addr_valid == 1'b0) begin
		                s_axi_rready <= 1'b0;
		                axi_state_r <= IDLE;
		                r_busy <= 1'b0;
		                r_data_valid <= 1'b0;
		            end
		        end
		        RESET:begin
                    r_busy <= 1'b0;
                    s_axi_arvalid <= 1'b0;
                    s_axi_rready <= 1'b0;
                    axi_state_r <= IDLE;
		        end
		        default:begin
		            axi_state_r <= IDLE;
		        end
		    endcase
		end
	end
	
	always @ (posedge aclk) begin
        if (reset == 1'b1) begin
			axi_state_w <= IDLE;
			r_busy <= 1'b0;
			s_axi_awvalid <= 0;
			s_axi_wvalid <= 0;
		end else begin
		    case (axi_state_w)
		        IDLE:begin
                    s_axi_awvalid <= 1'b0;
		            s_axi_wvalid <= 1'b0;

		            if (w_addr_valid == 1'b1) begin
		                axi_state_w <= WR_ADDR;
		            end
		        end
		        WR_ADDR:begin
		            s_axi_awvalid <= 1'b1;
		            s_axi_wvalid <= 1'b1;
		            r_busy <= 1'b1;

		            if (s_axi_bvalid == 1'b1) begin
		                s_axi_awvalid <= 1'b0;
		                s_axi_wvalid <= 1'b0;

		                if (s_axi_bresp != 2'b0) begin
		                //failed.retry...
		                    axi_state_w <= RESET;
		                end else begin
		                    axi_state_w <= DONE;
		                end
		            end
		        end
		        DONE:begin
		            r_busy <= 1'b0;
		            if (w_addr_valid == 1'b0) begin
		                axi_state_w <= IDLE;
		            end
		        end
		        RESET:begin
		            r_busy <= 1'b0;
                    axi_state_w <= 4'h0;
                    s_axi_awvalid <= 0;
                    s_axi_wvalid <= 0;
		            axi_state_w <= IDLE;
		        end
		        default:begin
		            axi_state_w <= IDLE;
		        end
		    endcase
		end
	end
    
endmodule