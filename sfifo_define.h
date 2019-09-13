//===================================================================================
// File name:	sfifo_define.h
// Project:	Flexible synchronous FIFO
// Function:	
// Author:	nguyenquan.icd@gmail.com
// Website: http://nguyenquanicd.blogspot.com
//===================================================================================

//All defines are used to configured the synchronous FIFO before synthesizing
`define EMPTY_SIGNAL
`define FULL_SIGNAL
`define SET_LOW_EN
`define SET_HIGH_EN
`define LOW_TH_SIGNAL
`define HIGH_TH_SIGNAL
`define OV_SIGNAL
`define UD_SIGNAL
//`define OUTPUT_REG
//`define TWO_CLOCK
//The new defines of the version 2
//Only use the following options when TWO_CLOCK is not defined
`define WRITE_FULL_EN
`define READ_EMPTY_EN
//-----------------------------------------