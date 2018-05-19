//-------------------------------------------------------
//
// Ochiba_RV32I.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// Topmodule of Ochiba_RV32I
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------

module Ochiba_RV32I #(parameter WIDTH = 32)
				 (input inclk,inrst,
				 output [7:0] gpio);

				wire	[31:0]	instr,address;
				wire				zero,wdataenable;
				wire	[1:0]		alusrca;
				wire	[1:0]		mem2reg;
				wire				iord, pcen, regwrite, regdest,reset,clk;
				wire	[1:0]		pcsource;
				wire	[3:0]		alusrcb;
				wire	[2:0]		llcntl,slcntl;
				wire				irwrite;	
				wire	[2:0]		funct3;
				wire	[4:0]		alucont;
				wire	[31:0]	memdata,writedata,mmemdata,dmemdata,instrmemdata,datamemdata,rsdata1,rsdata2,csrindata,csroutdata,mmemdata_h;
				wire  [31:0]   instraddress,dataaddress;
				wire           memread, wenable,csrrw,denable,IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,Exnow;
				wire           branch;
				wire	[15:0]	adr,addr;
				wire	[6:0]		opcode,funct7;
				wire	[11:0]	imm12,csraddr;

				assign reset = ~inrst;
				assign clk = ~inclk;
				assign wdataenable = 0;
								
				Ochiba_RV32IM_cont controller(clk,reset,branch,IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,Exnow);
													
				Ochiba_RV32IM_dp dp(clk,reset,instrmemdata,datamemdata,instraddress,dataaddress,writedata,wenable,csraddr,csrindata,csroutdata,csrrw,IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,Exnow,branch);

				instr_ram		instr_ram(writedata,instraddress,clk,wdataenable,instrmemdata);
				
				data_ram			data_ram(writedata,dataaddress,clk,wenable,datamemdata);
				gpio				gpio_cntl(dataaddress,writedata,clk,wenable,gpio);
				sysreg 	system_reg(clk,csrrw,reset,csraddr,csrindata,csroutdata);
				
					
	
			 
endmodule
				 