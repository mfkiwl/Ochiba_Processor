//-------------------------------------------------------
//
// Ochiba_RV32I-RegisterFile.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// 3rd stage: Register File(RF) stage
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------
module REGISTERFILE #(parameter WIDTH=32)(
					input clk,RFREGclear,
					input [4:0]REGDrs1,REGDrs2,REGDrd,
					input [WIDTH-1:0]REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,
					input [1:0]REGDregfwda,REGDregfwdb,REGDalusrca,
					input [3:0]REGDalusrcb,
					input [1:0]REGDmem2reg,
					input [3:0]REGDalucont,
					input [1:0]REGDpcsource,
					input REGDiord,
					input [2:0]REGDllcntl,REGDslcntl,
					input REGDalusel,
					input [1:0]REGDbranchcntl,
					input REGDregwrite,REGDwenable,REGDcsrrw,
					input [11:0]REGDcsraddr,
					output [4:0]REGRrd,
					output [WIDTH-1:0]REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg2data,
					output [1:0]REGRregfwda,REGRregfwdb,REGRmem2reg,
					output [3:0]REGRalucont,
					output [1:0]REGRpcsource,
					output [2:0]REGRllcntl,REGRslcntl,
					output REGRalusel,
					output [1:0]REGRbranchcntl,
					output REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,
					output [11:0]REGRcsraddr,
					output [4:0]ra1,ra2,
					input	 [WIDTH-1:0]rd1,rd2,
					input RFREGstall);
					
					assign ra1 = REGDrs1;
					assign ra2 = REGDrs2;
					
					wire [WIDTH-1:0] src1,src2;
					
					parameter const_zero =	32'b0; //Zero
					parameter const_one	=	32'b1; //0xFFFFFFFF
					
					mux4			src1mux(rd1,REGDpc,32'b0,32'b0,REGDalusrca,src1);
					mux16			src2mux(rd2,32'b1,REGDimm,REGDjimm,REGDstoreimm,REGDluiimm,32'b0,REGDcsrimm,
					32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,32'b0,REGDalusrcb,src2);
					
					//DATA PASS LATCH
					ffr5 REGrd         (clk,RFREGclear,RFREGstall,REGDrd,REGRrd);
					ffr  REGsrc1       (clk,RFREGclear,RFREGstall,src1,REGRalua);
					ffr  REGsrc2       (clk,RFREGclear,RFREGstall,src2,REGRalub);
					ffr  REGbranchimm  (clk,RFREGclear,RFREGstall,REGDbranchimm,REGRbranchimm);
					ffr  REGpc         (clk,RFREGclear,RFREGstall,REGDpc,REGRpc);
               ffr  REGreg2data   (clk,RFREGclear,RFREGstall,rd2,REGRreg2data);

				//DECODER OUTPUT LATCH
					ffr2  REGregfwda  (clk,RFREGclear,RFREGstall,REGDregfwda,REGRregfwda);
					ffr2  REGregfwdb  (clk,RFREGclear,RFREGstall,REGDregfwdb,REGRregfwdb);
					ffr2  REGmem2reg  (clk,RFREGclear,RFREGstall,REGDmem2reg,REGRmem2reg);
					ffr1  REGregwrite (clk,RFREGclear,RFREGstall,REGDregwrite,REGRregwrite);
					ffr1  REGalusel   (clk,RFREGclear,RFREGstall,REGDalusel,REGRalusel);
					ffr4  REGalucont  (clk,RFREGclear,RFREGstall,REGDalucont,REGRalucont);
					ffr2  REGpcsource (clk,RFREGclear,RFREGstall,REGDpcsource,REGRpcsource);
					ffr1  REGiord     (clk,RFREGclear,RFREGstall,REGDiord,REGRiord);
					ffr3  REGllcntl   (clk,RFREGclear,RFREGstall,REGDllcntl,REGRllcntl);
					ffr3  REGslcntl   (clk,RFREGclear,RFREGstall,REGDslcntl,REGRslcntl);
					ffr2  REGbrcntl   (clk,RFREGclear,RFREGstall,REGDbranchcntl,REGRbranchcntl);
					ffr1  wenable     (clk,RFREGclear,RFREGstall,REGDwenable,REGRwenable);
					ffr1  REGcsrrw    (clk,RFREGclear,RFREGstall,REGDcsrrw,REGRcsrrw);
					ffr12 REGcsraddr  (clk,RFREGclear,RFREGstall,REGDcsraddr,REGRcsraddr);
					

			
endmodule