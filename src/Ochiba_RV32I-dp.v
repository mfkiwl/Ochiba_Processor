//-------------------------------------------------------
//
// Ochiba_RV32I-dp.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// Ochiba Processer RV32I model
// Datapath and Pipeline
//
//-------------------------------------------------------
module Ochiba_RV32IM_dp #(parameter WIDTH = 32)
						(input 			clk,reset,
						 input [WIDTH-1:0]	instrmemdata,
						 input [WIDTH-1:0]	dmemrdata,
						 output[WIDTH-1:0]	instraddress,
						 output[WIDTH-1:0]	dmemaddr,
						 output[WIDTH-1:0]	dmemwdata,
						 output              wenable,
						 output[11:0]			csraddr,
						 output[WIDTH-1:0]	csroutputdata,
						 input[WIDTH-1:0]		csrreaddata,
						 output              csrwe,
						 input              IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,
						 output          Exnow,branch);
						 	
	wire	[4:0]		    REGDrs1,REGDrs2,REGDrd,REGRrd,ra1,ra2,REGArd,REGMrd,regaddr;
	wire	[31:0]	    imm,branchimm,storeimm,jimm,luiimm,csrimm;
	wire [WIDTH-1:0]   pc, nextpc,dnextpc, md, rd1, rd2, wd, a, src1, src2, aluresult,
                      aluout, constx4,pcbranch,lcmemdata,REGFfetchdata,REGFpc,REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,
							 REGDpc,REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg1data,REGRreg2data,regwd,REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,
							 REGMaluresult,REGMbranchimm,REGMpc,REGMreg1data,REGMreg2data,REGMdmemdata,REGMcsrrdata;
	wire              REGDiord,REGRiord,REGAiord,regwe,REGDalusel,REGRalusel,REGDregwrite,REGDwenable,REGDcsrrw,REGRregwrite,REGRwenable,REGRcsrrw,REGAwenable,REGAregwrite,REGAcsrrw,REGAzero,REGMregwrite,REGMzero,pcwrcntl;
	wire  [1:0]        REGDregfwda,REGDregfwdb,REGRregfwda,REGRregfwdb,REGDalusrca,REGDmem2reg,REGDpcsource,REGRmem2reg,REGRpcsource,REGAmem2reg,
	                   REGApcsource,REGMmem2reg,REGMpcsource;
	wire  [2:0]        REGDllcntl,REGDslcntl,REGRllcntl,REGRslcntl,REGAllcntl,REGAslcntl;
	wire	[1:0]			REGDbranchcntl,REGRbranchcntl,REGAbranchcntl,REGMbranchcntl;
	wire  [3:0]        REGDalusrcb,REGDalucont,REGRalucont;
	wire  [11:0]       REGDcsraddr,REGRcsraddr,REGAcsraddr;
	assign branch = pcwrcntl;
   									 				 

	FETCH          IF(clk,reset,IFREGclear,pcbranch,pcwrcntl,instraddress,instrmemdata,REGFfetchdata,REGFpc,IFREGstall);
	DECODE         ID(clk,reset,IDREGclear,REGFfetchdata,REGFpc,
	               REGDrs1,REGDrs2,REGDrd,REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,REGDregfwda,REGDregfwdb,REGDalusrca,
                  REGDalusrcb,REGDmem2reg,REGDalucont,REGDpcsource,REGDiord,REGDllcntl,REGDslcntl,REGDalusel,REGDbranchcntl,REGDregwrite,REGDwenable,REGDcsrrw,REGDcsraddr,IDREGstall);
   REGISTERFILE   RF(clk,RFREGclear,REGDrs1,REGDrs2,REGDrd,REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,REGDregfwda,REGDregfwdb,REGDalusrca,REGDalusrcb,
					   REGDmem2reg,REGDalucont,REGDpcsource,REGDiord,REGDllcntl,REGDslcntl,REGDalusel,REGDbranchcntl,REGDregwrite,REGDwenable,REGDcsrrw,REGDcsraddr,REGRrd,REGRalua,REGRalub,REGRbranchimm,REGRpc,REGRreg2data,
					   REGRregfwda,REGRregfwdb,REGRmem2reg,REGRalucont,REGRpcsource,REGRllcntl,REGRslcntl,REGRalusel,REGRbranchcntl,REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,REGRcsraddr,ra1,ra2,rd1,rd2,RFREGstall);
	ALU            Ex(clk,reset,ExREGclear,REGRrd,REGRalua,REGRalub,REGRbranchimm,REGRpc,/*REGRreg1data,*/REGRreg2data,REGRregfwda,REGRregfwdb,REGRmem2reg,REGRalucont,REGRpcsource,REGRllcntl,REGRslcntl,REGRalusel,REGRbranchcntl,REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,
				      REGRcsraddr,REGArd,REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,REGAmem2reg,REGApcsource,REGAllcntl,REGAslcntl,REGAbranchcntl,REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,REGAzero,REGAcsraddr,ExREGstall,Exnow);
   MEMORYACCESS   MA(clk,MAREGclear,REGArd,REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,REGAmem2reg,REGApcsource,REGAllcntl,REGAslcntl,REGAbranchcntl,REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,REGAzero,REGAcsraddr,REGMrd,
				      REGMaluresult,REGMbranchimm,REGMpc,REGMmem2reg,REGMpcsource,REGMbranchcntl,REGMregwrite,REGMzero,REGMdmemdata,REGMcsrrdata,dmemaddr,dmemwdata,dmemrdata,wenable,csrreaddata,csroutputdata,csraddr,csrwe,MAREGstall);


	WRITEBACK      WB(REGMrd,REGMaluresult,REGMbranchimm,REGMpc,REGMmem2reg,REGMpcsource,REGMbranchcntl,REGMregwrite,REGMzero,
				      REGMdmemdata,REGMcsrrdata,regaddr,regwd,regwe,pcbranch,pcwrcntl);
	
			
	regfile 		REGISTER(clk,regwe,ra1,ra2,regaddr,regwd,rd1,rd2);


endmodule

module aluplus	#(parameter WIDTH = 32)
					(input	[WIDTH-1:0]a,b,
					output	[WIDTH-1:0]result);
					
			assign result = a + b;
			
endmodule



module regfile #(parameter WIDTH = 32)	//Register
						(input					clk,regwrite,
						input		[4:0]			ra1,ra2,rd,
						input		[WIDTH-1:0] wd,
						output	[WIDTH-1:0]	rd1,rd2);
						
		reg	[WIDTH-1:0]REG[31:0];
		
		initial begin
		REG[1] = 32'b0;
		REG[2] = 32'b0;
		REG[3] = 32'b0;
		REG[4] = 32'b0;
		REG[5] = 32'b0;
		REG[6] = 32'b0;
		REG[7] = 32'b0;
		REG[8] = 32'b0;
		REG[9] = 32'b0;
		REG[10] = 32'b0;
		REG[11] = 32'b0;
		REG[12] = 32'b0;
		REG[13] = 32'b0;
		REG[14] = 32'b0;
		REG[15] = 32'b0;
		REG[16] = 32'b0;
		REG[17] = 32'b0;
		REG[18] = 32'b0;
		REG[19] = 32'b0;
		REG[20] = 32'b0;
		REG[21] = 32'b0;
		REG[22] = 32'b0;
		REG[23] = 32'b0;
		REG[24] = 32'b0;
		REG[25] = 32'b0;
		REG[26] = 32'b0;
		REG[27] = 32'b0;
		REG[28] = 32'b0;
		REG[29] = 32'b0;
		REG[30] = 32'b0;
		REG[31] = 32'b0;
		end
		
		//to see register data in simulation
		wire [31:0] REG0,REG1,REG2,REG3,REG4,REG5,REG6,REG7,REG8,REG9,REGa,REGb,REGc,REGd,REGe,REGf,REG10,REG11,REG12,REG13,REG14,REG15;
		assign	REG0	= REG[0];
		assign	REG1	= REG[1];
		assign	REG2	= REG[2];
		assign	REG3	= REG[3];
		assign	REG4	= REG[4];
		assign	REG5	= REG[5];
		assign	REG6	= REG[6];
		assign	REG7	= REG[7];
		assign	REG8	= REG[8];
		assign	REG9	= REG[9];
		assign	REGa	= REG[10];
		assign	REGb	= REG[11];
		assign	REGc	= REG[12];
		assign	REGd	= REG[13];
		assign	REGe	= REG[14];
		assign	REGf	= REG[15];
		assign	REG10	= REG[16];
		assign	REG11	= REG[17];
		assign	REG12	= REG[18];
		assign	REG13	= REG[19];
		assign	REG14	= REG[20];
		assign	REG15 = REG[21];
		
		always @(posedge clk)
			if(regwrite) REG[rd] <= wd;	
			
		assign rd1 = ra1	?	REG[ra1] :	0;	//x0:Zero reg
		assign rd2 = ra2	?	REG[ra2]	:	0;
		
endmodule
		
module	zero	#(parameter WIDTH=32)
					(input	[WIDTH-1:0]	data,
					output				zero);
			
			assign zero = (data == 32'b0);
					
endmodule

module	widthcntl	#(parameter WIDTH = 32)
						(input	[WIDTH-1:0]	indata,
						input		[2:0]			length,
						output 	[WIDTH-1:0]	outdata);
						
	assign outdata = width(indata,length);

   function [31:0]width;
	   input [31:0]indata;
	   input [2:0]length;
	
			begin
				case(length)
				3'b000:width			=	indata;	//LW(Load Word)
				3'b001:begin							//LHU(Load Half-word Unsigned)
							width[15:0]	=	indata[15:0];
							width[31:16]	=	16'b0;
						end
				3'b010:begin							//LBU(Load Byte Unsigned)
							width[7:0]	=	indata[7:0];
							width[31:8]	=	24'b0;
						end
				3'b011:begin							//LH(Load Half-word)
							width[15:0]	=	indata[15:0];
							if(indata[15] == 1)width[31:16]	=	16'hffff;
							else width[31:16]	=	16'b0;
						end
				3'b100:begin							//LB(Load Byte)
							width[7:0]	=	indata[7:0];
							if(indata[7] == 1)width[31:8]	=	24'hffffff;
							else width[31:8]	=	24'b0;
						end
				default:	width		=	indata;	
				endcase
			end
   endfunction

endmodule



module ff	#(parameter WIDTH = 32)
				(input				clk,
				input			[WIDTH-1:0]	indata,
				output reg	[WIDTH-1:0]	outdata);
			
			always @(posedge clk)
				outdata <= indata;
						
endmodule	

module ffr	#(parameter WIDTH = 32)
				(input				clk,reset,stall,
				input			[WIDTH-1:0]	indata,
				output reg	[WIDTH-1:0]	outdata);
				
			initial begin
			outdata <= 32'b0;
			end

            wire [WIDTH-1:0] ffwrdata;
           assign ffwrdata = stall ? outdata : indata;
                			
			always @(posedge clk)
			if			(reset)	outdata <= 32'b0;
			else		 outdata <= ffwrdata;	
			
endmodule

module ffr1	(input				clk,reset,stall,
				input			indata,
				output reg	outdata);
				
			initial begin
			outdata <= 1'b0;
			end
				
                 wire   ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 1'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr2	(input				clk,reset,stall,
				input			[1:0]	indata,
				output reg	[1:0]	outdata);
				
			initial begin
			outdata <= 2'b0;
			end
				
                    wire [1:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 2'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr3	(input				clk,reset,stall,
				input			[2:0]	indata,
				output reg	[2:0]	outdata);
				
			initial begin
			outdata <= 3'b0;
			end
				
                    wire [2:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 3'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr4	(input		clk,reset,stall,
				input			[3:0]	indata,
				output reg	[3:0]	outdata);
				
			initial begin
			outdata <= 3'b0;
			end
				
			  wire [3:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 4'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr5	(input				clk,reset,stall,
				input			[4:0]	indata,
				output reg	[4:0]	outdata);
				
			initial begin
			outdata <= 5'b0;
			end
				
                     wire [4:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 5'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr7	(input				clk,reset,stall,
				input			[6:0]	indata,
				output reg	[6:0]	outdata);
				
			initial begin
			outdata <= 7'b0;
			end
				
                     wire [6:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 7'b0;
                      else         outdata <= ffwrdata;    
			
endmodule

module ffr12	(input				clk,reset,stall,
				input			[11:0]	indata,
				output reg	[11:0]	outdata);
				
			initial begin
			outdata <= 12'b0;
			end
				
                     wire [11:0] ffwrdata;
                     assign ffwrdata = stall ? outdata : indata;
                                      
                      always @(posedge clk)
                      if            (reset)    outdata <= 12'b0;
                      else         outdata <= ffwrdata;    
			
endmodule



module ffrpc	#(parameter WIDTH = 32)
				(input				clk,reset,
				input			[WIDTH-1:0]	indata,
				output reg	[WIDTH-1:0]	outdata);
				
			initial begin
			outdata <= 32'h0000_0000;
			end
				
			always @(posedge clk)
			if			(reset)	outdata <= 32'b0;
			else		 outdata <= indata;	
			
endmodule



module ffenable #(parameter WIDTH = 32)	//Flip Flop with enable
						(input				clk,enable,
						input			[WIDTH-1:0]	indata,
						output reg	[WIDTH-1:0]	outdata);
			
			always @(posedge clk)
				if(enable) outdata <= indata;
						
endmodule									

module ffenabler #(parameter WIDTH = 32)	//Flip Flop with enable and reset
						(input				clk,reset,enable,
						input			[WIDTH-1:0]	indata,
						output reg	[WIDTH-1:0]	outdata);
			
			always @(posedge clk)
				if			(reset)	outdata <= 0;
				else if	(enable)	outdata <= indata;
						
endmodule	

module mux2	#(parameter WIDTH = 32) //2-input MUX
				(input	[WIDTH-1:0]	data0,data1,
				input						seldata,
				output	[WIDTH-1:0]	outdata);
				
	assign outdata = seldata ? data1 : data0;
	
endmodule


module mux4	#(parameter WIDTH = 32) //4-input MUX
				(input		[WIDTH-1:0]	data0,data1,data2,data3,
				input			[1:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
			
	assign outdata = mux4f(data0,data1,data2,data3,seldata);
				
	function [31:0]mux4f;
		input [31:0]data0,data1,data2,data3;
		input			[1:0]			seldata;
		begin
		case (seldata)
			2'b00: mux4f	= data0;
			2'b01: mux4f	= data1;
			2'b10: mux4f	= data2;
			2'b11: mux4f	= data3;
		endcase
		end
	endfunction
endmodule

module mux8	#(parameter WIDTH = 32) //8-input MUX
				(input		[WIDTH-1:0]	data0,data1,data2,data3,data4,data5,data6,data7,
				input			[2:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
				
	assign outdata = mux8f(data0,data1,data2,data3,data4,data5,data6,data7,seldata);
	
	function [31:0]mux8f;
		input [31:0]data0;
		input [31:0]data1;
		input [31:0]data2;
		input [31:0]data3;
		input [31:0]data4;
		input [31:0]data5;
		input [31:0]data6;
		input [31:0]data7;
		input	[2:0]	seldata;
		begin
		
		case (seldata)
			3'b000: mux8f = data0;
			3'b001: mux8f = data1;
			3'b010: mux8f = data2;
			3'b011: mux8f = data3;
			3'b100: mux8f = data4;
			3'b101: mux8f = data5;
			3'b110: mux8f = data6;
			3'b111: mux8f = data7;
		endcase
		end
	endfunction
endmodule

module mux16	#(parameter WIDTH = 32) //16-input MUX
				(input		[WIDTH-1:0]	data0,data1,data2,data3,data4,data5,data6,data7,data8,data9,dataa,datab,datac,datad,datae,dataf,
				input			[3:0]			seldata,
				output 	[WIDTH-1:0]	outdata);
				
	assign outdata = mux16f(data0,data1,data2,data3,data4,data5,data6,data7,data8,data9,dataa,datab,datac,datad,datae,dataf,seldata);
	
	function [31:0]mux16f;
		input [31:0]data0;
		input [31:0]data1;
		input [31:0]data2;
		input [31:0]data3;
		input [31:0]data4;
		input [31:0]data5;
		input [31:0]data6;
		input [31:0]data7;
		input [31:0]data8;
		input [31:0]data9;
		input [31:0]dataa;
		input [31:0]datab;
		input [31:0]datac;
		input [31:0]datad;
		input [31:0]datae;
		input [31:0]dataf;
		input	[3:0]	seldata;
		begin
		
		case (seldata)
			4'b0000: mux16f = data0;
			4'b0001: mux16f = data1;
			4'b0010: mux16f = data2;
			4'b0011: mux16f = data3;
			4'b0100: mux16f = data4;
			4'b0101: mux16f = data5;
			4'b0110: mux16f = data6;
			4'b0111: mux16f = data7;
			4'b1000: mux16f = data8;
			4'b1001: mux16f = data9;
			4'b1010: mux16f = dataa;
			4'b1011: mux16f = datab;
			4'b1100: mux16f = datac;
			4'b1101: mux16f = datad;
			4'b1110: mux16f = datae;
			4'b1111: mux16f = dataf;
			
		endcase
		end
	endfunction
endmodule
