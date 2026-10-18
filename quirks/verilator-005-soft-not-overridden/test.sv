// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-005: a soft constraint is not overridden by randomize() with.
module top;
   class item;
      rand int unsigned size;
      constraint size_default_c {soft size == 5;}
   endclass

   initial begin
      item it = new();
      int  ok;
`ifndef QUIRK_NO_TRIGGER
      ok = it.randomize() with {size == 7;};
      if (ok == 1 && it.size == 7) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS randomize returned %0d, size %0d", ok, it.size);
`endif
      it.size_default_c.constraint_mode(0);
      ok = it.randomize() with {size == 7;};
      if (ok == 1 && it.size == 7) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS randomize returned %0d, size %0d", ok, it.size);
      $finish;
   end
endmodule
