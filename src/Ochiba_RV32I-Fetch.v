//-------------------------------------------------------
//
// Ochiba_RV32I-Fetch.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// 1st stage: Instruction Fetch(IF) stage
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------
module FETCH #(parameter WIDTH=32)
					(input clk,reset,IFREGclear,
					input [WIDTH-1:0]pcbranch,
					input pcwrcntl,
					output [WIDTH-1:0]pc,
					input  [WIDTH-1:0]nextinstrdata,
					output [WIDTH-1:0]REGFfetchdata,REGFpc,
					input IFREGstall);
					
					wire [WIDTH-1:0]nextpc = pc + 4;
					wire [WIDTH-1:0]muxnextpc;
					
					mux2		pcwrmux(nextpc,pcbranch,pcwrcntl,muxnextpc);
					ffrpc		pcreg(clk,reset,muxnextpc,pc);
					ffr		fetchreg(clk,IFREGclear,IFREGstall,nextinstrdata, REGFfetchdata);
					ffr		pcpipreg(clk,IFREGclear,IFREGstall,pc,REGFpc);
					
					
endmodule