//-------------------------------------------------------
//
// Ochiba_RV32I-ALU.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// 4th stage: Execution(Ex) stage
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------
module ALU #(parameter WIDTH=32)
           (input clk,reset,ExREGclear,
			   input [4:0]REGRrd,
				input [WIDTH-1:0]REGRalua,REGRalub,REGRbranchimm,REGRpc,/*REGRreg1data,*/REGRreg2data,
				input [1:0]REGRregfwda,REGRregfwdb,REGRmem2reg,
				input [3:0]REGRalucont,
				input [1:0]REGRpcsource,
				input [2:0]REGRllcntl,REGRslcntl,
				input REGRalusel,
				input [1:0]REGRbranchcntl,
				input REGRregwrite,REGRiord,REGRwenable,REGRcsrrw,
				input [11:0]REGRcsraddr,
				output [4:0]REGArd,
				output [WIDTH-1:0]REGAaluresult,REGAbranchimm,REGApc,REGAreg2data,
				output [1:0]REGAmem2reg,
				output [1:0]REGApcsource,
				output [2:0]REGAllcntl,REGAslcntl,
				output [1:0]REGAbranchcntl,
				output REGAregwrite,REGAiord,REGAwenable,REGAcsrrw,REGAzero,
				output [11:0]REGAcsraddr,
				input  ExREGstall,
				output Exnow);
				
				wire [WIDTH-1:0] aluresult,fwdreg1,fwdreg2,fwdreg3,aluasrc,alubsrc,aludata1,aludata2,muldivdata1,muldivdata2,calresult,muldivresult;
				wire [3:0]alucont,muldivcont;
				wire             zero;
				
				assign Exnow = 1'b0;
				
				alucntl     alucntl(REGRalusel,aluasrc,alubsrc,REGRalucont,aludata1,aludata2,alucont,muldivdata1,muldivdata2,muldivcont);
				alu			alu(aludata1,aludata2,alucont,aluresult);
				alu			muldiv(muldivdata1,muldivdata2,muldivcont,muldivresult);
				calcntl     calcntl(REGRalusel,aluresult,muldivresult,calresult);
				mux4			fwdregmuxa(REGRalua,fwdreg1,fwdreg2,fwdreg3,REGRregfwda,aluasrc);
				mux4			fwdregmuxb(REGRalub,fwdreg1,fwdreg2,fwdreg3,REGRregfwdb,alubsrc);
				
					
				//data-forwording register
				ffr fwdregister1		(clk,ExREGclear,ExREGstall,calresult,fwdreg1);
				ffr fwdregister2        (clk,ExREGclear,ExREGstall,fwdreg1,fwdreg2);
				ffr fwdregister3        (clk,ExREGclear,ExREGstall,fwdreg2,fwdreg3);
				
				//Zero-check
				zero			zerochk(aluresult,zero);

					ffr5 REGrd         (clk,ExREGclear,ExREGstall,REGRrd,REGArd);
					ffr  REGaluresult  (clk,ExREGclear,ExREGstall,aluresult,REGAaluresult);
					ffr  REGbranchimm  (clk,ExREGclear,ExREGstall,REGRbranchimm,REGAbranchimm);
					ffr  REGpc         (clk,ExREGclear,ExREGstall,REGRpc,REGApc);
					ffr  REGreg2       (clk,ExREGclear,ExREGstall,REGRreg2data,REGAreg2data);

					ffr2 REGmem2reg  (clk,ExREGclear,ExREGstall,REGRmem2reg,REGAmem2reg);
					ffr1 REGregwrite (clk,ExREGclear,ExREGstall,REGRregwrite,REGAregwrite);
					ffr2 REGpcsource (clk,ExREGclear,ExREGstall,REGRpcsource,REGApcsource);
					ffr1 REGiord     (clk,ExREGclear,ExREGstall,REGRiord,REGAiord);
					ffr1 REGzero     (clk,ExREGclear,ExREGstall,zero,REGAzero);
					ffr3 REGllcntl   (clk,ExREGclear,ExREGstall,REGRllcntl,REGAllcntl);
					ffr3 REGslcntl   (clk,ExREGclear,ExREGstall,REGRslcntl,REGAslcntl);
					ffr2 REGbrcntl   (clk,ExREGclear,ExREGstall,REGRbranchcntl,REGAbranchcntl);
					ffr1 wenable     (clk,ExREGclear,ExREGstall,REGRwenable,REGAwenable);
					ffr1  REGcsrrw   (clk,ExREGclear,ExREGstall,REGRcsrrw,REGAcsrrw);
					ffr12 REGcsraddr (clk,ExREGclear,ExREGstall,REGRcsraddr,REGAcsraddr);
				
endmodule

module alucntl(input alusel,
					input [31:0]data1,data2,
					input [3:0]cont,
					output [31:0]aludata1,aludata2,
					output [3:0]alucont,
					output [31:0]muldivdata1,muldivdata2,
					output [3:0]muldivcont);
					
				assign aludata1    = alusel ? 32'b0 : data1;
				assign muldivdata1 = alusel ? data1 : 32'b0;
				assign aludata2    = alusel ? 32'b0 : data2;
				assign muldivdata2 = alusel ? data2 : 32'b0;
				assign alucont     = alusel ? 4'b0  : cont;
			   assign muldivcont  = alusel ? cont  : 4'b0;
				
endmodule

module calcntl(input alusel,
					input [31:0]aluresult,muldivresult,
					output [31:0]calresult);
					
				assign calresult    = alusel ? muldivresult : aluresult;
				
endmodule

module alu #(parameter WIDTH = 32)
				(input		[WIDTH-1:0]	a, b,
				input			[3:0]			alucont,
				output		[WIDTH-1:0]	result);
				
			wire   [4:0]shamt = b[4:0];
			assign result = alu(a,b,alucont,shamt);

	function [31:0]alu;
		input [31:0]in1;
		input [31:0]in2;
		input [3:0]	alucont;
		input [4:0] shamt;
		
		begin
				case(alucont[3:0])
					4'b0000:	alu	=	in1 & in2; //a AND b
					4'b0001:	alu	=	in1 | in2;	//a OR b
					4'b0010:	alu	=	in1 ^ in2; //a XOR b
					4'b0011:	alu	=	in1 + in2;	//a ADD b
					4'b0100:	alu	=	in1 - in2; //a SUB b
					4'b0101:	alu	=	{31'b0, $signed(in1) < $signed(in2)};	//slt	
					4'b0110:	alu	=	{31'b0, in1 < in2};	//sltu
					4'b0111:	alu	=	in1 << shamt;	//sll	
					4'b1000:	alu	=	in1 >> shamt;	//srl
					4'b1001:	alu	=	$signed(in1) >>> shamt;	//sra
					4'b1010:	alu	=	~(a | (~b));
				   4'b1011: alu	=  {31'b0, $signed(in1) >= $signed(in2)};//sge
					4'b1100: alu	=  {31'b0, in1 >= in2};//sgeu
					4'b1101: alu   =  {31'b0, in1 == in2};//seq
					4'b1110: alu   =  {31'b0, in1 != in2};//sne
				
					default:	alu =	0;
				endcase
		end
	endfunction
			
endmodule
