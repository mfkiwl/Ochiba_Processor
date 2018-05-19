//-------------------------------------------------------
//
// ram.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32I
//
// Instruction RAM and data RAM
// Ochiba Processer
// RV32I ISA Model
// In-order 6-stage pipeline
//
//-------------------------------------------------------
module instr_ram #(parameter WIDTH = 32)
(
	input [31:0] d,
	input [31:0] addr,
	input clk, menable,
	output reg [31:0] q
);

	// Declare the RAM variable
	reg [31:0] ram[19000:0];

	initial begin
		ram[32'h00000000] = 32'h0FF00193; //	addi $3,$0,1	write data to GPIO
		ram[32'h00000004] = 32'h0000F137; //   lui $3,0000_0	
		ram[32'h00000008] = 32'hFFF10113; //	addi $2,$0,FFF delay counter
		ram[32'h0000000c] = 32'h000000B3; //  	add  $1,$0,$0	reset counter
		ram[32'h00000010] = 32'h00108093; //	addi $1,$1,1    counter
		ram[32'h00000014] = 32'h00208263; //	beq $1,$2,PC+8	
		ram[32'h00000018] = 32'hFF9FF06F; //    jmp PC-8
		ram[32'h0000001c] = 32'hFFFFF237; //    lui $4,FFFF_F		gpio_addr
		ram[32'h00000020] = 32'hF0020213; //    addi $4,$1,F00		gpio_addr
		ram[32'h00000024] = 32'h00320023; //    sb  $3,$4,0000		write to gpio
		ram[32'h00000028] = 32'h000000B3; //	add  $1,$0,$0	reset counter
		ram[32'h0000002c] = 32'h00108093; //	addi $1,$1,1    counter // True branch address
		ram[32'h00000030] = 32'h00208263; //	beq $1,$2,PC+8	
		ram[32'h00000034] = 32'hFF9FF06F; //    jmp PC-8
		ram[32'h00000038] = 32'h00020023; //	sb  $3,$4,0000		write to gpio
		ram[32'h0000003c] = 32'hFD1FF06F; //	jmp pc -h30			send start
	end
		
	always @(negedge clk)
	begin
	// Write
		if (menable == 1) ram[addr] <= d;
	//read
		q <= ram[addr];		
	end
endmodule

module data_ram #(parameter WIDTH = 32)
(
	input [31:0] d,
	input [31:0] addr,
	input clk, menable,
	output reg [31:0] q
);

	// Declare the RAM variable
	reg [31:0] ram[1024:0];
	always @(negedge clk)
	begin
	// Write
		if (menable == 1) ram[addr] <= d;
	//read
		q <= ram[addr];		
	end
endmodule

