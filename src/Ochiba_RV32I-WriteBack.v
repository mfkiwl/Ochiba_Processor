module WRITEBACK #(parameter WIDTH=32)
                 (input [4:0]REGMrd,
				      input [WIDTH-1:0]REGMaluresult,REGMbranchimm,REGMpc,
				      input [1:0]REGMmem2reg,
				      input [1:0]REGMpcsource,
				      input [1:0]REGMbranchcntl,
						input REGMregwrite,REGMzero,
				      input [WIDTH-1:0]REGMdmemdata,REGMcsrrdata,
						output [4:0]regaddr,
						output [WIDTH-1:0]regwd,
						output regwe,
						output [WIDTH-1:0]dnextpc,
						output branchpcwe);
						
						assign regaddr    =  REGMrd;
						assign regwe      =  REGMregwrite;
						
						wire [WIDTH-1:0]pcbranch	=	REGMpc + 4 + REGMbranchimm;
						assign branchpcwe =  branchpcencntl(REGMbranchcntl,REGMzero);  //Branch PC Enable Control
						
						mux4			pcmux(32'b0,pcbranch,REGMaluresult,32'b0,REGMpcsource,dnextpc);
						mux4			writedatamux(REGMaluresult,REGMdmemdata,REGMpc + 4,REGMcsrrdata,REGMmem2reg,regwd);
						
						//Branch Controaller
						function branchpcencntl;
						    input [1:0]branchcntl;
						    input zero;
						
						    begin
						    case(branchcntl)
							    2'b00:branchpcencntl  =  1'b0;	//the Others instructions
							    2'b01:begin	//Branch OPCODE
							     		    if(zero == 0)	branchpcencntl	=	1'b0;
						    			    else				branchpcencntl	=	1'b1;
							          end
								 2'b10: branchpcencntl = 1'b1; //JAL,JALR
								 2'b11: branchpcencntl = 1'b0; //Others instructions
							   default:branchcntl = 1'b0;
						endcase
						end
					endfunction			
						
						
endmodule 