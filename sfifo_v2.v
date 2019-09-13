//===================================================================================
// File name:	sfifo_v2.v
// Project:	Flexible synchronous FIFO
// Function:	Synchronous FIFO with the configuration parameters
//         v2: - Enable write when the FIFO is full 
//             - Enable read when the FIFO is empty with the valid signal
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================

//All defines are used to configured the synchronous FIFO before synthesizing
`include "sfifo_define.h"
module sfifo_v2 (rst_n, wr, rd,
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
`include "sfifo_parameter.h"
//inputs
`ifdef TWO_CLOCK
  input clk_rd;
  input clk_wr;
`else
  input clk;
`endif
`ifdef SET_LOW_EN
  input [POINTER_WIDTH:0] low_th;
`endif
`ifdef SET_HIGH_EN
  input [POINTER_WIDTH:0] high_th;
`endif
input rst_n;
input wr;
input rd;
input [DATA_WIDTH-1:0] data_in;
//outputs
output  reg [DATA_WIDTH-1:0] data_out;
`ifdef LOW_TH_SIGNAL
  output wire sfifo_low_th;
`endif
`ifdef HIGH_TH_SIGNAL
  output wire sfifo_high_th;
`endif
`ifdef OV_SIGNAL
  output wire sfifo_ov;
`endif
`ifdef UD_SIGNAL
  output wire sfifo_ud;
`endif
`ifdef EMPTY_SIGNAL
  output  sfifo_empty;
`else
  wire    sfifo_empty;
`endif
`ifdef FULL_SIGNAL
  output  sfifo_full;
`else
  wire    sfifo_full;
`endif
`ifndef TWO_CLOCK
  `ifdef READ_EMPTY_EN
    output reg sfifo_valid;
  `endif
`endif
//internal signals
reg [POINTER_WIDTH:0] w_pointer;
reg [POINTER_WIDTH:0] r_pointer;
reg [DATA_WIDTH-1:0] mem_array [DATA_NUM-1:0];
wire    msb_diff;
wire    lsb_equal;
wire    sfifo_re;
wire    sfifo_we;
//write pointer
`ifndef TWO_CLOCK
  `ifdef WRITE_FULL_EN
    assign sfifo_we = wr & (~(sfifo_full | (sfifo_empty & rd)) | (sfifo_full & rd));
  `else
    assign sfifo_we = wr & (~sfifo_full);
  `endif
`else
  assign sfifo_we = wr & (~sfifo_full);
`endif
//
`ifdef TWO_CLOCK
  wire rclk = clk_rd;
  wire wclk = clk_wr;
`else
  wire rclk = clk;
  wire wclk = clk;
`endif
always @ (posedge wclk or negedge rst_n) begin
  if (~rst_n) w_pointer <= {POINTER_WIDTH+1{1'b0}};
  else if (sfifo_we) w_pointer <= w_pointer+1'b1;
end
//read pointer
assign sfifo_re = rd & (~sfifo_empty);
//
always @ (posedge rclk or negedge rst_n) begin
  if (~rst_n) r_pointer <= {POINTER_WIDTH+1{1'b0}};
  else if (sfifo_re) r_pointer <= r_pointer + 1'b1;
end
//memory array and write decoder
always @ (posedge wclk) begin
  if (sfifo_we)
    mem_array[w_pointer[POINTER_WIDTH-1:0]]
             <= data_in[DATA_WIDTH-1:0];
end
//read decoder
`ifndef TWO_CLOCK
  `ifdef READ_EMPTY_EN
    wire forward_dt = sfifo_empty & rd & wr;
    wire [DATA_WIDTH-1:0] pre_data_out = forward_dt?
    data_in[DATA_WIDTH-1:0]: mem_array[r_pointer[POINTER_WIDTH-1:0]];
  `else
    wire [DATA_WIDTH-1:0] pre_data_out = mem_array[r_pointer[POINTER_WIDTH-1:0]];
  `endif
`else
  wire [DATA_WIDTH-1:0] pre_data_out = mem_array[r_pointer[POINTER_WIDTH-1:0]];
`endif
//
`ifdef OUTPUT_REG
  always @ (posedge rclk) begin
    data_out[DATA_WIDTH-1:0] <= pre_data_out[DATA_WIDTH-1:0];
  end
`else
  always @ (*) begin
    data_out[DATA_WIDTH-1:0] = pre_data_out[DATA_WIDTH-1:0];
  end
`endif
//status signal
assign  msb_diff = w_pointer[POINTER_WIDTH]
                  ^r_pointer[POINTER_WIDTH];
//
assign  lsb_equal = (w_pointer[POINTER_WIDTH-1:0]
                  == r_pointer[POINTER_WIDTH-1:0]);
//
assign  sfifo_full = msb_diff & lsb_equal;
//
assign  sfifo_empty = (~msb_diff) & lsb_equal;
//Overflow
`ifdef OV_SIGNAL
  reg ov_reg;
  `ifdef TWO_CLOCK
    assign sfifo_ov = ov_reg & sfifo_full;
    wire clr_ov = ~sfifo_full;
  `else
    wire clr_ov = rd;
    assign sfifo_ov = ov_reg;
  `endif
  //
  `ifdef WRITE_FULL_EN
    wire set_ov = wr & sfifo_full & ~rd;
  `else
    wire set_ov = wr & sfifo_full;
  `endif
  //
  always @ (posedge wclk) begin
    if (~rst_n) ov_reg <= 1'b0;
    else if (clr_ov) ov_reg <= 1'b0;
    else if (set_ov) ov_reg <= 1'b1;
  end
`endif
//Underflow
`ifdef UD_SIGNAL
  reg ud_reg;
  `ifdef TWO_CLOCK
    assign sfifo_ud = ud_reg & sfifo_empty;
    wire clr_ud = ~sfifo_empty;
  `else
    assign sfifo_ud = ud_reg;
    wire clr_ud = wr;
  `endif
  //
  `ifdef READ_EMPTY_EN
    wire set_ud = rd & sfifo_empty & ~wr;
  `else
    wire set_ud = rd & sfifo_empty;
  `endif
  //
  always @ (posedge rclk) begin
    if (~rst_n) ud_reg <= 1'b0;
    else if (clr_ud) ud_reg <= 1'b0;
    else if (set_ud) ud_reg <= 1'b1;
  end
`endif
//The minus result of two pointers
`ifdef LOW_TH_SIGNAL
  wire [POINTER_WIDTH:0] minus_result = w_pointer[POINTER_WIDTH:0] - r_pointer[POINTER_WIDTH:0];
`else
  `ifdef HIGH_TH_SIGNAL
    wire [POINTER_WIDTH:0] minus_result = w_pointer[POINTER_WIDTH:0] - r_pointer[POINTER_WIDTH:0];
  `endif
`endif
//The low threshold signal
`ifdef LOW_TH_SIGNAL
  `ifdef SET_LOW_EN
    wire [POINTER_WIDTH:0] low_level = low_th[POINTER_WIDTH:0];
  `else
    wire [POINTER_WIDTH:0] low_level = TH_LEVEL;
  `endif
`endif

`ifdef LOW_TH_SIGNAL
  assign sfifo_low_th = (minus_result[POINTER_WIDTH:0] < low_level[POINTER_WIDTH:0]);
`endif
//The high threshold signal
`ifdef HIGH_TH_SIGNAL
  `ifdef SET_HIGH_EN
    wire [POINTER_WIDTH:0] high_level = high_th[POINTER_WIDTH:0];
  `else
    wire [POINTER_WIDTH:0] high_level = TH_LEVEL;
  `endif
`endif

`ifdef HIGH_TH_SIGNAL
  assign sfifo_high_th = (minus_result[POINTER_WIDTH:0] >= high_level[POINTER_WIDTH:0]);
`endif
//The valid signal of the output data
`ifndef TWO_CLOCK
  `ifdef READ_EMPTY_EN
    `ifdef OUTPUT_REG
      always @ (posedge rclk) begin
        sfifo_valid <= ~sfifo_empty | forward_dt;
      end
    `else
       always @ (*) begin
        sfifo_valid = ~sfifo_empty | forward_dt;
      end 
    `endif
  `endif
`endif
endmodule
