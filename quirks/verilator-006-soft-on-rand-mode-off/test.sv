// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-006: a soft constraint on a member with rand_mode(0) is enforced as a hard one.
module top;
   class item;
      rand int unsigned size;
      rand int unsigned data;
      constraint size_default_c {soft size == 5;}
   endclass

   initial begin
      item it = new();
      int  ok;
`ifndef QUIRK_NO_TRIGGER
      it.size.rand_mode(0);
      it.size = 3;
      ok = it.randomize();
      if (ok == 1 && it.size == 3) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS randomize returned %0d, size %0d", ok, it.size);
      it.size.rand_mode(1);
`endif
      it.size.rand_mode(0);
      it.size_default_c.constraint_mode(0);
      it.size = 3;
      ok = it.randomize();
      if (ok == 1 && it.size == 3) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS randomize returned %0d, size %0d", ok, it.size);
      $finish;
   end
endmodule
