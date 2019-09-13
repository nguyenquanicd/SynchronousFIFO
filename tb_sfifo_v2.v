//===================================================================================
// File name:	tb_sfifo.v
// Project:	Flexible synchronous FIFO
// Function:	The basic testbench of SFIFO
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================
`include "sfifo_define.h"
module tb_sfifo_v2;
`include "sfifo_parameter.h"

//inputs
`ifdef TWO_CLOCK
  reg clk_rd;
  reg clk_wr;
`else
  reg clk;
`endif
`ifdef SET_LOW_EN
  reg [POINTER_WIDTH:0] low_th;
`endif
`ifdef SET_HIGH_EN
  reg [POINTER_WIDTH:0] high_th;
`endif
reg rst_n;
reg wr;
reg rd;
reg [DATA_WIDTH-1:0] data_in;
//outputs
wire  [DATA_WIDTH-1:0] data_out;
`ifdef LOW_TH_SIGNAL
  wire sfifo_low_th;
`endif
`ifdef HIGH_TH_SIGNAL
  wire sfifo_high_th;
`endif
`ifdef OV_SIGNAL
  wire sfifo_ov;
`endif
`ifdef UD_SIGNAL
  wire sfifo_ud;
`endif
`ifdef EMPTY_SIGNAL
  wire  sfifo_empty;
`endif
`ifdef FULL_SIGNAL
  wire  sfifo_full;
`endif
`ifndef TWO_CLOCK
  `ifdef READ_EMPTY_EN
   wire sfifo_valid;
  `endif
`endif

sfifo_v2 dut (rst_n, wr, rd,
                  `ifdef TWO_CLOCK
                    clk_rd, clk_wr,
                  `else
                    clk,
                  `endif
                  `ifdef EMPTY_SIGNAL
                    sfifo_empty,
                  `endif
                  `ifdef FULL_SIGNAL
                    sfifo_full,
                  `endif
                  `ifdef SET_LOW_EN
                    low_th,
                  `endif
                  `ifdef SET_HIGH_EN
                    high_th,
                  `endif
                  `ifdef LOW_TH_SIGNAL
                    sfifo_low_th,
                  `endif
                  `ifdef HIGH_TH_SIGNAL
                    sfifo_high_th,
                  `endif
                  `ifdef OV_SIGNAL
                    sfifo_ov,
                  `endif
                  `ifdef UD_SIGNAL
                    sfifo_ud,
                  `endif
                  `ifndef TWO_CLOCK
                    `ifdef READ_EMPTY_EN
                      sfifo_valid,
                    `endif
                  `endif
                    data_in, data_out);

`ifdef TWO_CLOCK
  initial begin
    clk_rd = 0;
  	clk_wr = 0;
  end
  always #10 clk_wr = !clk_wr;
  always #20 clk_rd = !clk_rd;
  wire rclk = clk_rd;
  wire wclk = clk_wr;
`else
  initial begin
    clk = 0;
  	forever #10 clk = !clk;
  end
  wire rclk = clk;
  wire wclk = clk;
`endif

`ifdef SET_LOW_EN
  initial begin
    low_th[POINTER_WIDTH:0] = 2;
  end
`endif
`ifdef SET_HIGH_EN
  initial begin
    high_th[POINTER_WIDTH:0] = 5;
  end
`endif

initial begin
  rst_n = 0;
	#80
	rst_n = 1;
end

initial begin
  #80
  wr = 0;
  data_in[DATA_WIDTH-1:0] = 'd5;
  #71
  wr = 1;
  repeat (50) #40 wr = ~wr;
end

always @ (posedge wclk) data_in[DATA_WIDTH-1:0] <= data_in[DATA_WIDTH-1:0] + 1;

initial begin
  #80
  rd = 0;
  #71
  rd = 1;
  repeat (100) #80 rd = ~rd;
end

endmodule
