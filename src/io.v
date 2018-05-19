//-------------------------------------------------------
//
// io.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// I/O block
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------
module addrselect #(parameter WIDTH = 32) 
(	input [31:0] adr,
	input [31:0] mmemdata,mmemdatah,dmemdata,
	output menable,denable,
	output [31:0]memdata);
	
	wire s,h;
	wire [31:0]selmmemdata;

	assign s = (adr[31:0] == 32'b111111111111111111111111111xxxxx);
	assign h = (adr[31] == 1);
	assign denable = s ? 1'b1 : 1'b0; 
	assign menable = s ? 1'b0 : 1'b1; 
	assign selmmemdata = h ? mmemdatah : mmemdata; 
	assign memdata = s ? dmemdata : selmmemdata; 
 		
endmodule

module gpio(input [31:0]adr,data,
            input clk,wenable,
            output [7:0]gpio);
            
         reg [31:0]register;
			
			initial begin
			register <= 32'h0000_0000;
			end
				
         
        always @(posedge clk) begin
            if(adr == 32'hFFFFFF00 && wenable == 1'b1) register <= data;
         end   
         
         assign gpio[7:0] = register[7:0];
            
endmodule