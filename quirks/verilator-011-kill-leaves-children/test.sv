// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-011: process::kill() does not end the processes the killed process forked.
module top;
   timeunit 1ns; timeprecision 1ps;

   bit     child_ran;
   process parent;
   process child;

   initial begin
`ifndef QUIRK_NO_TRIGGER
      fork
         begin
            parent = process::self();
            fork
               begin
                  #10ns;
                  child_ran = 1;
               end
            join_none
            #100ns;
         end
      join_none
      #1ns;
      parent.kill();
      #20ns;
      if (!child_ran) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS the child of the killed process ran");
`endif
      // Keep the child's handle and kill it explicitly.
      child_ran = 0;
      fork
         begin
            parent = process::self();
            fork
               begin
                  child = process::self();
                  #10ns;
                  child_ran = 1;
               end
            join_none
            #100ns;
         end
      join_none
      #1ns;
      child.kill();
      parent.kill();
      #20ns;
      if (!child_ran) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS");
      $finish;
   end
endmodule
