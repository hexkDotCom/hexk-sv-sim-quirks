// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-002: a forked wait on a local of an automatic module task dereferences a null pointer.
module top;
   timeunit 1ns; timeprecision 1ps;

   int unsigned count;

`ifndef QUIRK_NO_TRIGGER
   // Waits up to 5 ns for count to change; seen is a local of the automatic task.
   task automatic wait_in_module(output bit woke);
      int unsigned seen = count;
      bit changed = 0;
      fork
         begin
            wait (count != seen);
            changed = 1;
         end
         #5ns;
      join_any
      disable fork;
      woke = changed;
   endtask
`endif

   // The same wait in a class method.
   class waiter;
      task wait_change(output bit woke);
         int unsigned seen = count;
         bit changed = 0;
         fork
            begin
               wait (count != seen);
               changed = 1;
            end
            #5ns;
         join_any
         disable fork;
         woke = changed;
      endtask
   endclass

   initial begin
      bit stale;
      bit fresh;
      waiter w = new();
`ifndef QUIRK_NO_TRIGGER
      fork
         wait_in_module(fresh);
         #1ns count++;
      join
      wait_in_module(stale);
      if (fresh && !stale) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS new %0b stale %0b", fresh, stale);
`endif
      fork
         w.wait_change(fresh);
         #1ns count++;
      join
      w.wait_change(stale);
      if (fresh && !stale) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS new %0b stale %0b", fresh, stale);
      $finish;
   end
endmodule
