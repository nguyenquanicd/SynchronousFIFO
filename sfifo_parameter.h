//Parameters are used to set the capacity of FIFO
parameter DATA_WIDTH    = 8;
parameter POINTER_WIDTH = 3;
//
`ifndef SET_HIGH_EN
  parameter TH_LEVEL  = (2**POINTER_WIDTH)/2;
`else
  `ifndef SET_LOW_EN
     parameter TH_LEVEL  = (2**POINTER_WIDTH)/2;
  `endif
`endif
parameter DATA_NUM      = 2**POINTER_WIDTH;