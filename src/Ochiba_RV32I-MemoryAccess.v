//-------------------------------------------------------
//
// Ochiba_RV32I-MemoryAccess.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// 5th stage: Memory Access(MA) stage
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------
module MEMORYACCESS #(parameter WIDTH=32)
                  (input clk,MAREGclear,
						input [4:0]REGArd,
				      input [WIDTH-1:0]REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,
				      input [1:0]REGAmem2reg,
				      input [1:0]REGApcsource,
				      input [2:0]REGAllcntl,REGAslcntl,
				      input [1:0]REGAbranchcntl,
						input REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,REGAzero,
				      input [11:0]REGAcsraddr,
						output [4:0]REGMrd,
				      output [WIDTH-1:0]REGMaluresult,REGMbranchimm,REGMpc,
				      output [1:0]REGMmem2reg,
				      output [1:0]REGMpcsource,
				      output [1:0]REGMbranchcntl,
						output REGMregwrite,REGMzero,
				      output [WIDTH-1:0]REGMdmemdata,REGMcsrrdata,
						output [WIDTH-1:0]dmemaddr,
						output [WIDTH-1:0]dmemwdata,
						input  [WIDTH-1:0]dmemrdata,
						output wenable,
						input  [31:0]csrreaddata,
						output [31:0]csroutputdata,
						output [11:0]csraddr,
						output csrwe,
						input  MAREGstall);
						
						wire [WIDTH-1:0]dataaddress,memrdata;
						
						assign dmemaddr = dataaddress;
						assign wenable   = REGAwenable;
						
					mux2			adressmux(REGApc,REGAaluresult,REGAiord,dataaddress);
						
					widthcntl	lw(dmemrdata,REGAllcntl,memrdata);
					widthcntl	sw(REGAreg2data,REGAslcntl,dmemwdata);	
					
               assign csroutputdata = REGAaluresult;
					assign csraddr = REGAcsraddr;
					assign csrwe = REGAcsrrw;
						
					ffr5 REGrd         (clk,MAREGclear,MAREGstall,REGArd,REGMrd);
					ffr  REGaluresult  (clk,MAREGclear,MAREGstall,REGAaluresult,REGMaluresult);
					ffr  REGdmemdata   (clk,MAREGclear,MAREGstall,memrdata,REGMdmemdata);
					ffr  REGcsrdata    (clk,MAREGclear,MAREGstall,csrreaddata,REGMcsrrdata);
					ffr  REGbranchimm  (clk,MAREGclear,MAREGstall,REGAbranchimm,REGMbranchimm);
					ffr  REGpc         (clk,MAREGclear,MAREGstall,REGApc,REGMpc);

					ffr2  REGmem2reg  (clk,MAREGclear,MAREGstall,REGAmem2reg,REGMmem2reg);
					ffr1  REGregwrite (clk,MAREGclear,MAREGstall,REGAregwrite,REGMregwrite);
					ffr2  REGpcsource (clk,MAREGclear,MAREGstall,REGApcsource,REGMpcsource);
					ffr2  REGbrcntl   (clk,MAREGclear,MAREGstall,REGAbranchcntl,REGMbranchcntl);
					ffr1  REGzero     (clk,MAREGclear,MAREGstall,REGAzero,REGMzero);

endmodule
