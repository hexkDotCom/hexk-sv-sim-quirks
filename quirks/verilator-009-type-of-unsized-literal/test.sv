// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-009: type() of an unsized literal is an internal error.
module top;
   initial begin
`ifndef QUIRK_NO_TRIGGER
      var type(5) a = 7;
      if ($bits(a) == 32) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS $bits %0d", $bits(a));
`endif
      begin
         var type(32'sd5) b = 7;
         if ($bits(b) == 32) $display("QUIRK_WORKAROUND: OK");
         else $display("QUIRK_WORKAROUND: FAILS $bits %0d", $bits(b));
      end
      $finish;
   end
endmodule
