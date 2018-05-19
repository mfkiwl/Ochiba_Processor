//-------------------------------------------------------
//
// Ochiba_RV32I-Decode.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// 2nd stage: Instruction Decode(ID) stage
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------
module DECODE #(parameter WIDTH=32)
					(input clk,reset,IDREGclear,
					input [WIDTH-1:0]REGfetchdata,REGFpc,
					output [4:0]REGDrs1,REGDrs2,REGDrd,
					output [WIDTH-1:0]REGDimm,REGDjimm,REGDbranchimm,REGDstoreimm,REGDluiimm,REGDcsrimm,REGDpc,
					output [1:0]REGDregfwda,REGDregfwdb,REGDalusrca,
					output [3:0]REGDalusrcb,
					output [1:0]REGDmem2reg,
					output [3:0]REGDalucont,
					output [1:0]REGDpcsource,
					output REGDiord,
					output [2:0]REGDllcntl,REGDslcntl,
					output REGDalusel,
					output [1:0]REGDbranchcntl,
					output REGDregwrite,REGDwenable,REGDcsrrw,
					output [11:0]REGDcsraddr,
					input  IDREGstall);
					
					wire	[4:0]		rs1,rs2,rd,rs1old1,rs2old1,rdold1,rs1old2,rs2old2,rdold2,rs1old3,rs2old3,rdold3;
					wire	[31:0]	imm,branchimm,storeimm,jimm,luiimm,csrimm;
					wire [WIDTH-1:0]   pc, nextpc;
					wire		[24:0]	systemcont;
					wire  [6:0]    opcode,opcode1,opcode2,opcode3,funct7;
					wire  [2:0]    funct3,llcntl,slcntl;
					wire  [11:0]   imm12,csraddr;
					wire  [1:0]    alusrca,mem2reg,pcsource;
					wire  [3:0]    alusrcb;
					wire           regwrite,iord,wenable,csrrw,alusel;
					wire  [1:0]		branchcntl;
					wire  [3:0]    alucont;
					
					wire [1:0] fwdold1,fwdold2,fwdold3,fwdmuxsela,fwdmuxselb;
                    wire [2:0] ereg0,ereg1,ereg2,ereg3;
						  wire [1:0] regc_1,regc_2,regc_3;
					
					assign rs1					=	REGfetchdata[19:15];	
					assign rs2					=	REGfetchdata[24:20];	
					assign rd					=	REGfetchdata[11:7];	
					assign imm[11:0]			=	REGfetchdata[31:20];	
					assign imm[31:12]			=	20'B0;
					assign jimm[0]				=	1'b0;
					assign jimm[10:1]			=	REGfetchdata[30:21];	
					assign jimm[11]			=	REGfetchdata[20];
					assign jimm[19:12]		=	REGfetchdata[19:12];
					assign jimm[20]			=	REGfetchdata[31];
					assign jimm[31:21]		=	{11{jimm[19]}};
					assign opcode				=	REGfetchdata[6:0];	
					assign funct3				=	REGfetchdata[14:12];	
					assign funct7				=	REGfetchdata[31:25];	
					assign imm12				=	REGfetchdata[31:20];	
					assign branchimm[0]		=	1'b0;
					assign branchimm[4:1]	=	REGfetchdata[11:8];	
					assign branchimm[10:5]	=	REGfetchdata[30:25];
					assign branchimm[11]		=	REGfetchdata[7];
					assign branchimm[12]		=	REGfetchdata[31];		
					assign branchimm[31:13]	=	{19{branchimm[11]}};
					assign storeimm[4:0]		=	REGfetchdata[11:7];
					assign storeimm[11:5]	=	REGfetchdata[31:25];
					assign storeimm[31:12]	=	{20{storeimm[11]}};
					assign luiimm[31:12]		=	REGfetchdata[31:12];
					assign luiimm[11:0]		=	12'b0;
					assign csraddr				=	imm12;
					assign csrimm[4:0]		=	REGfetchdata[19:15];
					assign csrimm[31:5]		=	27'b0;
					
					assign alusrca		=	systemcont[1:0];
					assign alusrcb		=	systemcont[5:2];
					assign mem2reg		=	systemcont[7:6];
					assign regwrite	=	systemcont[8];
					assign alusel		=  systemcont[9];
					assign alucont		=	systemcont[13:10];
					assign pcsource	=	systemcont[15:14];
					assign iord			=	systemcont[16];
					assign llcntl		=	systemcont[19:17];
					assign slcntl		=	systemcont[22:20];
					assign wenable		=	systemcont[23];
					assign csrrw		=	systemcont[24];
					
						//OPCODE of RV32I
					parameter   LOAD		=  7'b0000011;
					parameter   STORE		=  7'b0100011;
					parameter	OP			=	7'b0110011; 
					parameter	OPIMM		=	7'b0010011;
					parameter	LUI		=	7'b0110111;
					parameter	AUIPC		=	7'b0010111;
					parameter	JAL		=	7'b1101111;
					parameter	JALR		=	7'b1100111;
					parameter	BRANCH	=	7'b1100011;
					parameter	MISCMEM	=	7'b0001111;
					parameter	SYSTEM	=	7'b1110011;
	
					//funct3 code of FUNCT3
					parameter   ADDSUB	=  3'b000;
					parameter   SLT		=  3'b010;
					parameter	SLTU		=	3'b011;
					parameter	AND		=	3'b111;
					parameter	OR			=	3'b110;
					parameter	XOR		=	3'b100;
					parameter   SLL		=  3'b001;
					parameter   SRLSRA	=  3'b101;
	
					//funct3 code of LOAD
					parameter   LB			=  3'b000;
					parameter   LH			=  3'b001;
					parameter	LW			=	3'b010;
					parameter	LBU		=	3'b100;
					parameter	LHU		=	3'b101;
	
					//funct3 code of STORE
					parameter   SB			=  3'b000;
					parameter   SH			=  3'b001;
					parameter	SW			=	3'b010;
			
					//funct3 code of BRANCH
					parameter   BEQ			=  3'b000;
					parameter   BNE			=  3'b001;
					parameter	BLT			=	3'b100;
					parameter   BGE			=  3'b101;
					parameter   BLTU			=  3'b110;
					parameter	BGEU			=	3'b111;
	
					//funct3 code of MISCMEM
					parameter   FENCE			=  3'b000;
					parameter   FENCEI		=  3'b001;
			
					//funct3 code of SYSTEM
					parameter   ECAEBR	=  3'b000;
					parameter   CSRRW		=  3'b001;
					parameter	CSRRS		=	3'b010;
					parameter	CSRRC		=	3'b011;
					parameter	CSRRWI	=	3'b101;
					parameter	CSRRSI	=	3'b110;
					parameter   CSRRCI	=  3'b111;
				
					/* additional OPCode of RV32I
					parameter	MUL		=	3'b000;
					parameter	MULH		=	3'b001;
					parameter	MULHSU	=	3'b010;
					parameter	MULHU		=	3'b011;
					parameter	DIV		=	3'b100;
					parameter	DIVU		=	3'b101;
					parameter	REM		=	3'b110;
					parameter	REMU		=	3'b111;
					*/
	
					//funct11 code of ECALL and EBREAK
					parameter   ECALL		=  11'b0;
					parameter   EBREAK	=  11'b00000000001;

					
					assign systemcont =	decoder(opcode,funct3,funct7,imm12);
					assign branchcntl	=	branchcntl_base(opcode,funct3);
					

					ffr5 REGrs1        (clk,IDREGclear,IDREGstall,rs1,REGDrs1);
					ffr5 REGrs2        (clk,IDREGclear,IDREGstall,rs2,REGDrs2);
					ffr5 REGrd         (clk,IDREGclear,IDREGstall,rd,REGDrd);
					ffr  REGimm        (clk,IDREGclear,IDREGstall,imm,REGDimm);
					ffr  REGjimm       (clk,IDREGclear,IDREGstall,jimm,REGDjimm);
					ffr  REGbranchimm  (clk,IDREGclear,IDREGstall,branchimm,REGDbranchimm);
					ffr  REGstoreimm   (clk,IDREGclear,IDREGstall,storeimm,REGDstoreimm);
					ffr  REGluiimm     (clk,IDREGclear,IDREGstall,luiimm,REGDluiimm);
					ffr  REGcsrimm     (clk,IDREGclear,IDREGstall,csrimm,REGDcsrimm);
					ffr  REGpc         (clk,IDREGclear,IDREGstall,REGFpc,REGDpc);

				   ffr2  REGregfwda  (clk,IDREGclear,IDREGstall,fwdmuxsela,REGDregfwda);
					ffr2  REGregfwdb  (clk,IDREGclear,IDREGstall,fwdmuxselb,REGDregfwdb);
					ffr2  REGalusrca  (clk,IDREGclear,IDREGstall,alusrca,REGDalusrca);
					ffr4  REGalusrcb  (clk,IDREGclear,IDREGstall,alusrcb,REGDalusrcb);
					ffr2  REGmem2reg  (clk,IDREGclear,IDREGstall,mem2reg,REGDmem2reg);
					ffr1  REGregwrite (clk,IDREGclear,IDREGstall,regwrite,REGDregwrite);
					ffr1  REGalusel   (clk,IDREGclear,IDREGstall,alusel,REGDalusel);
					ffr4  REGalucont  (clk,IDREGclear,IDREGstall,alucont,REGDalucont);
					ffr2  REGpcsource (clk,IDREGclear,IDREGstall,pcsource,REGDpcsource);
					ffr1  REGiord     (clk,IDREGclear,IDREGstall,iord,REGDiord);
					ffr3  REGllcntl   (clk,IDREGclear,IDREGstall,llcntl,REGDllcntl);
					ffr3  REGslcntl   (clk,IDREGclear,IDREGstall,slcntl,REGDslcntl);
					ffr2  REGbrcntl   (clk,IDREGclear,IDREGstall,branchcntl,REGDbranchcntl);
					ffr1  REGwenable  (clk,IDREGclear,IDREGstall,wenable,REGDwenable);
					ffr1  REGcsrrw    (clk,IDREGclear,IDREGstall,csrrw,REGDcsrrw);
					ffr12 REGcsraddr  (clk,IDREGclear,IDREGstall,csraddr,REGDcsraddr);
					
				//ここまで
					
				//Register Forwording controller
				   ffr7 REGopcode1		  (clk,IDREGclear,IDREGstall,opcode,opcode1);
					ffr7 REGopcode2        (clk,IDREGclear,IDREGstall,opcode1,opcode2);
					ffr7 REGopcode3        (clk,IDREGclear,IDREGstall,opcode2,opcode3);
				
					ffr5 REGrdold1         (clk,IDREGclear,IDREGstall,rd,rdold1);
					ffr5 REGrdold2         (clk,IDREGclear,IDREGstall,rdold1,rdold2);
					ffr5 REGrdold3         (clk,IDREGclear,IDREGstall,rdold2,rdold3);
					
					assign ereg0 =  ereg(opcode);
				   assign ereg1 =  ereg(opcode1);
					assign ereg2 =  ereg(opcode2);
					assign ereg3 =  ereg(opcode3);
					
					assign regc_1[1] = ereg0[2] & ereg1[0]; //rs1
					assign regc_1[0] = ereg0[1] & ereg1[0]; //rs2
					assign regc_2[1] = ereg0[2] & ereg2[0]; //rs1
					assign regc_2[0] = ereg0[1] & ereg2[0]; //rs2
					assign regc_3[1] = ereg0[2] & ereg3[0]; //rs1
					assign regc_3[0] = ereg0[1] & ereg3[0]; //rs2
					
					assign fwdmuxsela = regfwdds1(fwdold1,fwdold2,fwdold3);
					assign fwdmuxselb = regfwdds2(fwdold1,fwdold2,fwdold3);
					
					assign fwdold1 = fwd(regc_1,rdold1,rs1,rs2);
					assign fwdold2 = fwd(regc_2,rdold2,rs1,rs2);
					assign fwdold3 = fwd(regc_3,rdold3,rs1,rs2);
					
					function [1:0]fwd;
					 input [1:0]reg_c;
					 input [4:0]REGold;
					 input [4:0]rs1;
					 input [4:0]rs2;
					 
					case (reg_c)
						2'b00: fwd = 2'b00;
						2'b10: case(REGold - rs1)
										5'b0000: fwd = 2'b10;
										default: fwd = 2'b00;
										endcase
						2'b01: case(REGold - rs2)
										5'b0000: fwd = 2'b01;
										default: fwd = 2'b00;
										endcase
						2'b11: case(REGold - rs2)
										5'b0000: case(REGold - rs1)
													5'b0000: fwd = 2'b11;
													default: fwd = 2'b01;
													endcase
										default: case(REGold - rs1)
													5'b0000: fwd = 2'b10;
													default: fwd = 2'b00;
													endcase
								  endcase
					endcase
					
					endfunction
					
			function [2:0]ereg;
				input [6:0]opcode;
			
				begin
		
					case(opcode)
							LOAD:    ereg	=	3'b101;	
							STORE:   ereg	=	3'b110;	
							OP:      ereg	=	3'b111;	
							OPIMM:   ereg	=	3'b101;	
							LUI:     ereg	=	3'b001;
							AUIPC:   ereg	=	3'b001;
							JAL:     ereg	=	3'b001;
							JALR:    ereg	=	3'b101;	
							BRANCH:  ereg	=	3'b110;
							MISCMEM: ereg	=	3'b000;
							SYSTEM:  ereg	=	3'b000;				
			   	default:	ereg		=	3'b000;	
				   endcase
				end
				   
			endfunction
					
					function [1:0]regfwdds1; //Register Forword Data Source for Register source1
				        input  [1:0]fwdold1;
                    input  [1:0]fwdold2;
                    input  [1:0]fwdold3;
						 
						 case(fwdold1[1])
							1'b1: regfwdds1 = 2'b01;
							1'b0: case (fwdold2[1])
									  1'b1:  regfwdds1 = 2'b10;
						           1'b0:  case(fwdold3[1])
											     1'b1: regfwdds1 = 2'b11;
												  1'b0: regfwdds1 = 2'b00;
												endcase
						         endcase
						endcase
					endfunction
					
					function [1:0]regfwdds2;//Register Forword Data Source for Register source2
				        input  [1:0]fwdold1;
                    input  [1:0]fwdold2;
                    input  [1:0]fwdold3;
						 
						 case(fwdold1[0])
							1'b1: regfwdds2 = 2'b01;
							1'b0: case (fwdold2[0])
									  1'b1:  regfwdds2 = 2'b10;
						           1'b0:  case(fwdold3[0])
											     1'b1: regfwdds2 = 2'b11;
												  1'b0: regfwdds2 = 2'b00;
												endcase
						         endcase
						endcase
					endfunction
					
				function	[1:0]branchcntl_base;
				input 		[6:0]	opcode;
				input			[2:0]	funct3;
				
				begin
				if(opcode == BRANCH )begin
						branchcntl_base = 2'b01;
				end
				else if(opcode == JAL || opcode == JALR) begin
						branchcntl_base = 2'b10;
				end
				else branchcntl_base = 1'b00;				
				end
            endfunction
	
				function [24:0] decoder;
				input 		[6:0]	opcode;
				input			[2:0]	funct3;
				input			[6:0] funct7;
				input			[11:0]imm12;

				begin
				case(opcode)	//opcode check
					OP:begin		//OP instructions
					   case(funct3) //funct3 check
						   ADDSUB:	begin
									case(funct7)
											7'b0:				decoder = 25'b0_0_000_000_0_00_0011_0_1_00_0000_00; //ADD
											7'b0100000:		decoder = 25'b0_0_000_000_0_00_0100_0_1_00_0000_00; //SUB
//											7'b0000001:	   decoder = 25'b0_0_000_000_0_00_0000_1_1_00_0000_00; //MUL
											default:			decoder = 25'b0_0_000_000_0_00_0011_0_1_00_0000_00;
									endcase
									end
						   SLT:	begin
									case(funct7) 
											7'b0:				decoder = 25'b0_0_000_000_0_00_0101_0_1_00_0000_00; //SLT
//											7'b0000001:		decoder = 25'b0_0_000_000_0_00_0010_1_1_00_0000_00; //MULHSU
											default:			decoder = 25'b0_0_000_000_0_00_0101_0_1_00_0000_00;
									endcase
									end
						   SLTU:	begin
									case(funct7) 
											7'b0:				decoder = 25'b0_0_000_000_0_00_0110_0_1_00_0000_00; //SLTU
//											7'b0000001:		decoder = 25'b0_0_000_000_0_00_0011_1_1_00_0000_00; //MULHU
											default:			decoder = 25'b0_0_000_000_0_00_0110_0_1_00_0000_00; 
									endcase
									end
						   AND:	begin
									case(funct7)
											7'b0:				decoder = 25'b0_0_000_000_0_00_0000_0_1_00_0000_00; //AND
//											7'b0000001:		decoder = 25'b0_0_000_000_0_00_0111_1_1_00_0000_00; //REMU
											default:			decoder = 25'b0_0_000_000_0_00_0000_0_1_00_0000_00; 
									endcase
									end
						   OR:	begin
									case(funct7)
											7'b0:				decoder = 25'b0_0_000_000_0_00_0001_0_1_00_0000_00; //OR
//											7'b0000001:		decoder = 25'b0_0_000_000_0_00_0110_1_1_00_0000_00; //REM
											default:			decoder = 25'b0_0_000_000_0_00_0001_0_1_00_0000_00;
									endcase
									end
						   XOR:	begin
									case(funct7)
											7'b0:				decoder = 25'b0_0_000_000_0_00_0010_0_1_00_0000_00; //XOR
//											7'b0000001:		decoder = 25'b0_0_000_000_0_00_0100_1_1_00_0000_00; //DIV
											default:			decoder = 25'b0_0_000_000_0_00_0010_0_1_00_0000_00;
									endcase
									end
						   SLL:		begin
									case(funct7)
											7'b0:				decoder = 25'b0_0_000_000_0_00_0111_0_1_00_0000_00; //SLL
//											7'b0000001:		decoder = 25'b0_0_000_000_0_00_0001_1_1_00_0000_00; //MULH
											default:			decoder = 25'b0_0_000_000_0_00_0111_0_1_00_0000_00;
									endcase
									end
						   SRLSRA:begin
						   			case(funct7)
						   				7'b0:			decoder = 25'b0_0_000_000_0_00_1000_0_1_00_0000_00; //SRL
							   			7'b0100000:	decoder = 25'b0_0_000_000_0_00_1001_0_1_00_0000_00; //SRA
//											7'b0000001:	decoder = 25'b0_0_000_000_0_00_0101_1_1_00_0000_00; //DIVU
											default:		decoder = 25'b0_0_000_000_0_00_1000_0_1_00_0000_00;
										endcase
									end
						   default: decoder = 25'b0_0_000_000_0_00_000_0000_0_1_00_0000_00; 
					   endcase
					end
					
				OPIMM:begin
						case(funct3) 
							ADDSUB:	 decoder = 25'b0_0_000_000_0_00_0011_0_1_00_0010_00;	
							SLT:		 decoder = 25'b0_0_000_000_0_00_0101_0_1_00_0010_00;
							SLTU:		 decoder = 25'b0_0_000_000_0_00_0110_0_1_00_0010_00;
							AND:		 decoder = 25'b0_0_000_000_0_00_0000_0_1_00_0010_00;
							OR:		 decoder = 25'b0_0_000_000_0_00_0001_0_1_00_0010_00;
							XOR:		 decoder = 25'b0_0_000_000_0_00_0010_0_1_00_0010_00;
							SLL:		 decoder = 25'b0_0_000_000_0_00_0111_0_1_00_0010_00;
							SRLSRA:	begin
										case(funct7) 
											7'b0:			 decoder = 25'b0_0_000_000_0_00_1000_0_1_00_0010_00;
											7'b0100000:	 decoder = 25'b0_0_000_000_0_00_1001_0_1_00_0010_00;
											default:  decoder = 25'b0_0_000_000_0_00_1000_0_1_00_0010_00;
										endcase
										end
							default:  decoder = 25'b0_0_000_000_0_00_00011_1_00_010_00;
						endcase
						end
						
				LOAD:	begin
						case(funct3)
								LB:		 decoder = 25'b0_0_000_100_1_00_0011_0_1_01_0010_00;
								LH:		 decoder = 25'b0_0_000_011_1_00_0011_0_1_01_0010_00;
								LW:		 decoder = 25'b0_0_000_000_1_00_0011_0_1_01_0010_00;
								LBU:		 decoder = 25'b0_0_000_010_1_00_0011_0_1_01_0010_00;
								LHU:		 decoder = 25'b0_0_000_001_1_00_0011_0_1_01_0010_00;
                        default:  decoder = 25'b0_0_000_111_1_00_0011_0_1_01_0010_00;
						endcase
						end
				STORE: begin
						case(funct3)
								LB:		 decoder = 25'b0_1_100_000_1_00_0011_0_0_00_0100_00;
								LH:		 decoder = 25'b0_1_011_000_1_00_0011_0_0_00_0100_00;
								LW:		 decoder = 25'b0_1_000_000_1_00_0011_0_0_00_0100_00;
								LBU:		 decoder = 25'b0_1_010_000_1_00_0011_0_0_00_0100_00;
								LHU:		 decoder = 25'b0_1_001_000_1_00_0011_0_0_00_0100_00;
                        default:  decoder = 25'b0_1_111_000_1_00_0011_0_0_00_0100_00;
						endcase
						end
				BRANCH: begin
						case(funct3)
								BEQ:		decoder = 25'b0_0_000_000_0_01_1110_0_0_00_0000_00;
								BNE:		decoder = 25'b0_0_000_000_0_01_1101_0_0_00_0000_00;
								BLT:		decoder = 25'b0_0_000_000_0_01_0101_0_0_00_0000_00;
								BGE:		decoder = 25'b0_0_000_000_0_01_1011_0_0_00_0000_00;
								BLTU:		decoder = 25'b0_0_000_000_0_01_0110_0_0_00_0000_00;
								BGEU:		decoder = 25'b0_0_000_000_0_01_1100_0_0_00_0000_00;								
						default:  decoder = 25'b0_0_000_000_0_01_1101_0_0_00_0000_00;
							endcase
							end
				
				LUI: decoder = 25'b0_0_000_000_0_00_0011_0_1_00_0101_10;
				JAL:  decoder = 25'b0_0_000_000_1_10_0011_0_1_10_0011_01;
				JALR:  decoder = 25'b0_0_000_000_1_10_0011_0_1_10_0010_00;	
				AUIPC:	decoder = 25'b0_0_000_000_0_00_0011_0_1_00_0010_01;
				SYSTEM: begin
						case(funct3)
								CSRRW:		 decoder = 25'b1_0_000_000_1_00_0011_0_1_11_1111_00;
								CSRRS:		 decoder = 25'b1_0_000_000_1_00_0001_0_0_11_0110_00;
								CSRRC:		 decoder = 25'b1_0_000_000_1_00_1010_0_0_11_0110_00;
								CSRRWI:		 decoder = 25'b1_0_000_000_1_00_0011_0_0_00_1000_00;
								CSRRSI:		 decoder = 25'b1_0_000_000_1_00_0001_0_0_00_1000_00;
								CSRRCI:		 decoder = 25'b1_0_000_000_1_00_1001_0_0_00_1000_00;
                        default:  decoder = 25'b1_0_000_000_1_00_00011_0_00_1111_00;
						endcase
						end
														
            default:	 decoder = 25'b0_0_000_000_0_00_00000_0_00_000_00;
				endcase
		end
endfunction
					




endmodule