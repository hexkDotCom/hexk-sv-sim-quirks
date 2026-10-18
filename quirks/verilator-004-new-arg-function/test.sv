// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-004: an argument of new() that calls a module function arrives as 0.
package quirk_pkg;
   class holder;
      int value;
      function new(int v);
         value = v;
      endfunction
   endclass
endpackage

module top;
   import quirk_pkg::*;

   function automatic int twice(int v);
      return 2 * v;
   endfunction

   initial begin
      holder h;
      int arg;
`ifndef QUIRK_NO_TRIGGER
      h = new(twice(21));
      if (h.value == 42) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS new(twice(21)) stored %0d", h.value);
`endif
      arg = twice(21);
      h = new(arg);
      if (h.value == 42) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS stored %0d", h.value);
      $finish;
   end
endmodule
