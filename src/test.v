//-------------------------------------------------------
// Ochiba_RV32IM.v
// Sodium(sodium@wide.sfc.ad.jp)
// Instruction set:RISC-V RV32IM
//
// Testbench of Ochiba Processer
//-------------------------------------------------------
`timescale 1ns/10ps

// top level design for testing
module test #(parameter WIDTH = 31, REGBITS = 3)();

   reg                 clk;
   reg                 reset;
   wire  [7:0]gpio;
   // 10nsec --> 100MHz
   parameter STEP = 10;

   Ochiba_RV32IM Ochiba(clk,reset,gpio);

   // initialize test
   initial
      begin
         `ifdef __POST_PR__
            $sdf_annotate("rv32i.sdf", test.Ochiba, , "sdf.log", "MAXIMUM");
         `endif
         clk <= 1; reset <= 1; 
         // dump waveform
         $dumpfile("dump_Ochiba_RV32IM.vcd");
         $dumpvars(0, Ochiba);
         // stop at 1,000 cycles
         #(STEP* 500000);
         $display("Simulation failed");
         $finish;
      end

   // generate clock to sequence tests
   always #(STEP/2)
      begin
         clk <= ~clk;
      end

endmodule 
