// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk verilator-001: a class event triggered while nobody waits satisfies a later @(e).
module top;
   timeunit 1ns; timeprecision 1ps;

   class notifier;
`ifndef QUIRK_NO_TRIGGER
      event changed;
      bit woke;

      function void notify();
         ->changed;
      endfunction

      // Waits up to 5 ns for the next trigger.
      task wait_for_change();
         woke = 0;
         fork
            begin
               @(changed);
               woke = 1;
            end
            #5ns;
         join_any
         disable fork;
      endtask
`endif

      int unsigned count;
      bit counter_woke;

      function void notify_count();
         count++;
      endfunction

      // Waits up to 5 ns for the counter to change.
      task wait_for_count();
         int unsigned seen = count;
         counter_woke = 0;
         fork
            begin
               wait (count != seen);
               counter_woke = 1;
            end
            #5ns;
         join_any
         disable fork;
      endtask
   endclass

   initial begin
      notifier n = new();
      bit stale_woke;
`ifndef QUIRK_NO_TRIGGER
      // Trigger at 0 ns with nobody waiting; wait from 10 ns: must not wake.
      n.notify();
      #10ns;
      n.wait_for_change();
      if (n.woke) $display("QUIRK_RESULT: DIFFERS @(e) at %0t returned for a trigger at 0", $time);
      else $display("QUIRK_RESULT: AS_EXPECTED");
`endif
      // Same with the counter: a stale notification must not wake, a new one must.
      n.notify_count();
      #10ns;
      n.wait_for_count();
      stale_woke = n.counter_woke;
      fork
         n.wait_for_count();
         #1ns n.notify_count();
      join
      if (!stale_woke && n.counter_woke) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS stale %0b new %0b", stale_woke, n.counter_woke);
      $finish;
   end
endmodule
