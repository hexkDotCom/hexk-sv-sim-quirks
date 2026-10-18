// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 HEXK
// Quirk vcs-001: a delay in a type-parameterized class is scaled by the time unit of the scope
// that declares the type argument.
package lib_pkg;
   timeunit 1ps; timeprecision 1ps;

   // Waits delay_ps in the time unit of this package (ps).
   class delayer #(type T = int);
      task wait_ps(longint unsigned delay_ps);
         #(delay_ps);
      endtask
   endclass

   // The same delay in a static task of a class without a type parameter.
   class wait_util;
      static task wait_ps(longint unsigned delay_ps);
         #(delay_ps);
      endtask
   endclass

   class safe_delayer #(type T = int);
      task wait_ps(longint unsigned delay_ps);
         wait_util::wait_ps(delay_ps);
      endtask
   endclass
endpackage

module top;
   timeunit 1ns; timeprecision 1ps;

   class module_item;
      int data;
   endclass

   initial begin
`ifndef QUIRK_NO_TRIGGER
      lib_pkg::delayer #(module_item) d = new();
`endif
      lib_pkg::safe_delayer #(module_item) s = new();
      realtime start;
`ifndef QUIRK_NO_TRIGGER
      start = $realtime;
      d.wait_ps(30000);
      if ($realtime - start == 30.0) $display("QUIRK_RESULT: AS_EXPECTED");
      else $display("QUIRK_RESULT: DIFFERS 30000 ps took %0.3f ns", $realtime - start);
`endif
      start = $realtime;
      s.wait_ps(30000);
      if ($realtime - start == 30.0) $display("QUIRK_WORKAROUND: OK");
      else $display("QUIRK_WORKAROUND: FAILS 30000 ps took %0.3f ns", $realtime - start);
      $finish;
   end
endmodule
