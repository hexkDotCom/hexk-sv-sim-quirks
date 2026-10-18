// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-012: local:: in randomize() with on a specialized parameterized class is rejected.
module top;
   class seq #(int W = 8);
      rand bit [W-1:0] n;
   endclass

   initial begin
      seq #(16) s = new();
      bit [15:0] n = 16'd9;
      int ok;
`ifndef QUIRK_NO_TRIGGER
      ok = s.randomize() with {n == local::n;};
      if (ok == 1 && s.n == 9) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS randomize %0d n %0d", ok, s.n);
`endif
      begin
         // A name that cannot hit a member of the class, without local::.
         bit [15:0] wanted_n = 16'd9;
         ok = s.randomize() with {n == wanted_n;};
         if (ok == 1 && s.n == 9) $display("QUIRK_WORKAROUND: OK");
         else $display("QUIRK_WORKAROUND: FAILS randomize %0d n %0d", ok, s.n);
      end
      $finish;
   end
endmodule
