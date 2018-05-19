//-------------------------------------------------------
//
// Ochiba_RV32IM-cont.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32IM
//
// Ochiba Processer RV32IM model
// Datapath/Pipeline Controller
//
//-------------------------------------------------------
module Ochiba_RV32IM_cont 		(input clk,reset,branch,
								output IFREGclear,IDREGclear,RFREGclear,ExREGclear,MAREGclear,WBREGclear,IFREGstall,IDREGstall,RFREGstall,ExREGstall,MAREGstall,
								input Exnow);
										
				assign IFREGclear = branch | reset;
				assign IDREGclear = branch | reset;
				assign RFREGclear = branch | reset;
				assign ExREGclear = branch | reset | Exnow;
				assign MAREGclear = branch | reset;
				assign WBREGclear = branch | reset;
				
			    assign IFREGstall = Exnow ? 1'b1 : 1'b0;
			    assign IDREGstall = Exnow ? 1'b1 : 1'b0;
			    assign RFREGstall = Exnow ? 1'b1 : 1'b0;
			    assign ExREGstall = 1'b0;
			    assign MAREGstall = 1'b0;
			    

endmodule
